@echo off

call settings.bat

:: =======================================================================================
:: Main

::: Load data into the classification database.
::: This script has 6 steps. The step that is executed is defined by %type_of_load%.
::: To execute a step, run this script with the number or name of the step as a parameter
::: or start the script and provide the number or name of the step in the prompt.

::: Option 0: create_database
:::: Create the classification database, its schemas, and the initial tables.
::: Option 1: create_classification
:::: Create a multi-level classification using publicationclassification.
:::: The classification parameter settings should be specified in the
:::: global variables %classification_*%.
:::: The classification parameter settings and the output of
:::: publicationclassification are logged to time-stamped log files in the
:::: folder [/log/publicationclassification].
::: Option 2: create_labeling
:::: Generate labels for the clusters of the classification using the OpenAI GPT
:::: language model.
:::: The classification labeling parameter settings should be specified in the
:::: global variables %classification_*%.
:::: The output of publicationclassificationlabeling is logged to a time-stamped
:::: log file in the folder [/log/publicationclassificationlabeling].
::: Option 3: table_scripts
:::: Run all scripts in [src\sql\classification\table_scripts] to load data
:::: into the classification database.
::: Option 4: create_vosviewer_maps
:::: Generate the VOSviewer map and network file data and load it into the
:::: classification database.
::: Option 5: load_vosviewer_maps_only
:::: Load the VOSviewer map file data into the classification database.
::: Option 6: validation
:::: Perform row-counts and data-types for the classification database.

:: Input variables
::: 1. type_of_load
::::   possible values:
::::    0 | create_database
::::    1 | create_classification
::::    2 | create_labeling
::::    3 | table_scripts
::::    4 | create_vosviewer_maps
::::    5 | load_vosviewer_maps_only
::::    6 | validation

:: Executables
::: java_exe
::: powershell_exe
::: publicationclassification_exe
::: publicationclassificationlabeling_exe
::: vosviewer_exe
:: =======================================================================================

set type_of_load=%~1
if not defined type_of_load call :choose_type_of_load
call :execute_type_of_load

call %functions%\notify.bat "%classification_db_name%" "%~n0" "%type_of_load%"
pause
goto:eof
:: =======================================================================================


:: =======================================================================================
:create_database
:: =======================================================================================

call %functions%\create_database.bat ^
    %classification_db_name% ^
    %classification_sql_src_folder% ^
    %classification_sql_log_folder%

call %functions%\check_errors.bat

call %functions%\run_sql_script.bat ^
    %classification_db_name% ^
    %classification_sql_src_folder%\create_schemas.sql ^
    %classification_sql_log_folder% ^
    ""

call %functions%\run_sql_script.bat ^
    %classification_db_name% ^
    %classification_sql_src_folder%\create_input_tables_publicationclassification.sql ^
    %classification_sql_log_folder% ^
    "-v relational_db_name=%relational_db_name% classification_min_pub_year_extended_pub_set=%classification_min_pub_year_extended_pub_set% classification_max_pub_year_extended_pub_set=%classification_max_pub_year_extended_pub_set%  classification_min_pub_year_core_pub_set=%classification_min_pub_year_core_pub_set% classification_max_pub_year_core_pub_set=%classification_max_pub_year_core_pub_set%"

call %functions%\check_errors.bat

goto:eof
:: =======================================================================================


:: =======================================================================================
:create_classification
:: =======================================================================================

call %functions%\classification_create_classification.bat ^
    %classification_db_name% ^
    %publicationclassification_log_folder%

goto:eof
:: =======================================================================================


:: =======================================================================================
:copy_previous_classification
:: =======================================================================================

call %functions%\run_sql_script.bat ^
    %classification_db_name% ^
    %classification_sql_src_folder%\copy_publicationclassification.sql ^
    %classification_sql_log_folder% ^
    "-v previous_classification_db_name=%previous_classification_db_name%"

goto:eof
:: =======================================================================================


:: =======================================================================================
:complement_classification
:: =======================================================================================

call %functions%\run_sql_script.bat ^
    %classification_db_name% ^
    %classification_sql_src_folder%\complement_publicationclassification.sql ^
    %classification_sql_log_folder% ^
    "-v relational_db_name=%relational_db_name%"

goto:eof
:: =======================================================================================


:: =======================================================================================
:create_labeling
:: =======================================================================================

call %functions%\run_sql_script.bat ^
    %classification_db_name% ^
    %classification_sql_src_folder%\create_input_table_publicationclassificationlabeling.sql ^
    %classification_sql_log_folder% ^
    "-v relational_db_name=%relational_db_name% classification_n_pub_titles_per_cluster=%classification_n_pub_titles_per_cluster%"

