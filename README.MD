#Readme

## Update Data

```
./download.sh

./cleanup.sh || true; and ./import.sh; and ./export.sh

# Update delay correction query
mysql -h 127.0.0.1 -u root deaths <queries/exp_delay_correction.sql >./out/delay_correction.csv
```

## Prerequisite

`brew install csvkit docker coreutils`

`docker run --name us-mortality-db -e MYSQL_ALLOW_EMPTY_PASSWORD=true -d -p 3306:3306 mariadb:latest --secure-file-priv=""`

# Excecut until mysql server responds:
`mysql -h 127.0.0.1 -u root -e "SELECT 1";`

# Now Excecute:
`./download.sh && ./cleanup.sh || true && ./import.sh && ./export.sh`

Import out/ docs into google sheet

```
SET
    collation_connection = 'utf8mb4_general_ci';

SET
    sql_mode = '';

```

`./download.sh && ./cleanup.sh && ./import.sh && ./test.sh`
