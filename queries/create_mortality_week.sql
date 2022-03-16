ALTER TABLE
    deaths.imp_Weekly_counts_of_deaths_by_jurisdiction_and_age_group
MODIFY
    week INTEGER;

CREATE INDEX IF NOT EXISTS idx_all ON deaths.imp_Weekly_counts_of_deaths_by_jurisdiction_and_age_group (year, week, jurisdiction, age_group, `type`);

-- ***
-- Create the expected weekly structure, as some weeks might be missing.
-- ***
DROP TABLE IF EXISTS deaths.deaths_structure;

CREATE TABLE deaths.deaths_structure AS
SELECT
    *
FROM
    (
        SELECT
            DISTINCT jurisdiction
        FROM
            deaths.imp_Weekly_counts_of_deaths_by_jurisdiction_and_age_group
    ) a
    CROSS JOIN (
        SELECT
            DISTINCT year,
            week,
            age_group
        FROM
            deaths.imp_Weekly_counts_of_deaths_by_jurisdiction_and_age_group
        WHERE
            jurisdiction = 'United States'
    ) b;

CREATE INDEX idx_all ON deaths.deaths_structure (year, week, jurisdiction, age_group);

ANALYZE TABLE deaths.deaths_structure;

ANALYZE TABLE deaths.imp_Weekly_counts_of_deaths_by_jurisdiction_and_age_group;

-- ***
-- Create Mortality table, per 100k.
-- ***
DROP TABLE IF EXISTS deaths.mortality_week;

CREATE TABLE deaths.mortality_week AS
SELECT
    a.state,
    a.year,
    a.week,
    deaths_0_24,
    deaths_25_44,
    deaths_45_64,
    deaths_65_74,
    deaths_75_84,
    deaths_85,
    @deaths := deaths_0_24 + deaths_25_44 + deaths_45_64 + deaths_65_74 + deaths_75_84 + deaths_85 AS "deaths",
    @mortality_0_24 := (deaths_0_24 / pop_0_24) * 100000 AS "mortality_0_24",
    @mortality_25_44 := (deaths_25_44 / pop_25_44) * 100000 AS "mortality_25_44",
    @mortality_45_64 := (deaths_45_64 / pop_45_64) * 100000 AS "mortality_45_64",
    @mortality_65_74 := (deaths_65_74 / pop_65_74) * 100000 AS "mortality_65_74",
    @mortality_75_84 := (deaths_75_84 / pop_75_84) * 100000 AS "mortality_75_84",
    @mortality_85 := (deaths_85 / pop_85) * 100000 AS "mortality_85",
    (@deaths / pop_total) * 100000 AS mortality,
    pop_0_24,
    pop_25_44,
    pop_45_64,
    pop_65_74,
    pop_75_84,
    pop_85,
    pop_total
FROM
    (
        SELECT
            a.state,
            a.year,
            a.week,
            sum(deaths_0_24) AS "deaths_0_24",
            sum(deaths_25_44) AS "deaths_25_44",
            sum(deaths_45_64) AS "deaths_45_64",
            sum(deaths_65_74) AS "deaths_65_74",
            sum(deaths_75_84) AS "deaths_75_84",
            sum(deaths_85) AS "deaths_85"
        FROM
            (
                SELECT
                    a.state,
                    a.year,
                    a.week,
                    CASE
                        WHEN age_group = "Under 25 years" THEN deaths
                        ELSE 0
                    END AS "deaths_0_24",
                    CASE
                        WHEN age_group = "25-44 years" THEN deaths
                        ELSE 0
                    END AS "deaths_25_44",
                    CASE
                        WHEN age_group = "45-64 years" THEN deaths
                        ELSE 0
                    END AS "deaths_45_64",
                    CASE
                        WHEN age_group = "65-74 years" THEN deaths
                        ELSE 0
                    END AS "deaths_65_74",
                    CASE
                        WHEN age_group = "75-84 years" THEN deaths
                        ELSE 0
                    END AS "deaths_75_84",
                    CASE
                        WHEN age_group = "85 years and older" THEN deaths
                        ELSE 0
                    END AS "deaths_85"
                FROM
                    (
                        -- Join with the expected structure, given some weeks are missing.
                        SELECT
                            a.jurisdiction AS "state",
                            a.year,
                            a.week,
                            a.age_group,
                            CASE
                                WHEN b.number_of_deaths IS NOT NULL
                                AND b.number_of_deaths <> '' THEN b.number_of_deaths
                                ELSE 0
                            END AS 'deaths'
                        FROM
                            deaths.deaths_structure a
                            LEFT JOIN (
                                -- Combine NYC and NY data
                                SELECT
                                    "New York" AS jurisdiction,
                                    year,
                                    week,
                                    age_group,
                                    sum(number_of_deaths) AS "number_of_deaths",
                                    TYPE
                                FROM
                                    deaths.imp_Weekly_counts_of_deaths_by_jurisdiction_and_age_group
                                WHERE
                                    jurisdiction LIKE "New York%"
                                GROUP BY
                                    year,
                                    week,
                                    age_group,
                                    TYPE
                                UNION
                                -- and combine with rest
                                ALL
                                SELECT
                                    jurisdiction,
                                    year,
                                    week,
                                    age_group,
                                    number_of_deaths,
                                    TYPE
                                FROM
                                    deaths.imp_Weekly_counts_of_deaths_by_jurisdiction_and_age_group
                                WHERE
                                    jurisdiction NOT LIKE "New York%"
                            ) b ON a.jurisdiction = b.jurisdiction
                            AND a.year = b.year
                            AND a.week = b.week
                            AND a.age_group = b.age_group
                            AND b.`type` = "Predicted (weighted)"
                    ) a
            ) a
        GROUP BY
            state,
            year,
            week
    ) a
    JOIN population.imp_population20152021 b ON a.state = b.state
    AND a.year = b.year;

