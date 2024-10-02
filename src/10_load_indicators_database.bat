@echo off

call settings.bat

:: =======================================================================================
:: Main

::: Create the indicators database.
::: Load data into the indicators database by running the SQL scripts in the folder
::: [src\sql\indicators\].
::: Perform a row-count for all tables in the indicators database and store the
::: results in the folder [data\validation].
:: =======================================================================================

call %functions%\create_database.bat ^
    %indicators_db_name% ^
    %indicators_sql_src_folder% ^
    %indicators_sql_log_folder%
call %functions%\check_errors.bat

call %functions%\run_sql_script.bat ^
    %indicators_db_name% ^
    %indicators_sql_src_folder%\create_sp_schema.sql ^
    %indicators_sql_log_folder% ^
    ""
call %functions%\check_errors.bat

call %functions%\run_sql_script.bat ^
    %indicators_db_name% ^
    %indicators_sql_src_folder%\create_func_constants.sql ^
    %indicators_sql_log_folder% ^
    "-v indicators_max_pub_year=%indicators_max_pub_year%"
call %functions%\check_errors.bat

call %functions%\run_sql_folder.bat ^
    %indicators_db_name% ^
    %indicators_sql_src_folder%\table_scripts ^
    %indicators_sql_log_folder% ^
    "-v relational_db_name=%relational_db_name% core_db_name=%core_db_name% classification_db_name=%classification_db_name% indicators_min_pub_year=%indicators_min_pub_year%"
call %functions%\check_errors.bat

call %functions%\run_sql_folder.bat ^
    %indicators_db_name% ^
    %indicators_sql_src_folder%\stored_procedures ^
    %indicators_sql_log_folder% ^
    "-v indicators_min_pub_year=%indicators_min_pub_year%"
call %functions%\check_errors.bat

call %functions%\validate_database.bat   %indicators_db_name%
call %functions%\validate_data_types.bat %indicators_db_name%

call %functions%\check_errors.bat pause
goto:eof
:: =======================================================================================
