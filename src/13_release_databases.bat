@echo off

call settings.bat

:: =======================================================================================
:: Main

::: Prompt the user to choose one or more databases to finalize.
::: Databases are finalized in numbered order
:::   if the user selects [3 1 2], the order will still be [1 2 3]
::: The choice can also be passed as an argument to the script
:::   use quotes in case of multiple choices ("1 2 3")

::: For each of the databases the following actions are performed if appropriate
:::   - Developer access is revoked (revoke_developer_access.sql)
:::   - CWTS group access is granted
:::   - Addittional access is granted (grant_access.sql)
:::   - File limits are set on the database to prevent further growth
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

echo Choose databases to release (option numbers, <space> separated)
echo Option 0: all
echo Option 1: %authors_json_db_name%
echo           %concepts_json_db_name%
echo           %funders_json_db_name%
echo           %institutions_json_db_name%
echo           %publishers_json_db_name%
echo           %sources_json_db_name%
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
:execute_type_of_load
:: =======================================================================================
setlocal

set "run=0"
set "type_of_load=%type_of_load% "

if not "%type_of_load:1 =%" == "%type_of_load%" ( set "run=1" && call :release_json_databases )
if not "%type_of_load:2 =%" == "%type_of_load%" ( set "run=1" && call :release_relational_database )
if not "%type_of_load:3 =%" == "%type_of_load%" ( set "run=1" && call :release_text_database )
if not "%type_of_load:4 =%" == "%type_of_load%" ( set "run=1" && call :release_classification_database )
if not "%type_of_load:5 =%" == "%type_of_load%" ( set "run=1" && call :release_core_database )
if not "%type_of_load:6 =%" == "%type_of_load%" ( set "run=1" && call :release_indicators_database )

if "%run%" == "0" (
    echo No valid input
    call :choose_type_of_load
    goto :execute_type_of_load
)

call %functions%\check_errors.bat pause
endlocal
goto:eof
:: =======================================================================================

:: =======================================================================================
:release_json_databases
:: =======================================================================================

call %functions%\set_database_file_limits.bat ^
    %authors_json_db_name% ^
    %json_sql_log_folder%\authors

call %functions%\set_database_file_limits.bat ^
    %concepts_json_db_name% ^
    %json_sql_log_folder%\concepts

call %functions%\set_database_file_limits.bat ^
    %funders_json_db_name% ^
    %json_sql_log_folder%\funders

call %functions%\set_database_file_limits.bat ^
    %institutions_json_db_name% ^
    %json_sql_log_folder%\institutions

call %functions%\set_database_file_limits.bat ^
    %publishers_json_db_name% ^
    %json_sql_log_folder%\publishers

call %functions%\set_database_file_limits.bat ^
    %sources_json_db_name% ^
    %json_sql_log_folder%\sources

call %functions%\set_database_file_limits.bat ^
    %works_json_db_name% ^
    %json_sql_log_folder%\works

goto:eof
:: =======================================================================================

:: =======================================================================================
:release_relational_database
:: =======================================================================================

call %functions%\grant_access_cwts_group.bat ^
    %relational_db_name% ^
    %relational_sql_log_folder%

call %functions%\run_sql_script.bat ^
    %relational_db_name% ^
    %relational_sql_src_folder%\grant_access.sql ^
    %relational_sql_log_folder% ^
    "-v sql_cwts_group=%sql_cwts_group%"

call %functions%\set_database_file_limits.bat ^
    %relational_db_name% ^
    %relational_sql_log_folder%

goto:eof
:: =======================================================================================

:: =======================================================================================
:release_text_database
:: =======================================================================================

call %functions%\grant_access_cwts_group.bat ^
    %text_db_name% ^
    %text_sql_log_folder%

call %functions%\set_database_file_limits.bat ^
    %text_db_name% ^
    %text_sql_log_folder%

goto:eof
:: =======================================================================================


:: =======================================================================================
:release_classification_database
:: =======================================================================================

call %functions%\run_sql_script.bat ^
    %classification_db_name% ^
    %classification_sql_src_folder%\grant_access.sql ^
    %classification_sql_log_folder% ^
    "-v sql_cwts_group=%sql_cwts_group%"

call %functions%\set_database_file_limits.bat ^
    %classification_db_name% ^
    %classification_sql_log_folder%

goto:eof
:: =======================================================================================


:: =======================================================================================
:release_core_database
:: =======================================================================================

call %functions%\grant_access_cwts_group.bat ^
    %core_db_name% ^
    %core_sql_log_folder%

call %functions%\set_database_file_limits.bat ^
    %core_db_name% ^
    %core_sql_log_folder%

goto:eof
:: =======================================================================================


:: =======================================================================================
:release_indicators_database
:: =======================================================================================

call %functions%\run_sql_script.bat ^
    %indicators_db_name% ^
    %indicators_sql_src_folder%\grant_access.sql ^
    %indicators_sql_log_folder% ^
    "-v sql_cwts_group=%sql_cwts_group%"

call %functions%\set_database_file_limits.bat ^
    %indicators_db_name% ^
    %indicators_sql_log_folder%

goto:eof
:: =======================================================================================
