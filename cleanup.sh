#!/bin/bash

mysql -h 127.0.0.1 -u root -e "DROP DATABASE IF EXISTS population;"
mysql -h 127.0.0.1 -u root -e "DROP DATABASE IF EXISTS deaths;"
