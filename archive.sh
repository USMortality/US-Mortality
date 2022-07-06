#!/bin/bash

function archive() {
    echo "Week $1"

    # Copy datasets into place for given week
    cp "data/deaths/Weekly_counts_of_deaths_by_jurisdiction_and_age_group_${1}.csv" "data/deaths/Weekly_counts_of_deaths_by_jurisdiction_and_age_group.csv"

    cp "data/deaths/Weekly_counts_of_deaths_by_state_and_cause_${1}.csv" "data/deaths/Weekly_counts_of_deaths_by_state_and_cause.csv"
    csvcut --columns=2,3,4,20 data/deaths/Weekly_counts_of_deaths_by_state_and_cause.csv >data/deaths/Weekly_counts_of_deaths_by_state_and_cause.csv.bak
    sed -i.bak -e 's/"COVID-19 (U071, Underlying Cause of Death)"/"covid19_u071_underlying"/g' data/deaths/Weekly_counts_of_deaths_by_state_and_cause.csv.bak
    mv data/deaths/Weekly_counts_of_deaths_by_state_and_cause.csv.bak data/deaths/Weekly_counts_of_deaths_by_state_and_cause.csv
    rm data/deaths/Weekly_counts_of_deaths_by_state_and_cause.csv.bak.bak

    # Clean, import and process dataset for given week
    ./cleanup.sh || true && ./import.sh && ./export.sh

    # Archive current week
    mysql -h 127.0.0.1 -u root -e "CREATE DATABASE IF NOT EXISTS archive;"
    mysql -h 127.0.0.1 -u root -e "CREATE TABLE IF NOT EXISTS archive.mortality_weeks (ID INT PRIMARY KEY AUTO_INCREMENT, week VARCHAR(7));"
    mysql -h 127.0.0.1 -u root -e "INSERT INTO archive.mortality_weeks (week) VALUES ('$1');"
    mysql -h 127.0.0.1 -u root -e "DROP TABLE IF EXISTS archive.mortality_week_$1; CREATE TABLE archive.mortality_week_$1 AS SELECT * FROM deaths.mortality_week;"
    mysql -h 127.0.0.1 -u root -e "CREATE INDEX idx_1 ON archive.mortality_week_$1 (state, year, week);"
    mysql -h 127.0.0.1 -u root -e "CREATE INDEX idx_2 ON archive.mortality_week_$1 (state);"
}

start=$(gdate -d "(date) - 16 weeks" +%F)
end=$(gdate -d "(date) - 3 weeks" +%F)

# mysql -h 127.0.0.1 -u root -e "DROP DATABASE IF EXISTS archive;"
# while ! [[ $start > $end ]]; do
#     start=$(gdate -d "$start + 1 week" +%F)
#     week=$(gdate -d $start +%Y)"_"$(gdate -d $start +%U)
#     archive "${week}"
# done

# Single week
end="2022-06-25"
week=$(gdate -d $end +%Y)"_"$(gdate -d $end +%U)
archive $week

# Delay Correction
mysql -h 127.0.0.1 -u root deaths <queries/exp_delay_correction.sql >out/mortality_delay_correction.csv
mysql -h 127.0.0.1 -u root deaths <queries/create_mortality_week_predicted.sql

# Sheets
./queries_sheet/export.sh
