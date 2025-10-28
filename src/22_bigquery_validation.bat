@echo off

call settings.bat

:: =======================================================================================
:: Main
:: =======================================================================================

call %functions%\variable.bat :create_folder validation_data_folder
call %programs%\executables.bat :create_folder validation_data_folder

call :validate_dataset %relational_db_name%
call :validate_dataset %classification_db_name%
call :validate_dataset %core_db_name%

goto:eof
:: =======================================================================================


:: =======================================================================================
:validate_dataset
:: =======================================================================================

set dataset=%~1
set output_file=%validation_data_folder%\%dataset%_bigquery_row_count_tables.tsv

set "query=select concat(table_id, '\t', cast(row_count as STRING)) from `%bigquery_project%.%dataset%.__TABLES__`"

echo Validate %bigquery_project%:%dataset%
call %bq_exe% query ^
    --format=csv ^
    %query% ^
    1> %output_file%.tmp

call %powershell_exe% "Get-Content %output_file%.tmp | select-object -skip 1 | Out-File %output_file%"
del %output_file%.tmp >nul

call %functions%\validate_database.bat %dataset%

goto:eof
:: =======================================================================================
