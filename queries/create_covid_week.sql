DROP TABLE IF EXISTS deaths.covid_week;

CREATE TABLE deaths.covid_week AS
SELECT
    a.state,
    a.year,
    a.week,
    b.deaths_covid
FROM
    (
        SELECT
            DISTINCT jurisdiction AS "state",
            year,
            week
        FROM
            deaths.deaths_structure
        WHERE
            year >= 2020
    ) a
    LEFT JOIN (
        SELECT
            jurisdiction_of_occurrence AS "state",
            mmwr_year AS "year",
            mmwr_week AS "week",
            covid19_u071_underlying "deaths_covid"
        FROM
            deaths.imp_Weekly_counts_of_deaths_by_state_and_cause
    ) b ON a.state = b.state
    AND a.year = b.year
    AND a.week = b.week;

CREATE INDEX idx_all ON deaths.covid_week (state, year, week);