@echo off

call settings.bat

:: =======================================================================================
:: Main

::: Create the relational database.

::: Load data into the relational database by running all sql scripts
::: in [src\sql\relational\].

::: Perform a row-count for all tables in the relational database
::: in [data\validation\relational_row_count_tables.csv]
:: =======================================================================================

call %functions%\create_database.bat ^
    %relational_db_name% ^
    %relational_sql_src_folder% ^
    %relational_sql_log_folder%
call %functions%\check_errors.bat

call %functions%\load_database.bat ^
    :run_all_scripts ^
    %relational_db_name% ^
    %relational_sql_src_folder% ^
    %relational_sql_log_folder% ^
    "-v previous_relational_db_name=%previous_relational_db_name% authors_json_db_name=%authors_json_db_name% concepts_json_db_name=%concepts_json_db_name% institutions_json_db_name=%institutions_json_db_name% publishers_json_db_name=%publishers_json_db_name% sources_json_db_name=%sources_json_db_name% works_json_db_name=%works_json_db_name% etl_db_name=%etl_db_name%"
call %functions%\check_errors.bat

call %functions%\validate_database.bat   %relational_db_name%
call %functions%\validate_data_types.bat %relational_db_name%

call %functions%\check_errors.bat pause
goto:eof
:: =======================================================================================
