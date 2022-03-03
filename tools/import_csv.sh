#!/bin/bash

FILE_PATH=$1
DB=$2
FILE=$(basename "$FILE_PATH")
FILE_NAME=$(echo $FILE | sed 's/.csv//g' | sed 's/ /_/g' | sed 's/-/_/g' | sed 's/\//_/g' | sed 's/+/_/g')
COLUMNS=$(head -n 1 $FILE_PATH | sed 's/ /_/g' | tr -cd '[:alnum:],_' | awk '{print tolower($0)}')
COLUMNS=${COLUMNS%$'\r'}
TABLE_NAME="imp_$FILE_NAME"

# Create table sql statement.
IFS=',' read -ra COLUMN <<<"$COLUMNS"
SQL="CREATE TABLE $TABLE_NAME ("
for i in "${COLUMN[@]}"; do
	SQL+=" $i varchar(20),"
done
SQL=${SQL:0:${#SQL}-1}
SQL+=" );"

# Prepare DB.
mysql -h 127.0.0.1 -u root -e "CREATE DATABASE IF NOT EXISTS $DB;"
mysql -h 127.0.0.1 -u root -e "USE $DB;"
mysql -h 127.0.0.1 -u root -e "DROP TABLE IF EXISTS $TABLE_NAME" $DB
mysql -h 127.0.0.1 -u root -e "$SQL" $DB

cd $(dirname $FILE_PATH)
ln -s "$FILE" "$TABLE_NAME.csv"

# Import data.
mysqlimport --local -h 127.0.0.1 -u root --columns=$COLUMNS --fields-terminated-by="," --fields-optionally-enclosed-by='"' --ignore-lines=1 $DB "$TABLE_NAME.csv"

unlink "$TABLE_NAME.csv"
cd ~-