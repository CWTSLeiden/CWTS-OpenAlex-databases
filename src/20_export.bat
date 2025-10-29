@echo off

call settings.bat

:: =======================================================================================
:: Main
:: =======================================================================================

call %functions%\export_database.bat ^
    %relational_db_name% ^
    %sql_src_folder%\relational\export ^
    %export_data_folder%\relational ^
    %export_log_folder%\relational

call %functions%\export_database.bat ^
    %classification_db_name% ^
    %sql_src_folder%\classification\export ^
    %export_data_folder%\classification ^
    %export_log_folder%\classification

call %functions%\export_database.bat ^
    %core_db_name% ^
    %sql_src_folder%\core\export ^
    %export_data_folder%\core ^
    %export_log_folder%\core

call %functions%\check_errors.bat pause
goto:eof
:: =======================================================================================
