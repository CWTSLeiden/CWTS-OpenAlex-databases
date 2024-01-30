@echo off

call settings.bat

:: =======================================================================================
:: Main

::: Download OpenAlex data from their AWS instance.
::: Downloaded files are put in [data\json_files\download].
:: =======================================================================================

call %functions%\aws_download_folder.bat ^
    s3://openalex ^
    %download_json_files_data_folder% ^
    openalex ^
    %download_log_folder%

call %functions%\notify.bat "%json_db_name%" "%~n0" ""

call %functions%\check_errors.bat pause
goto:eof
:: =======================================================================================
