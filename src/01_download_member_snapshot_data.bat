@echo off

call settings.bat
call %programs%\executables.bat

:: =======================================================================================
:: Main

::: Download OpenAlex data from their AWS instance.
::: Downloaded files are put in [data\json_files\download].
:: =======================================================================================

set aws_config_file=%development_folder%\aws_config.conf

set "ps_env=$env:AWS_CONFIG_FILE='%aws_config_file%'"
set "ps_command=aws s3 ls s3://openalex-snapshots/full/ | Where-Object { $_ -Match 'PRE' } | Select-Object -Last 1 | ForEach-Object { $_ -replace '[\s]*PRE ([0-9-]{10})/','$1' }"
for /F %%i in ('%powershell_exe% "%ps_env%; %ps_command%"') do (
    set snapshot_date=%%i
)

call %functions%\aws_download_folder.bat ^
    s3://openalex-snapshots/full/%snapshot_date%/jsonl/ ^
    %download_json_files_data_folder%\data ^
    openalex ^
    %download_log_folder%

call %functions%\notify.bat "%json_db_name%" "%~n0" ""

call %functions%\check_errors.bat pause
goto:eof
:: =======================================================================================
