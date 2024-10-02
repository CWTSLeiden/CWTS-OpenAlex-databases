@echo off

call settings.bat

:: =======================================================================================
:: Main

::: Prompt the user to choose one or more databases to shrink.
::: Databases are shrinked in numbered order
:::   if the user selects [3 1 2], the order will still be [1 2 3]
::: The choice can also be passed as an argument to the script
:::   use quotes in case of multiple choices ("1 2 3")
:: =======================================================================================

set type_of_load=%~1
if not defined type_of_load call :choose_type_of_load
call :execute_type_of_load

call %functions%\check_errors.bat pause
goto:eof
:: =======================================================================================


:: =======================================================================================
:choose_type_of_load
:: =======================================================================================

echo Choose databases to shrink (names or numbers [space] separated)
echo Option 0: all
echo Option 1: %authors_json_db_name%
echo           %concepts_json_db_name%
echo           %domains_json_db_name%
echo           %fields_json_db_name%
echo           %funders_json_db_name%
echo           %institutions_json_db_name%
echo           %publishers_json_db_name%
echo           %sources_json_db_name%
echo           %subfields_json_db_name%
echo           %topics_json_db_name%
echo           %works_json_db_name%
echo Option 2: %relational_db_name%
echo Option 3: %text_db_name%
echo Option 4: %classification_db_name%
echo Option 5: %core_db_name%
echo Option 6: %indicators_db_name%

set /p type_of_load="Enter option: "

if "%type_of_load%" == "0" set "type_of_load=1 2 3 4 5 6 7 8 9"
if "%type_of_load%" == "all" set "type_of_load=1 2 3 4 5 6 7 8 9"

goto:eof
:: =======================================================================================


:: =======================================================================================
:execute_type_of_load
:: =======================================================================================
setlocal

set "run=0"
set "type_of_load=%type_of_load% "

if not "%type_of_load:1 =%" == "%type_of_load%" ( set "run=1" && call :shrink_json_databases )
if not "%type_of_load:2 =%" == "%type_of_load%" ( set "run=1" && call :shrink_relational_database )
if not "%type_of_load:3 =%" == "%type_of_load%" ( set "run=1" && call :shrink_text_database )
if not "%type_of_load:4 =%" == "%type_of_load%" ( set "run=1" && call :shrink_classification_database )
if not "%type_of_load:5 =%" == "%type_of_load%" ( set "run=1" && call :shrink_core_database )
if not "%type_of_load:6 =%" == "%type_of_load%" ( set "run=1" && call :shrink_indicators_database )

if "%run%" == "0" (
    echo No valid input
    call :choose_type_of_load
    goto :execute_type_of_load
)

endlocal
goto:eof
:: =======================================================================================


:: =======================================================================================
:shrink_json_databases
:: =======================================================================================

call %functions%\shrink_database.bat ^
    %authors_json_db_name% ^
    %json_sql_log_folder%\authors

call %functions%\shrink_database.bat ^
    %concepts_json_db_name% ^
    %json_sql_log_folder%\concepts

call %functions%\shrink_database.bat ^
    %domains_json_db_name% ^
    %json_sql_log_folder%\domains

call %functions%\shrink_database.bat ^
    %fields_json_db_name% ^
    %json_sql_log_folder%\fields

call %functions%\shrink_database.bat ^
    %funders_json_db_name% ^
    %json_sql_log_folder%\funders

call %functions%\shrink_database.bat ^
    %institutions_json_db_name% ^
    %json_sql_log_folder%\institutions

call %functions%\shrink_database.bat ^
    %publishers_json_db_name% ^
    %json_sql_log_folder%\publishers

call %functions%\shrink_database.bat ^
    %sources_json_db_name% ^
    %json_sql_log_folder%\sources

call %functions%\shrink_database.bat ^
    %subfields_json_db_name% ^
    %json_sql_log_folder%\subfields

call %functions%\shrink_database.bat ^
    %topics_json_db_name% ^
    %json_sql_log_folder%\topics

call %functions%\shrink_database.bat ^
    %works_json_db_name% ^
    %json_sql_log_folder%\works

call %functions%\notify.bat "%json_db_name%" "%~n0" ""
goto:eof
:: =======================================================================================


:: =======================================================================================
:shrink_relational_database
:: =======================================================================================

call %functions%\run_sql_script.bat ^
    %relational_db_name% ^
    %relational_sql_src_folder%\remove_help_tables.sql ^
    %relational_sql_log_folder% ^
    ""

call %functions%\shrink_database.bat ^
    %relational_db_name% ^
    %relational_sql_log_folder%

call %functions%\notify.bat "%relational_db_name%" "%~n0" ""
goto:eof
:: =======================================================================================


:: =======================================================================================
:shrink_text_database
:: =======================================================================================

call %functions%\shrink_database.bat ^
    %text_db_name% ^
    %text_sql_log_folder%

call %functions%\notify.bat "%text_db_name%" "%~n0" ""
goto:eof
:: =======================================================================================


:: =======================================================================================
:shrink_classification_database
:: =======================================================================================

call %functions%\shrink_database.bat ^
    %classification_db_name% ^
    %classification_sql_log_folder%

call %functions%\notify.bat "%classification_db_name%" "%~n0" ""
goto:eof
:: =======================================================================================


:: =======================================================================================
:shrink_core_database
:: =======================================================================================

call %functions%\shrink_database.bat ^
    %core_db_name% ^
    %core_sql_log_folder%

call %functions%\notify.bat "%core_db_name%" "%~n0" ""
goto:eof
:: =======================================================================================


:: =======================================================================================
:shrink_indicators_database
:: =======================================================================================

call %functions%\shrink_database.bat ^
    %indicators_db_name% ^
    %indicators_sql_log_folder%

call %functions%\notify.bat "%indicators_db_name%" "%~n0" ""
goto:eof
:: =======================================================================================
