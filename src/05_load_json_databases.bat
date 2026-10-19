@echo off

call settings.bat

:: =======================================================================================
:: Main

::: Apply page compression before loading the data into the json databases.
::: Then load data into the json databases using BCP.
::: For flows with asynchronous processing, this script spawns multiple terminal windows
::: while the main window waits for all processes to finish.
:: =======================================================================================

:: AWARDS ------------------------------------------------------------------------------

set db_filegrowth=1GB
call %functions%\create_database.bat ^
    %awards_json_db_name% ^
    %json_sql_src_folder% ^
    %json_sql_log_folder%\awards
call %functions%\check_errors.bat
set "db_filegrowth="

call %functions%\run_sql_script.bat ^
    %awards_json_db_name% ^
    %process_folder%\awards\create_tables.sql ^
    %json_sql_log_folder%\awards ^
    ""
call %functions%\check_errors.bat

call %functions%\apply_page_compression.bat ^
    %awards_json_db_name% ^
    %json_sql_log_folder%\awards

call %functions%\bcp_data.bat ^
    %awards_json_db_name% ^
    %process_folder%\awards ^
    %bcp_log_folder%\awards

call %functions%\validate_database.bat   %awards_json_db_name%
call %functions%\validate_data_types.bat %awards_json_db_name%

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


:: CONTINENTS ------------------------------------------------------------------------------

set db_filegrowth=1GB
call %functions%\create_database.bat ^
    %continents_json_db_name% ^
    %json_sql_src_folder% ^
    %json_sql_log_folder%\continents
call %functions%\check_errors.bat
set "db_filegrowth="

call %functions%\run_sql_script.bat ^
    %continents_json_db_name% ^
    %process_folder%\continents\create_tables.sql ^
    %json_sql_log_folder%\continents ^
    ""
call %functions%\check_errors.bat

call %functions%\apply_page_compression.bat ^
    %continents_json_db_name% ^
    %json_sql_log_folder%\continents

call %functions%\bcp_data.bat ^
    %continents_json_db_name% ^
    %process_folder%\continents ^
    %bcp_log_folder%\continents

call %functions%\validate_database.bat   %continents_json_db_name%
call %functions%\validate_data_types.bat %continents_json_db_name%

:: COUNTRIES ------------------------------------------------------------------------------

set db_filegrowth=1GB
call %functions%\create_database.bat ^
    %countries_json_db_name% ^
    %json_sql_src_folder% ^
    %json_sql_log_folder%\countries
call %functions%\check_errors.bat
set "db_filegrowth="

call %functions%\run_sql_script.bat ^
    %countries_json_db_name% ^
    %process_folder%\countries\create_tables.sql ^
    %json_sql_log_folder%\countries ^
    ""
call %functions%\check_errors.bat

call %functions%\apply_page_compression.bat ^
    %countries_json_db_name% ^
    %json_sql_log_folder%\countries

call %functions%\bcp_data.bat ^
    %countries_json_db_name% ^
    %process_folder%\countries ^
    %bcp_log_folder%\countries

call %functions%\validate_database.bat   %countries_json_db_name%
call %functions%\validate_data_types.bat %countries_json_db_name%

:: DOMAINS ------------------------------------------------------------------------------

set db_filegrowth=1GB
call %functions%\create_database.bat ^
    %domains_json_db_name% ^
    %json_sql_src_folder% ^
    %json_sql_log_folder%\domains
call %functions%\check_errors.bat
set "db_filegrowth="

call %functions%\run_sql_script.bat ^
    %domains_json_db_name% ^
    %process_folder%\domains\create_tables.sql ^
    %json_sql_log_folder%\domains ^
    ""
call %functions%\check_errors.bat

call %functions%\apply_page_compression.bat ^
    %domains_json_db_name% ^
    %json_sql_log_folder%\domains

call %functions%\bcp_data.bat ^
    %domains_json_db_name% ^
    %process_folder%\domains ^
    %bcp_log_folder%\domains

call %functions%\validate_database.bat   %domains_json_db_name%
call %functions%\validate_data_types.bat %domains_json_db_name%

:: FIELDS ------------------------------------------------------------------------------

set db_filegrowth=1GB
call %functions%\create_database.bat ^
    %fields_json_db_name% ^
    %json_sql_src_folder% ^
    %json_sql_log_folder%\fields
call %functions%\check_errors.bat
set "db_filegrowth="

call %functions%\run_sql_script.bat ^
    %fields_json_db_name% ^
    %process_folder%\fields\create_tables.sql ^
    %json_sql_log_folder%\fields ^
    ""
