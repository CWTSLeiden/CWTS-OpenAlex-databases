@echo off

:: =======================================================================================
:: Main
::: Extract all archives
::: Robocopy command to duplicate file structure

:: global variables

:: functions
::: unzip_file.bat

:: input variables
::: 1. db_name:         Name of the database.
::: 2. type_of_json     Type of json data
::: 3. process_number   Process number
:: =======================================================================================

setlocal enabledelayedexpansion

set db_name=%~1
set type_of_json=%~2
set process_number=%~3

call :check_variables 3 %*

set source_folder=%process_json_files_data_folder%\%type_of_json%\%process_number%
set extract_folder_name=%process_folder%\%type_of_json%\%process_number%\data
robocopy "%source_folder%" "%extract_folder_name%" /e /xf * /NFL /NDL /NJH /NJS /nc /ns /np | findstr /r /v "^$"

for /R %source_folder% %%f in (*.gz) do (
    call :unzip_file ^
    "%%f"
)

call %functions%\wait.bat :send %~f0
endlocal
goto:eof

:: =======================================================================================
:unzip_file
:: =======================================================================================
set "zip_file=%~1"
set "zip_folder=%~dp1"
set parent_folder_name=!zip_folder:%source_folder%=!

call %functions%\unzip_file.bat ^
    "%zip_file%" ^
    "%extract_folder_name%%parent_folder_name%" ^
    "%zip_log_folder%\%type_of_json%\%process_number%%parent_folder_name%" ^
    flatten_structure

goto:eof

:: =======================================================================================
:check_variables
:: =======================================================================================

:: check number of input parameters
call %functions%\variable.bat :check_parameters %*

:: validate input variables
call %functions%\variable.bat :check_variable db_name
call %functions%\variable.bat :check_variable type_of_json
call %functions%\variable.bat :check_variable process_number

goto:eof
:: =======================================================================================
