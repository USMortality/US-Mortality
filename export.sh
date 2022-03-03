#!/bin/bash

mysql -h 127.0.0.1 -u root -e \
    "SET GLOBAL collation_connection = 'utf8mb4_general_ci';"
mysql -h 127.0.0.1 -u root -e "SET GLOBAL sql_mode = '';"

mysql -h 127.0.0.1 -u root deaths <queries/create_mortality_week.sql
mysql -h 127.0.0.1 -u root deaths <queries/create_covid_week.sql
mysql -h 127.0.0.1 -u root deaths <queries/exp_mortality_week.sql \
    >./out/mortality_week.csv
