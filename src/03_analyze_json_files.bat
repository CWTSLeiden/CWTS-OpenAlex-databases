@echo off

call settings.bat

:: =======================================================================================
:: Main
:: =======================================================================================

call :analyze_json_tags %extract_json_files_data_folder%\concepts
call :analyze_json_tags %extract_json_files_data_folder%\domains
call :analyze_json_tags %extract_json_files_data_folder%\fields
call :analyze_json_tags %extract_json_files_data_folder%\funders
call :analyze_json_tags %extract_json_files_data_folder%\institutions
call :analyze_json_tags %extract_json_files_data_folder%\publishers
call :analyze_json_tags %extract_json_files_data_folder%\sources
call :analyze_json_tags %extract_json_files_data_folder%\subfields
call :analyze_json_tags %extract_json_files_data_folder%\topics
call :analyze_json_tags %extract_json_files_data_folder%\authors
call :analyze_json_tags %extract_json_files_data_folder%\works

call %functions%\notify.bat "%json_db_name%" "%~n0" ""
pause
goto:eof
:: =======================================================================================


:: =======================================================================================
:analyze_json_tags
:: =======================================================================================
set source_folder=%~1
set source_name=%~n1

call %functions%\json_analyze_data.bat ^
    %json_db_name% ^
    %source_folder% ^
    "part_#" ^
    line_by_line ^
    %validation_data_folder%\json_paths_%source_name%.txt
)

goto:eof
:: =======================================================================================
