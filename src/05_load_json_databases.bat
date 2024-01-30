@echo off

call settings.bat

:: =======================================================================================
:: Main

::: Apply page compression before loading the data into the json databases.
::: Then load data into the json databases using BCP.
::: For flows with asynchronous processing, this script spawns multiple terminal windows
::: while the main window waits for all processes to finish.
:: =======================================================================================

:: CONCEPTS ------------------------------------------------------------------------------

set db_filegrowth=1GB
call %functions%\create_database.bat ^
    %concepts_json_db_name% ^
    %json_sql_src_folder% ^
    %json_sql_log_folder%\concepts
call %functions%\check_errors.bat
set "db_filegrowth="

call %functions%\run_sql_script.bat ^
    %concepts_json_db_name% ^
    %process_folder%\concepts\create_tables.sql ^
    %json_sql_log_folder%\concepts ^
    ""
call %functions%\check_errors.bat

call %functions%\apply_page_compression.bat ^
    %concepts_json_db_name% ^
    %json_sql_log_folder%\concepts

call %functions%\bcp_data.bat ^
    %concepts_json_db_name% ^
    %process_folder%\concepts ^
    %bcp_log_folder%\concepts

call %functions%\validate_database.bat   %concepts_json_db_name%
call %functions%\validate_data_types.bat %concepts_json_db_name%

:: FUNDERS ------------------------------------------------------------------------------

set db_filegrowth=1GB
call %functions%\create_database.bat ^
    %funders_json_db_name% ^
    %json_sql_src_folder% ^
    %json_sql_log_folder%\funders
call %functions%\check_errors.bat
set "db_filegrowth="

call %functions%\run_sql_script.bat ^
    %funders_json_db_name% ^
    %process_folder%\funders\create_tables.sql ^
    %json_sql_log_folder%\funders ^
    ""
call %functions%\check_errors.bat

call %functions%\apply_page_compression.bat ^
    %funders_json_db_name% ^
    %json_sql_log_folder%\funders

call %functions%\bcp_data.bat ^
    %funders_json_db_name% ^
    %process_folder%\funders ^
    %bcp_log_folder%\funders

call %functions%\validate_database.bat   %funders_json_db_name%
call %functions%\validate_data_types.bat %funders_json_db_name%

:: PUBLISHERS ------------------------------------------------------------------------------

set db_filegrowth=1GB
call %functions%\create_database.bat ^
    %publishers_json_db_name% ^
    %json_sql_src_folder% ^
    %json_sql_log_folder%\publishers
call %functions%\check_errors.bat
set "db_filegrowth="

call %functions%\run_sql_script.bat ^
    %publishers_json_db_name% ^
    %process_folder%\publishers\create_tables.sql ^
    %json_sql_log_folder%\publishers ^
    ""
call %functions%\check_errors.bat

call %functions%\apply_page_compression.bat ^
    %publishers_json_db_name% ^
    %json_sql_log_folder%\publishers

call %functions%\bcp_data.bat ^
    %publishers_json_db_name% ^
    %process_folder%\publishers ^
    %bcp_log_folder%\publishers

call %functions%\validate_database.bat   %publishers_json_db_name%
call %functions%\validate_data_types.bat %publishers_json_db_name%

:: INSTITUTIONS ------------------------------------------------------------------------------

set db_filegrowth=1GB
call %functions%\create_database.bat ^
    %institutions_json_db_name% ^
    %json_sql_src_folder% ^
    %json_sql_log_folder%\institutions
call %functions%\check_errors.bat
set "db_filegrowth="

call %functions%\run_sql_script.bat ^
    %institutions_json_db_name% ^
    %process_folder%\institutions\create_tables.sql ^
    %json_sql_log_folder%\institutions ^
    ""
call %functions%\check_errors.bat

call %functions%\apply_page_compression.bat ^
    %institutions_json_db_name% ^
    %json_sql_log_folder%\institutions

call %functions%\bcp_data.bat ^
    %institutions_json_db_name% ^
    %process_folder%\institutions ^
    %bcp_log_folder%\institutions

call %functions%\validate_database.bat   %institutions_json_db_name%
call %functions%\validate_data_types.bat %institutions_json_db_name%

:: SOURCES ------------------------------------------------------------------------------

set db_filegrowth=1GB
call %functions%\create_database.bat ^
    %sources_json_db_name% ^
    %json_sql_src_folder% ^
    %json_sql_log_folder%\sources
call %functions%\check_errors.bat
set "db_filegrowth="

call %functions%\run_sql_script.bat ^
    %sources_json_db_name% ^
    %process_folder%\sources\create_tables.sql ^
    %json_sql_log_folder%\sources ^
    ""
call %functions%\check_errors.bat

call %functions%\apply_page_compression.bat ^
    %sources_json_db_name% ^
    %json_sql_log_folder%\sources

call %functions%\bcp_data.bat ^
    %sources_json_db_name% ^
    %process_folder%\sources ^
    %bcp_log_folder%\sources

call %functions%\validate_database.bat   %sources_json_db_name%
call %functions%\validate_data_types.bat %sources_json_db_name%

:: AUTHORS ------------------------------------------------------------------------------

call %functions%\create_database.bat ^
    %authors_json_db_name% ^
    %json_sql_src_folder% ^
    %json_sql_log_folder%\authors
call %functions%\check_errors.bat

call %functions%\unify_create_tables.bat ^
    %authors_json_db_name% ^
    %process_folder%\authors ^
    %json_sql_log_folder%\authors
call %functions%\check_errors.bat

call %functions%\apply_page_compression.bat ^
    %authors_json_db_name% ^
    %json_sql_log_folder%\authors

for /L %%i in (1,1,%number_of_processes%) do (
    start /min %functions%\bcp_data.bat ^
        %authors_json_db_name% ^
        %process_folder%\authors\%%i ^
        %bcp_log_folder%\authors\%%i
)
call %functions%\wait.bat :receive %functions%\bcp_data.bat %number_of_processes%

call %functions%\validate_database.bat   %authors_json_db_name%
call %functions%\validate_data_types.bat %authors_json_db_name%

:: WORKS ------------------------------------------------------------------------------

call %functions%\create_database.bat ^
    %works_json_db_name% ^
    %json_sql_src_folder% ^
    %json_sql_log_folder%\works
call %functions%\check_errors.bat

call %functions%\unify_create_tables.bat ^
    %works_json_db_name% ^
    %process_folder%\works ^
    %json_sql_log_folder%\works
call %functions%\check_errors.bat

call %functions%\apply_page_compression.bat ^
    %works_json_db_name% ^
    %json_sql_log_folder%\works

for /L %%i in (1,1,%number_of_processes%) do (
    start /min %functions%\bcp_data.bat ^
        %works_json_db_name% ^
        %process_folder%\works\%%i ^
        %bcp_log_folder%\works\%%i
)
call %functions%\wait.bat :receive %functions%\bcp_data.bat %number_of_processes%

call %functions%\validate_database.bat   %works_json_db_name%
call %functions%\validate_data_types.bat %works_json_db_name%

:: ---------------------------------------------------------------------------------------

call %functions%\notify.bat "%json_db_name%" "%~n0" ""
call %functions%\check_errors.bat pause
goto:eof
:: =======================================================================================
