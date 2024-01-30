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
setlocal

set db_name_choice=%~1
if not defined db_name_choice call :choose_db_name
call :set_db_name

set validation_choice=%~2
if not defined validation_choice call :choose_validation_type
call :set_validation_type

if "%validation_type%" == "row_counts" (
    call %functions%\validate_database_compare.bat %db_name%
)
if "%validation_type%" == "data_types" (
    call %functions%\validate_data_types_compare.bat %db_name%
)

endlocal
goto:eof
:: =======================================================================================


:: =======================================================================================
:choose_db_name
:: =======================================================================================
echo Choose database
echo Option  1: %authors_json_db_name%
echo Option  2: %concepts_json_db_name%
echo Option  3: %funders_json_db_name%
echo Option  4: %institutions_json_db_name%
echo Option  5: %publishers_json_db_name%
echo Option  6: %sources_json_db_name%
echo Option  7: %works_json_db_name%
echo Option  8: %relational_db_name%
echo Option  9: %text_db_name%
echo Option 10: %classification_db_name%
set /p db_name_choice="Enter option: "

goto:eof
:: =======================================================================================


:: =======================================================================================
:set_db_name
:: =======================================================================================
if "%db_name_choice%" == "1"  set db_name=%authors_json_db_name%
if "%db_name_choice%" == "2"  set db_name=%concepts_json_db_name%
if "%db_name_choice%" == "3"  set db_name=%funders_json_db_name%
if "%db_name_choice%" == "4"  set db_name=%institutions_json_db_name%
if "%db_name_choice%" == "5"  set db_name=%publishers_json_db_name%
if "%db_name_choice%" == "6"  set db_name=%sources_json_db_name%
if "%db_name_choice%" == "7"  set db_name=%works_json_db_name%
if "%db_name_choice%" == "8"  set db_name=%relational_db_name%
if "%db_name_choice%" == "9"  set db_name=%text_db_name%
if "%db_name_choice%" == "10" set db_name=%classification_db_name%
if not defined db_name (
    set db_name=%db_name_choice%
)

goto:eof
:: =======================================================================================


:: =======================================================================================
:choose_validation_type
:: =======================================================================================
echo Choose validation
echo Option  1: row_counts
echo Option  2: data_types
set /p validation_choice="Enter option: "

goto:eof
:: =======================================================================================


:: =======================================================================================
:set_validation_type
:: =======================================================================================
if "%validation_choice%" == "1" set validation_type=row_counts
if "%validation_choice%" == "2" set validation_type=data_types
if not defined validation_type (
    set validation_type=%validation_choice%
)

goto:eof
:: =======================================================================================
