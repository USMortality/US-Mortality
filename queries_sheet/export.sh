#!/bin/bash

mysql -h 127.0.0.1 -u root -e \
    "SET GLOBAL collation_connection = 'utf8mb4_general_ci';"
mysql -h 127.0.0.1 -u root -e "SET GLOBAL sql_mode = '';"

mysql -h 127.0.0.1 -u root deaths <./queries_sheet/mortality_quarter.sql \
    >./out/mortality_quarter.csv
mysql -h 127.0.0.1 -u root deaths <./queries_sheet/mortality_yearly.sql \
    >./out/mortality_yearly.csv
mysql -h 127.0.0.1 -u root deaths <./queries_sheet/mortality_yearly_current_week.sql \
    >./out/mortality_yearly_current_week.csv
mysql -h 127.0.0.1 -u root deaths <./queries_sheet/mortality_time_series.sql \
    >./out/mortality_time_series.csv
mysql -h 127.0.0.1 -u root deaths <./queries_sheet/mortality_2020_2021_q4.sql \
    >./out/mortality_2020_2021_q4.csv
mysql -h 127.0.0.1 -u root deaths <./queries_sheet/mortality_pandemic_ts.sql \
    >./out/mortality_pandemic_ts.csv
mysql -h 127.0.0.1 -u root deaths <./queries_sheet/mortality_pandemic_ts_std.sql \
    >./out/mortality_pandemic_ts_std.csv
