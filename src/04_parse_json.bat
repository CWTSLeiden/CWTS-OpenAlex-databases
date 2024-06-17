@echo off

call settings.bat

:: =======================================================================================
:: Main

::: Parse the raw json files in [data\json_files\extract\%db_name%\]
::: to generate scripts for create_tables, remove_tables, create_primary_keys and bcpdata
::: in [process\%db_name%\] along with .xxx files used for processing.
::: The scripts are copied to [data\generated_sql_scripts\%db_name%\] after parsing.
:: =======================================================================================

call %functions%\json_parse_data.bat ^
    %concepts_json_db_name% ^
    openalexconcepts ^
    %process_folder%\concepts ^
    %extract_json_files_data_folder%\concepts ^
    %generated_sql_scripts_data_folder%\concepts ^
    %json_parser_log_folder%\concepts ^
    erase_previous

call %functions%\json_parse_data.bat ^
    %domains_json_db_name% ^
    openalexdomains ^
    %process_folder%\domains ^
    %extract_json_files_data_folder%\domains ^
    %generated_sql_scripts_data_folder%\domains ^
    %json_parser_log_folder%\domains ^
    erase_previous

call %functions%\json_parse_data.bat ^
    %fields_json_db_name% ^
    openalexfields ^
    %process_folder%\fields ^
    %extract_json_files_data_folder%\fields ^
    %generated_sql_scripts_data_folder%\fields ^
    %json_parser_log_folder%\fields ^
    erase_previous

call %functions%\json_parse_data.bat ^
    %funders_json_db_name% ^
    openalexfunders ^
    %process_folder%\funders ^
    %extract_json_files_data_folder%\funders ^
    %generated_sql_scripts_data_folder%\funders ^
    %json_parser_log_folder%\funders ^
    erase_previous

call %functions%\json_parse_data.bat ^
    %institutions_json_db_name% ^
    openalexinstitutions ^
    %process_folder%\institutions ^
    %extract_json_files_data_folder%\institutions ^
    %generated_sql_scripts_data_folder%\institutions ^
    %json_parser_log_folder%\institutions ^
    erase_previous

call %functions%\json_parse_data.bat ^
    %publishers_json_db_name% ^
    openalexpublishers ^
    %process_folder%\publishers ^
    %extract_json_files_data_folder%\publishers ^
    %generated_sql_scripts_data_folder%\publishers ^
    %json_parser_log_folder%\publishers ^
    erase_previous

call %functions%\json_parse_data.bat ^
    %sources_json_db_name% ^
    openalexsources ^
    %process_folder%\sources ^
    %extract_json_files_data_folder%\sources ^
    %generated_sql_scripts_data_folder%\sources ^
    %json_parser_log_folder%\sources ^
    erase_previous

call %functions%\json_parse_data.bat ^
    %subfields_json_db_name% ^
    openalexsubfields ^
    %process_folder%\subfields ^
    %extract_json_files_data_folder%\subfields ^
    %generated_sql_scripts_data_folder%\subfields ^
    %json_parser_log_folder%\subfields ^
    erase_previous

call %functions%\json_parse_data.bat ^
    %topics_json_db_name% ^
    openalextopics ^
    %process_folder%\topics ^
    %extract_json_files_data_folder%\topics ^
    %generated_sql_scripts_data_folder%\topics ^
    %json_parser_log_folder%\topics ^
    erase_previous

for /L %%i in (1,1,%number_of_processes%) do (
    start /min %functions%\json_parse_data.bat ^
        %authors_json_db_name% ^
        openalexauthors ^
        %process_folder%\authors\%%i ^
        %extract_json_files_data_folder%\authors\%%i ^
        %generated_sql_scripts_data_folder%\authors\%%i ^
        %json_parser_log_folder%\authors\%%i ^
        erase_previous
)
call %functions%\wait.bat :receive %functions%\json_parse_data.bat %number_of_processes%

for /L %%i in (1,1,%number_of_processes%) do (
    start /min %functions%\json_parse_data.bat ^
        %works_json_db_name% ^
        openalexworks ^
        %process_folder%\works\%%i ^
        %extract_json_files_data_folder%\works\%%i ^
        %generated_sql_scripts_data_folder%\works\%%i ^
        %json_parser_log_folder%\works\%%i ^
        erase_previous
)
call %functions%\wait.bat :receive %functions%\json_parse_data.bat %number_of_processes%

call %functions%\notify.bat "%json_db_name%" "%~n0" ""
call %functions%\check_errors.bat skip_pause
pause
goto:eof
:: =======================================================================================
