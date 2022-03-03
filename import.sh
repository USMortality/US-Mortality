#!/bin/bash

function import_csv() {
    cd tools
    ./import_csv.sh "../data/${2}/${1}" $2
    cd ~-
}

mysql -h 127.0.0.1 -u root -e "SET GLOBAL local_infile=1;"

# Population
import_csv population20152021.csv population
import_csv std_population2000.csv population

# Deaths
import_csv Weekly_counts_of_deaths_by_jurisdiction_and_age_group.csv deaths
import_csv Weekly_counts_of_deaths_by_state_and_cause.csv deaths
