# CWTS OpenAlex databases

This repository contains the source code used by [CWTS](https://www.cwts.nl) to extract, transform, and load data from [OpenAlex](https://openalex.org) into a Microsoft SQL Server database system.

The source code produces five Microsoft SQL Server databases:

(1) Database containing data from OpenAlex in a relational format.

(2) Database containing titles and abstracts of publications.

(3) Database containing data on core publications.

(4) Database containing a classification of publications into research areas.

(5) Database containing stored procedures for indicator calculations.

See [this blog post](https://www.leidenmadtrics.nl/articles/introducing-the-leiden-ranking-open-edition) for more information about (3), (4), and (5).

This repository makes use of the [CWTS ETL tooling repository](https://github.com/CWTSLeiden/CWTS-ETL-tooling), the [publicationclassification repository](https://github.com/CWTSLeiden/publicationclassification), and the [publicationclassificationlabeling repository](https://github.com/CWTSLeiden/publicationclassificationlabeling).

