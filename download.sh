#!/bin/bash

date=$(gdate --date="14 days ago" +"%Y")"_"$(gdate --date="14 days ago" +"%U")
wget "https://data.cdc.gov/api/views/y5bj-9g5w/rows.csv?accessType=DOWNLOAD" \
    -O "data/deaths/Weekly_counts_of_deaths_by_jurisdiction_and_age_group_"\
"${date}.csv"

wget "https://data.cdc.gov/api/views/muzy-jte6/rows.csv?accessType=DOWNLOAD" \
    -O "data/deaths/Weekly_counts_of_deaths_by_state_and_cause_${date}.csv"
