@echo off

call settings.bat

:: =======================================================================================
:: Main

::: 1. Split archives from subfolders with many files
::: 2. Extract all archives
:: =======================================================================================

call %functions%\split_process_files.bat ^
    %download_json_files_data_folder%\data\authors ^
    %process_json_files_data_folder%\authors ^
    %number_of_processes% ^
    gz ^
    include_parent_directory ^
    size

call %functions%\split_process_files.bat ^
    %download_json_files_data_folder%\data\works ^
    %process_json_files_data_folder%\works ^
    %number_of_processes% ^
    gz ^
    include_parent_directory ^
    size

call %functions%\check_errors.bat

:: ---------------------------------------------------------------------------------------

call %functions%\unzip_folder.bat ^
    %download_json_files_data_folder%\data\awards "gz" ^
    %extract_json_files_data_folder%\awards ^
    %zip_log_folder%\awards ^
    flatten_folder_structure

call %functions%\unzip_folder.bat ^
    %download_json_files_data_folder%\data\concepts "gz" ^
    %extract_json_files_data_folder%\concepts ^
    %zip_log_folder%\concepts ^
    flatten_folder_structure

call %functions%\unzip_folder.bat ^
    %download_json_files_data_folder%\data\continents "gz" ^
    %extract_json_files_data_folder%\continents ^
    %zip_log_folder%\continents ^
    flatten_folder_structure

call %functions%\unzip_folder.bat ^
    %download_json_files_data_folder%\data\countries "gz" ^
    %extract_json_files_data_folder%\countries ^
    %zip_log_folder%\countries ^
    flatten_folder_structure

call %functions%\unzip_folder.bat ^
    %download_json_files_data_folder%\data\domains "gz" ^
    %extract_json_files_data_folder%\domains ^
    %zip_log_folder%\domains ^
    flatten_folder_structure

call %functions%\unzip_folder.bat ^
    %download_json_files_data_folder%\data\fields "gz" ^
    %extract_json_files_data_folder%\fields ^
    %zip_log_folder%\fields ^
    flatten_folder_structure

call %functions%\unzip_folder.bat ^
    %download_json_files_data_folder%\data\funders "gz" ^
    %extract_json_files_data_folder%\funders ^
    %zip_log_folder%\funders ^
    flatten_folder_structure

call %functions%\unzip_folder.bat ^
    %download_json_files_data_folder%\data\institutions "gz" ^
    %extract_json_files_data_folder%\institutions ^
    %zip_log_folder%\institutions ^
    flatten_folder_structure

call %functions%\unzip_folder.bat ^
    %download_json_files_data_folder%\data\institution-types "gz" ^
    %extract_json_files_data_folder%\institution-types ^
    %zip_log_folder%\institution-types ^
    flatten_folder_structure

call %functions%\unzip_folder.bat ^
    %download_json_files_data_folder%\data\keywords "gz" ^
    %extract_json_files_data_folder%\keywords ^
    %zip_log_folder%\keywords ^
    flatten_folder_structure

call %functions%\unzip_folder.bat ^
    %download_json_files_data_folder%\data\languages "gz" ^
    %extract_json_files_data_folder%\languages ^
    %zip_log_folder%\languages ^
    flatten_folder_structure

call %functions%\unzip_folder.bat ^
    %download_json_files_data_folder%\data\licenses "gz" ^
    %extract_json_files_data_folder%\licenses ^
    %zip_log_folder%\licenses ^
    flatten_folder_structure

call %functions%\unzip_folder.bat ^
    %download_json_files_data_folder%\data\publishers "gz" ^
    %extract_json_files_data_folder%\publishers ^
    %zip_log_folder%\publishers ^
    flatten_folder_structure

call %functions%\unzip_folder.bat ^
    %download_json_files_data_folder%\data\sdgs "gz" ^
    %extract_json_files_data_folder%\sdgs ^
    %zip_log_folder%\sdgs ^
    flatten_folder_structure

call %functions%\unzip_folder.bat ^
    %download_json_files_data_folder%\data\sources "gz" ^
    %extract_json_files_data_folder%\sources ^
    %zip_log_folder%\sources ^
    flatten_folder_structure

call %functions%\unzip_folder.bat ^
    %download_json_files_data_folder%\data\source-types "gz" ^
    %extract_json_files_data_folder%\source-types ^
    %zip_log_folder%\source-types ^
    flatten_folder_structure

call %functions%\unzip_folder.bat ^
    %download_json_files_data_folder%\data\subfields "gz" ^
    %extract_json_files_data_folder%\subfields ^
    %zip_log_folder%\subfields ^
    flatten_folder_structure

call %functions%\unzip_folder.bat ^
    %download_json_files_data_folder%\data\topics "gz" ^
    %extract_json_files_data_folder%\topics ^
    %zip_log_folder%\topics ^
    flatten_folder_structure

call %functions%\unzip_folder.bat ^
    %download_json_files_data_folder%\data\work-types "gz" ^
    %extract_json_files_data_folder%\work-types ^
    %zip_log_folder%\work-types ^
    flatten_folder_structure

for /L %%i in (1,1,%number_of_processes%) do (
    start /min %functions%\unzip_folder.bat ^
        %process_json_files_data_folder%\authors\%%i "gz" ^
        %extract_json_files_data_folder%\authors\%%i ^
        %zip_log_folder%\authors\%%i ^
        flatten_folder_structure
)
call %functions%\wait.bat :receive %functions%\unzip_folder.bat %number_of_processes%

for /L %%i in (1,1,%number_of_processes%) do (
    start /min %functions%\unzip_folder.bat ^
        %process_json_files_data_folder%\works\%%i "gz" ^
        %extract_json_files_data_folder%\works\%%i ^
        %zip_log_folder%\works\%%i ^
        flatten_folder_structure
)
call %functions%\wait.bat :receive %functions%\unzip_folder.bat %number_of_processes%

:: ---------------------------------------------------------------------------------------

call %functions%\notify.bat "%json_db_name%" "%~n0" ""
call %functions%\check_errors.bat pause
goto:eof
:: =======================================================================================
