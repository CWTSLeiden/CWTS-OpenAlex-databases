@echo off

call settings.bat

:: =======================================================================================
:: Main

::: Create the text database.

::: Load data into the text database by running all sql scripts
::: in [src\sql\text\].

::: Perform a row-count for all tables in the text database
::: in [data\validation\text_row_count_tables.csv]
:: =======================================================================================

call %functions%\create_database.bat ^
    %text_db_name% ^
    %text_sql_src_folder% ^
    %text_sql_log_folder%
call %functions%\check_errors.bat

call %functions%\load_database.bat ^
    :run_all_scripts ^
    %text_db_name% ^
    %text_sql_src_folder% ^
    %text_sql_log_folder% ^
    "-v relational_db_name=%relational_db_name%"
call %functions%\check_errors.bat

call %functions%\validate_database.bat   %text_db_name%
call %functions%\validate_data_types.bat %text_db_name%

call %functions%\notify.bat "%text_db_name%" "%~n0" ""

call %functions%\check_errors.bat pause
goto:eof
:: =======================================================================================
