@echo off

call settings.bat

:: =======================================================================================
:: Main
:: =======================================================================================

call :load_bigquery_folder ^
    %relational_db_name% ^
    %export_data_folder%\relational

call :load_bigquery_folder ^
    %classification_db_name% ^
    %export_data_folder%\classification

call :load_bigquery_folder ^
    %core_db_name% ^
    %export_data_folder%\core

call %functions%\check_errors.bat pause
goto:eof
:: =======================================================================================


:: =======================================================================================
:load_bigquery_folder
:: =======================================================================================
setlocal
set db_name=%~1
set export_folder=%~2

for /f %%f in ('dir /b /ON "%export_folder%\*.tsv"') do (
    call :load_bigquery_table %db_name% %%~f %export_folder%
)

endlocal
goto:eof
:: =======================================================================================


:: =======================================================================================
:load_bigquery_table
:: =======================================================================================
setlocal
set db_name=%~1
set file=%~2
set file_name=%~n2
set "table_name=%file_name:_#=" & set "number=%"
set export_folder=%~3

call %functions%\load_bigquery_table ^
    %export_folder%\%file% ^
    %bigquery_project%:%db_name%.%table_name% ^
    %export_folder%\types\%table_name%_types.tsv ^
    %bigquery_log_folder%\%db_name%

endlocal
goto:eof
:: =======================================================================================