call %functions%\check_errors.bat

call %functions%\secret.bat ^
    %development_folder%\openai_api_key.txt ^
    classification_openai_api_key

call %functions%\classification_create_labeling.bat ^
    %classification_db_name% ^
    %publicationclassificationlabeling_log_folder%

goto:eof
:: =======================================================================================


:: =======================================================================================
:copy_previous_labeling
:: =======================================================================================

call %functions%\run_sql_script.bat ^
    %classification_db_name% ^
    %classification_sql_src_folder%\copy_publicationclassificationlabeling.sql ^
    %classification_sql_log_folder% ^
    "-v previous_classification_db_name=%previous_classification_db_name%"

goto:eof
:: =======================================================================================


:: =======================================================================================
:table_scripts
:: =======================================================================================

call %functions%\run_sql_folder.bat ^
    %classification_db_name% ^
    %classification_sql_src_folder%\table_scripts ^
    %classification_sql_log_folder% ^
    "-v relational_db_name=%relational_db_name%"

call %functions%\check_errors.bat

goto:eof
:: =======================================================================================


:: =======================================================================================
:create_vosviewer_maps
:: =======================================================================================

call %functions%\run_sql_folder.bat ^
    %classification_db_name% ^
    %classification_sql_src_folder%\VOSviewer ^
    %classification_sql_log_folder% ^
    "-v relational_db_name=%relational_db_name% classification_min_pub_year_core_pub_set=%classification_min_pub_year_core_pub_set% classification_max_pub_year_core_pub_set=%classification_max_pub_year_core_pub_set%"

call %functions%\classification_create_vosviewer_maps.bat ^
    %classification_db_name% ^
    %classification_data_folder% ^
    %classification_log_folder%

call %functions%\check_errors.bat

call :load_vosviewer_maps

goto:eof
:: =======================================================================================


:: =======================================================================================
:load_vosviewer_maps
:: =======================================================================================

call %functions%\classification_load_vosviewer_maps.bat ^
    %classification_db_name% ^
    %classification_data_folder% ^
    %classification_sql_log_folder% ^
    %classification_bcp_log_folder%

call %functions%\check_errors.bat

goto:eof
:: =======================================================================================


:: =======================================================================================
:validate
:: =======================================================================================

call %functions%\validate_database.bat   %classification_db_name%
call %functions%\validate_data_types.bat %classification_db_name%

goto:eof
:: =======================================================================================


:: =======================================================================================
:choose_type_of_load
:: =======================================================================================

echo Choose step(s) to run (option numbers, [space] separated)
echo Option 0: create_database
echo Option 1: create_classification
echo Option 2: copy_previous_classification
echo Option 3: complement_classification
echo Option 4: create_labeling
echo Option 5: copy_previous_labeling
echo Option 6: table_scripts
echo Option 7: create_vosviewer_maps
echo Option 8: load_vosviewer_maps_only
echo Option 9: validate

set /p type_of_load="Enter option: "

goto:eof
:: =======================================================================================


:: =======================================================================================
:execute_type_of_load
:: =======================================================================================
setlocal

set "run=0"
set "type_of_load=%type_of_load% "

if not "%type_of_load:0 =%" == "%type_of_load%" ( set "run=1" && call :create_database )
if not "%type_of_load:1 =%" == "%type_of_load%" ( set "run=1" && call :create_classification )
if not "%type_of_load:2 =%" == "%type_of_load%" ( set "run=1" && call :copy_previous_classification )
if not "%type_of_load:3 =%" == "%type_of_load%" ( set "run=1" && call :complement_classification )
if not "%type_of_load:4 =%" == "%type_of_load%" ( set "run=1" && call :create_labeling )
if not "%type_of_load:5 =%" == "%type_of_load%" ( set "run=1" && call :copy_previous_labeling )
if not "%type_of_load:6 =%" == "%type_of_load%" ( set "run=1" && call :table_scripts )
if not "%type_of_load:7 =%" == "%type_of_load%" ( set "run=1" && call :create_vosviewer_maps )
if not "%type_of_load:8 =%" == "%type_of_load%" ( set "run=1" && call :load_vosviewer_maps )
if not "%type_of_load:9 =%" == "%type_of_load%" ( set "run=1" && call :validate )

if "%run%" == "0" (
    echo No valid input
    call :choose_type_of_load
    goto :execute_type_of_load
)

endlocal
goto:eof
:: =======================================================================================
