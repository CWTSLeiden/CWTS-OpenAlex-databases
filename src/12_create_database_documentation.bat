@echo off

call settings.bat

:: =======================================================================================
:: Main 

::: Create extended properties in the relational from [doc\documentation.tsv]

::: Create documentation from those extended properties and the Visio
::: image files in [doc\img\]
:: =======================================================================================

call %functions%\add_extended_properties.bat ^
    %relational_db_name% ^
	%doc_folder%\documentation.tsv ^
	%documentation_relational_sql_log_folder% ^
	%bcp_log_folder% ^
	erase_previous

call %functions%\generate_database_documentation.bat ^
    %relational_db_name% ^
	%generated_documentation_doc_folder% ^
	%img_doc_folder% ^
	%database_documentatie_generator_log_folder%

call %functions%\check_errors.bat pause
goto:eof
:: =======================================================================================