-- correction factor 2021
DROP VIEW IF EXISTS population.population_weights_2021;

CREATE VIEW population.population_weights_2021 AS
SELECT
    state,
    year,
    pop_0_24 / pop_total AS "f_0_24",
    pop_25_44 / pop_total AS "f_25_44",
    pop_45_64 / pop_total AS "f_45_64",
    pop_65_74 / pop_total AS "f_65_74",
    pop_75_84 / pop_total AS "f_75_84",
    pop_85 / pop_total AS "f_85"
FROM
    population.imp_population20152021 a
WHERE
    year = 2021;

DROP TABLE IF EXISTS deaths.adj_mortality_week;

CREATE TABLE deaths.adj_mortality_week AS
SELECT
    a.*,
    @adj_mortality_0_24 := mortality_0_24 * b.f_0_24 AS "adj_mortality_0_24",
    @adj_mortality_25_44 := mortality_25_44 * b.f_25_44 AS "adj_mortality_25_44",
    @adj_mortality_45_64 := mortality_45_64 * b.f_45_64 AS "adj_mortality_45_64",
    @adj_mortality_65_74 := mortality_65_74 * b.f_65_74 AS "adj_mortality_65_74",
    @adj_mortality_75_84 := mortality_75_84 * b.f_75_84 AS "adj_mortality_75_84",
    @adj_mortality_85 := mortality_85 * b.f_85 AS "adj_mortality_85",
    @adj_mortality_0_24 + @adj_mortality_25_44 + @adj_mortality_45_64 + @adj_mortality_65_74 + @adj_mortality_75_84 + @adj_mortality_85 AS "adj_mortality",
    @adj_mortality_std_0_24 := mortality_0_24 * c.f_0_24 AS "adj_mortality_std_0_24",
    @adj_mortality_std_25_44 := mortality_25_44 * c.f_25_44 AS "adj_mortality_std_25_44",
    @adj_mortality_std_45_64 := mortality_45_64 * c.f_45_64 AS "adj_mortality_std_45_64",
    @adj_mortality_std_65_74 := mortality_65_74 * c.f_65_74 AS "adj_mortality_std_65_74",
    @adj_mortality_std_75_84 := mortality_75_84 * c.f_75_84 AS "adj_mortality_std_75_84",
    @adj_mortality_std_85 := mortality_85 * c.f_85 AS "adj_mortality_std_85",
    @adj_mortality_std_0_24 + @adj_mortality_std_25_44 + @adj_mortality_std_45_64 + @adj_mortality_std_65_74 + @adj_mortality_std_75_84 + @adj_mortality_std_85 AS "adj_mortality_std"
FROM
    deaths.mortality_week a
    JOIN population.population_weights_2021 b ON a.state = b.state
    JOIN population.imp_std_population2000 c;

CREATE INDEX idx_state ON deaths.adj_mortality_week (state);

CREATE INDEX idx_year ON deaths.adj_mortality_week (year);

CREATE INDEX idx_week ON deaths.adj_mortality_week (week);