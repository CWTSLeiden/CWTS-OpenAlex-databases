@echo off

call settings.bat

:: =======================================================================================
:: Main
:: =======================================================================================
set export_table_include_types=false

call :export_folder ^
    %leiden_ranking_db_name% ^
    %sql_src_folder%\zenodo\leiden_ranking ^
    %export_data_folder%\zenodo\leiden_ranking ^
    %export_data_folder%\zenodo\cwts_%leiden_ranking_db_name%.zip ^
    %export_log_folder%\zenodo\leiden_ranking

call :export_folder ^
    %core_db_name% ^
    %sql_src_folder%\zenodo\core ^
    %export_data_folder%\zenodo\core ^
    %export_data_folder%\zenodo\core_%relational_db_name%.zip ^
    %export_log_folder%\zenodo\core

call :export_folder ^
    %classification_db_name% ^
    %sql_src_folder%\zenodo\classification ^
    %export_data_folder%\zenodo\classification ^
    %export_data_folder%\zenodo\classification_%relational_db_name%.zip ^
    %export_log_folder%\zenodo\classification

call %functions%\check_errors.bat pause
goto:eof
:: =======================================================================================


:: =======================================================================================
:export_folder
:: =======================================================================================
setlocal

set db_name=%~1
set export_sql_folder=%~2
set output_folder=%~3
set archive_file=%~4
set log_folder=%~5

for /f %%f in ('dir /b /ON "%export_sql_folder%\*.sql"') do (
    call %functions%\export_table.bat ^
        %db_name% ^
        %export_sql_folder%\%%f ^
        %output_folder% ^
        %log_folder%
)

set zip_append=true
if exist %archive_file% (
    del %archive_file%
)

call %functions%\zip_folder.bat ^
    %output_folder% ^
    %archive_file% ^
    %zip_log_folder%

endlocal
goto:eof
:: =======================================================================================
