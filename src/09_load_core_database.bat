@echo off

call settings.bat

:: =======================================================================================
:: Main

::: Create the core database.
::: Load data into the core database by running all SQL scripts in the folder
::: [src\sql\core\].
::: Perform a row-count for all tables in the core database and store the
::: results in the folder [data\validation].
:: =======================================================================================

call %functions%\create_database.bat ^
    %core_db_name% ^
    %core_sql_src_folder% ^
    %core_sql_log_folder%
call %functions%\check_errors.bat

call %functions%\run_sql_folder.bat ^
    %core_db_name% ^
    %core_sql_src_folder%\table_scripts ^
    %core_sql_log_folder% ^
    "-v relational_db_name=%relational_db_name% core_min_pub_year_core_pubs=%core_min_pub_year_core_pubs%"
call %functions%\check_errors.bat

call %functions%\validate_database.bat   %core_db_name%
call %functions%\validate_data_types.bat %core_db_name%

call %functions%\check_errors.bat pause
goto:eof
:: =======================================================================================
