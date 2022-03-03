#!/bin/bash

function test() {
    name=$1
    record=$2
    printf "$name: " && mysqltest -h 127.0.0.1 -u root --result-file=result/$name.expected $record <$name.sql
}

cd test

printf "\n\n%s\n\n" "Running tests..."

test "exp_population" $1
test "exp_stringency" $1
test "exp_deaths" $1

cd ~-