call %functions%\check_errors.bat

call %functions%\apply_page_compression.bat ^
    %fields_json_db_name% ^
    %json_sql_log_folder%\fields

call %functions%\bcp_data.bat ^
    %fields_json_db_name% ^
    %process_folder%\fields ^
    %bcp_log_folder%\fields

call %functions%\validate_database.bat   %fields_json_db_name%
call %functions%\validate_data_types.bat %fields_json_db_name%

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

:: INSTITUTION-TYPES ------------------------------------------------------------------------------

set db_filegrowth=1GB
call %functions%\create_database.bat ^
    %institutiontypes_json_db_name% ^
    %json_sql_src_folder% ^
    %json_sql_log_folder%\institution-types
call %functions%\check_errors.bat
set "db_filegrowth="

call %functions%\run_sql_script.bat ^
    %institutiontypes_json_db_name% ^
    %process_folder%\institution-types\create_tables.sql ^
    %json_sql_log_folder%\institution-types ^
    ""
call %functions%\check_errors.bat

call %functions%\apply_page_compression.bat ^
    %institutiontypes_json_db_name% ^
    %json_sql_log_folder%\institution-types

call %functions%\bcp_data.bat ^
    %institutiontypes_json_db_name% ^
    %process_folder%\institution-types ^
    %bcp_log_folder%\institution-types

call %functions%\validate_database.bat   %institutiontypes_json_db_name%
call %functions%\validate_data_types.bat %institutiontypes_json_db_name%

:: KEYWORDS ------------------------------------------------------------------------------

set db_filegrowth=1GB
call %functions%\create_database.bat ^
    %keywords_json_db_name% ^
    %json_sql_src_folder% ^
    %json_sql_log_folder%\keywords
call %functions%\check_errors.bat
set "db_filegrowth="

call %functions%\run_sql_script.bat ^
    %keywords_json_db_name% ^
    %process_folder%\keywords\create_tables.sql ^
    %json_sql_log_folder%\keywords ^
    ""
call %functions%\check_errors.bat

call %functions%\apply_page_compression.bat ^
    %keywords_json_db_name% ^
    %json_sql_log_folder%\keywords

call %functions%\bcp_data.bat ^
    %keywords_json_db_name% ^
    %process_folder%\keywords ^
    %bcp_log_folder%\keywords

call %functions%\validate_database.bat   %keywords_json_db_name%
call %functions%\validate_data_types.bat %keywords_json_db_name%

:: LANGUAGES ------------------------------------------------------------------------------

set db_filegrowth=1GB
call %functions%\create_database.bat ^
    %languages_json_db_name% ^
    %json_sql_src_folder% ^
    %json_sql_log_folder%\languages
call %functions%\check_errors.bat
set "db_filegrowth="

call %functions%\run_sql_script.bat ^
    %languages_json_db_name% ^
    %process_folder%\languages\create_tables.sql ^
    %json_sql_log_folder%\languages ^
    ""
call %functions%\check_errors.bat

call %functions%\apply_page_compression.bat ^
    %languages_json_db_name% ^
    %json_sql_log_folder%\languages

call %functions%\bcp_data.bat ^
    %languages_json_db_name% ^
    %process_folder%\languages ^
    %bcp_log_folder%\languages

call %functions%\validate_database.bat   %languages_json_db_name%
call %functions%\validate_data_types.bat %languages_json_db_name%

:: LICENSES ------------------------------------------------------------------------------

set db_filegrowth=1GB
call %functions%\create_database.bat ^
    %licenses_json_db_name% ^
    %json_sql_src_folder% ^
    %json_sql_log_folder%\licenses
call %functions%\check_errors.bat
set "db_filegrowth="

call %functions%\run_sql_script.bat ^
    %licenses_json_db_name% ^
    %process_folder%\licenses\create_tables.sql ^
    %json_sql_log_folder%\licenses ^
    ""
call %functions%\check_errors.bat

call %functions%\apply_page_compression.bat ^
    %licenses_json_db_name% ^
    %json_sql_log_folder%\licenses

call %functions%\bcp_data.bat ^
    %licenses_json_db_name% ^
    %process_folder%\licenses ^
    %bcp_log_folder%\licenses

call %functions%\validate_database.bat   %licenses_json_db_name%
call %functions%\validate_data_types.bat %licenses_json_db_name%

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

:: SDGS ------------------------------------------------------------------------------

set db_filegrowth=1GB
call %functions%\create_database.bat ^
    %sdgs_json_db_name% ^
    %json_sql_src_folder% ^
    %json_sql_log_folder%\sdgs
call %functions%\check_errors.bat
set "db_filegrowth="

