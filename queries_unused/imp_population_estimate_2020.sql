-- create view with population numbers (uncorrected for total pop) per age bracket for 2020
DROP VIEW IF EXISTS population.estimate_2020;

CREATE VIEW population.estimate_2020 AS
SELECT
    state,
    age_group_code,
    population_2018,
    population_2019,
    population_2019 * (population_2019 / population_2018) AS "population_2020_uncorrected"
FROM
    (
        SELECT
            state,
            age_group_code,
            sum(population_2018) AS "population_2018",
            sum(population_2019) AS "population_2019"
        FROM
            (
                -- states
                SELECT
                    state,
                    age_group_code,
                    CASE
                        WHEN yearly_july_1st_estimates_code = 2018 THEN population
                        ELSE 0
                    END AS population_2018,
                    CASE
                        WHEN yearly_july_1st_estimates_code = 2019 THEN population
                        ELSE 0
                    END AS population_2019
                FROM
                    population.imp_Bridged_Race_Population_Estimates_1990_2019
                WHERE
                    yearly_july_1st_estimates_code IN (2018, 2019)
                UNION
                -- US total
                SELECT
                    "United States" AS "state",
                    age_group_code,
                    CASE
                        WHEN yearly_july_1st_estimates_code = 2018 THEN population
                        ELSE 0
                    END AS population_2018,
                    CASE
                        WHEN yearly_july_1st_estimates_code = 2019 THEN population
                        ELSE 0
                    END AS population_2019
                FROM
                    population.imp_Bridged_Race_Population_Estimates_1990_2019_US
                WHERE
                    yearly_july_1st_estimates_code IN (2018, 2019)
                    AND age_group_code <> ""
            ) a
        GROUP BY
            state,
            age_group_code
    ) b;

DROP VIEW IF EXISTS population.corr_factor;

CREATE VIEW population.corr_factor AS
SELECT
    a.state,
    b.population / population_2020_state_total AS "corr_factor"
FROM
    (
        SELECT
            state,
            sum(population_2020_uncorrected) AS "population_2020_state_total"
        FROM
            population.estimate_2020
        GROUP BY
            state
    ) a
    JOIN population.imp_census2020 b ON a.state = b.state;

DROP VIEW IF EXISTS population.2020_states_age_group;

CREATE VIEW population.2020_states_age_group AS
SELECT
    "" AS notes,
    a.state AS "state",
    "" AS state_code,
    "" AS age_group,
    age_group_code,
    "2020" AS yearly_july_1st_estimates,
    "2020" AS yearly_july_1st_estimates_code,
    round(population_2020_uncorrected * corr_factor) AS "population"
FROM
    population.estimate_2020 a
    JOIN population.corr_factor b ON a.state = b.state;