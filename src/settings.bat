@echo off

:: ---------------------------------------------------------------------------------------
:: Pipeline settings
:: ---------------------------------------------------------------------------------------

set db_version=2024aug
set previous_db_version=2023nov
set db_owner=vuw\%USERNAME%
set database_drive_letter=G

set notifications=true
set verbose=true

:: ---------------------------------------------------------------------------------------
:: Database settings
:: ---------------------------------------------------------------------------------------

set log_drive_letter=L

:: Identity tables
set copy_identity_tables=true
set previous_relational_db_name=openalex_%previous_db_version%

:: Relational databases
set relational_db_name=openalex_%db_version%
set text_db_name=openalex_%db_version%_text
set classification_db_name=openalex_%db_version%_classification
set core_db_name=openalex_%db_version%_core
set indicators_db_name=openalex_%db_version%_indicators

:: Raw databases
set json_db_name=openalex_%db_version%_json
set authors_json_db_name=openalex_%db_version%_authors_json
set concepts_json_db_name=openalex_%db_version%_concepts_json
set funders_json_db_name=openalex_%db_version%_funders_json
set institutions_json_db_name=openalex_%db_version%_institutions_json
set publishers_json_db_name=openalex_%db_version%_publishers_json
set sources_json_db_name=openalex_%db_version%_sources_json
set works_json_db_name=openalex_%db_version%_works_json

:: Utility databases
set etl_db_name=cwtsdb_etl
set dba_db_name=cwtsdb_dba

:: ---------------------------------------------------------------------------------------
:: Classification Settings
:: ---------------------------------------------------------------------------------------

set classification_min_pub_year_extended_pub_set=1980
set classification_max_pub_year_extended_pub_set=2023
set classification_min_pub_year_core_pub_set=2000
set classification_max_pub_year_core_pub_set=2023

:: publicationclassification
set classification_memory=200G
set classification_n_iterations=100
set classification_resolution_macro_level=2.2e-8
set classification_resolution_meso_level=4.9e-7
set classification_resolution_micro_level=2.2e-6
set classification_threshold_macro_level=500000
set classification_threshold_meso_level=10000
set classification_threshold_micro_level=1000
set classification_pub_table=classification.pub
set classification_cit_link_table=classification.cit_link
set classification_classification_table=classification.pub_cluster

:: publicationclassificationlabeling
set classification_n_pub_titles_per_cluster=250
set classification_pub_titles_table=classification.cluster_pub_titles
set classification_label_table=classification.cluster_labeling
set classification_openai_gpt_model=gpt-3.5-turbo-1106
set classification_print_labeling=%verbose%

:: ---------------------------------------------------------------------------------------
:: Core Settings
:: ---------------------------------------------------------------------------------------

set core_min_pub_year_core_pubs=%classification_min_pub_year_core_pub_set%

:: ---------------------------------------------------------------------------------------
:: Indicators Settings
:: ---------------------------------------------------------------------------------------

set indicators_min_pub_year=%classification_min_pub_year_core_pub_set%
set indicators_max_pub_year=2023

:: ---------------------------------------------------------------------------------------
:: Terminal Settings
:: ---------------------------------------------------------------------------------------

set process_drive_letter=D

set number_of_processes=32
set sleep_timer=1

:: Json Parser
set json_parser_folderfilecolumns=true

:: Json Analyzer
set json_analyzer_safe=false
set json_analyzer_skip_paths="abstract_inverted_index,international.display_name,international.description"
set json_analyzer_sample_lines=10000

:: ---------------------------------------------------------------------------------------
:: Folders
:: ---------------------------------------------------------------------------------------

set root_folder=%process_drive_letter%:\Development\OpenAlex\%db_version%
call %root_folder%\etl-tooling\functions\folder.bat
call %functions%\secret.bat %development_folder%\secrets.bat

set core_sql_src_folder=%sql_src_folder%\core
set core_sql_log_folder=%sql_log_folder%\core

:: ---------------------------------------------------------------------------------------
:: Checks
:: ---------------------------------------------------------------------------------------

call %functions%\check_errors.bat