call %functions%\run_sql_script.bat ^
    %sdgs_json_db_name% ^
    %process_folder%\sdgs\create_tables.sql ^
    %json_sql_log_folder%\sdgs ^
    ""
call %functions%\check_errors.bat

call %functions%\apply_page_compression.bat ^
    %sdgs_json_db_name% ^
    %json_sql_log_folder%\sdgs

call %functions%\bcp_data.bat ^
    %sdgs_json_db_name% ^
    %process_folder%\sdgs ^
    %bcp_log_folder%\sdgs

call %functions%\validate_database.bat   %sdgs_json_db_name%
call %functions%\validate_data_types.bat %sdgs_json_db_name%

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

:: SOURCE-TYPES ------------------------------------------------------------------------------

set db_filegrowth=1GB
call %functions%\create_database.bat ^
    %sourcetypes_json_db_name% ^
    %json_sql_src_folder% ^
    %json_sql_log_folder%\source-types
call %functions%\check_errors.bat
set "db_filegrowth="

call %functions%\run_sql_script.bat ^
    %sourcetypes_json_db_name% ^
    %process_folder%\source-types\create_tables.sql ^
    %json_sql_log_folder%\source-types ^
    ""
call %functions%\check_errors.bat

call %functions%\apply_page_compression.bat ^
    %sourcetypes_json_db_name% ^
    %json_sql_log_folder%\source-types

call %functions%\bcp_data.bat ^
    %sourcetypes_json_db_name% ^
    %process_folder%\source-types ^
    %bcp_log_folder%\source-types

call %functions%\validate_database.bat   %sourcetypes_json_db_name%
call %functions%\validate_data_types.bat %sourcetypes_json_db_name%

:: SUBFIELDS ------------------------------------------------------------------------------

set db_filegrowth=1GB
call %functions%\create_database.bat ^
    %subfields_json_db_name% ^
    %json_sql_src_folder% ^
    %json_sql_log_folder%\subfields
call %functions%\check_errors.bat
set "db_filegrowth="

call %functions%\run_sql_script.bat ^
    %subfields_json_db_name% ^
    %process_folder%\subfields\create_tables.sql ^
    %json_sql_log_folder%\subfields ^
    ""
call %functions%\check_errors.bat

call %functions%\apply_page_compression.bat ^
    %subfields_json_db_name% ^
    %json_sql_log_folder%\subfields

call %functions%\bcp_data.bat ^
    %subfields_json_db_name% ^
    %process_folder%\subfields ^
    %bcp_log_folder%\subfields

call %functions%\validate_database.bat   %subfields_json_db_name%
call %functions%\validate_data_types.bat %subfields_json_db_name%

:: TOPICS ------------------------------------------------------------------------------

set db_filegrowth=1GB
call %functions%\create_database.bat ^
    %topics_json_db_name% ^
    %json_sql_src_folder% ^
    %json_sql_log_folder%\topics
call %functions%\check_errors.bat
set "db_filegrowth="

call %functions%\run_sql_script.bat ^
    %topics_json_db_name% ^
    %process_folder%\topics\create_tables.sql ^
    %json_sql_log_folder%\topics ^
    ""
call %functions%\check_errors.bat

call %functions%\apply_page_compression.bat ^
    %topics_json_db_name% ^
    %json_sql_log_folder%\topics

call %functions%\bcp_data.bat ^
    %topics_json_db_name% ^
    %process_folder%\topics ^
    %bcp_log_folder%\topics

call %functions%\validate_database.bat   %topics_json_db_name%
call %functions%\validate_data_types.bat %topics_json_db_name%

:: WORK-TYPES ------------------------------------------------------------------------------

set db_filegrowth=1GB
call %functions%\create_database.bat ^
    %worktypes_json_db_name% ^
    %json_sql_src_folder% ^
    %json_sql_log_folder%\work-types
call %functions%\check_errors.bat
set "db_filegrowth="

call %functions%\run_sql_script.bat ^
    %worktypes_json_db_name% ^
    %process_folder%\work-types\create_tables.sql ^
    %json_sql_log_folder%\work-types ^
    ""
call %functions%\check_errors.bat

call %functions%\apply_page_compression.bat ^
    %worktypes_json_db_name% ^
    %json_sql_log_folder%\work-types

call %functions%\bcp_data.bat ^
    %worktypes_json_db_name% ^
    %process_folder%\work-types ^
    %bcp_log_folder%\work-types

call %functions%\validate_database.bat   %worktypes_json_db_name%
call %functions%\validate_data_types.bat %worktypes_json_db_name%

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
