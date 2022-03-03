DROP VIEW IF EXISTS population.state_year_age;

CREATE VIEW population.state_year_age AS
SELECT
    state,
    cast(yearly_july_1st_estimates_code AS INTEGER) AS 'year_code',
    age_group_code,
    cast(population AS INTEGER) AS 'population'
FROM
    population.imp_Bridged_Race_Population_Estimates_1990_2019
WHERE
    yearly_july_1st_estimates_code IN (
        SELECT
            *
        FROM
            seq_1999_to_2019
    )
UNION
ALL
SELECT
    -- 2020
    state,
    cast(yearly_july_1st_estimates_code AS INTEGER) AS 'year_code',
    age_group_code,
    cast(population AS INTEGER)
FROM
    population.2020_states_age_group
ORDER BY
    state,
    year_code,
    age_group_code;