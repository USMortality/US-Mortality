#!/bin/bash

mysql -h 127.0.0.1 -u root -e \
    "SET GLOBAL collation_connection = 'utf8mb4_general_ci';"
mysql -h 127.0.0.1 -u root -e "SET GLOBAL sql_mode = '';"

mysql -h 127.0.0.1 -u root deaths <./queries_sheet/mortality_quarter.sql \
    >./out/mortality_quarter.tsv
mysql -h 127.0.0.1 -u root deaths <./queries_sheet/mortality_yearly.sql \
    >./out/mortality_yearly.tsv
mysql -h 127.0.0.1 -u root deaths <./queries_sheet/mortality_yearly_current_week.sql \
    >./out/mortality_yearly_current_week.tsv
mysql -h 127.0.0.1 -u root deaths <./queries_sheet/mortality_time_series.sql \
    >./out/mortality_time_series.tsv
mysql -h 127.0.0.1 -u root deaths <./queries_sheet/mortality_flu_season_20_22.sql \
    >./out/mortality_flu_season_20_22.tsv
mysql -h 127.0.0.1 -u root deaths <./queries_sheet/mortality_pandemic_ts.sql \
    >./out/mortality_pandemic_ts.tsv
mysql -h 127.0.0.1 -u root deaths <./queries_sheet/mortality_pandemic_ts_std.sql \
    >./out/mortality_pandemic_ts_std.tsv

mysql -h 127.0.0.1 -u root deaths <./queries_sheet/mortality_d_ts.sql \
    >./out/mortality_d_ts.tsv
mysql -h 127.0.0.1 -u root deaths <./queries_sheet/mortality_d_ts_0_24.sql \
    >./out/mortality_d_ts_0_24.tsv
mysql -h 127.0.0.1 -u root deaths <./queries_sheet/mortality_d_ts_25_44.sql \
    >./out/mortality_d_ts_25_44.tsv
mysql -h 127.0.0.1 -u root deaths <./queries_sheet/mortality_d_ts_45_64.sql \
    >./out/mortality_d_ts_45_64.tsv
mysql -h 127.0.0.1 -u root deaths <./queries_sheet/mortality_d_ts_65_74.sql \
    >./out/mortality_d_ts_65_74.tsv
mysql -h 127.0.0.1 -u root deaths <./queries_sheet/mortality_d_ts_75_84.sql \
    >./out/mortality_d_ts_75_84.tsv
mysql -h 127.0.0.1 -u root deaths <./queries_sheet/mortality_d_ts_85.sql \
    >./out/mortality_d_ts_85.tsv

mysql -h 127.0.0.1 -u root deaths <./queries_sheet/mortality_r_ts.sql \
    >./out/mortality_r_ts.tsv
mysql -h 127.0.0.1 -u root deaths <./queries_sheet/mortality_r_ts_0_24.sql \
    >./out/mortality_r_ts_0_24.tsv
mysql -h 127.0.0.1 -u root deaths <./queries_sheet/mortality_r_ts_25_44.sql \
    >./out/mortality_r_ts_25_44.tsv
mysql -h 127.0.0.1 -u root deaths <./queries_sheet/mortality_r_ts_45_64.sql \
    >./out/mortality_r_ts_45_64.tsv
mysql -h 127.0.0.1 -u root deaths <./queries_sheet/mortality_r_ts_65_74.sql \
    >./out/mortality_r_ts_65_74.tsv
mysql -h 127.0.0.1 -u root deaths <./queries_sheet/mortality_r_ts_75_84.sql \
    >./out/mortality_r_ts_75_84.tsv
mysql -h 127.0.0.1 -u root deaths <./queries_sheet/mortality_r_ts_85.sql \
    >./out/mortality_r_ts_85.tsv
