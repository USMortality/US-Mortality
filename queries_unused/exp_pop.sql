DROP TABLE IF EXISTS population.exp_population;

CREATE TABLE population.exp_population
SELECT
    state,
    CONCAT(year_code, "/", MONTH) AS month_code,
    pop_0_24,
    pop_25_44,
    pop_45_64,
    pop_65_74,
    pop_75_84,
    pop_85,
    pop_0_24 + pop_25_44 + pop_45_64 + pop_65_74 + pop_75_84 + pop_85 AS "pop_total"
FROM
    (
        SELECT
            state,
            year_code,
            SUM(pop_0_24) AS pop_0_24,
            SUM(pop_25_44) AS pop_25_44,
            SUM(pop_45_64) AS pop_45_64,
            SUM(pop_65_74) AS pop_65_74,
            SUM(pop_75_84) AS pop_75_84,
            SUM(pop_85) AS pop_85
        FROM
            (
                -- 1999-2020 States
                SELECT
                    state,
                    year_code,
                    CASE
                        WHEN age_group_code = "1" THEN cast(population AS INTEGER)
                        WHEN age_group_code = "1-4" THEN cast(population AS INTEGER)
                        WHEN age_group_code = "5-9" THEN cast(population AS INTEGER)
                        WHEN age_group_code = "10-14" THEN cast(population AS INTEGER)
                        WHEN age_group_code = "15-19" THEN cast(population AS INTEGER)
                        WHEN age_group_code = "20-24" THEN cast(population AS INTEGER)
                        ELSE 0
                    END AS "pop_0_24",
                    CASE
                        WHEN age_group_code = "25-29" THEN cast(population AS INTEGER)
                        WHEN age_group_code = "30-34" THEN cast(population AS INTEGER)
                        WHEN age_group_code = "35-39" THEN cast(population AS INTEGER)
                        WHEN age_group_code = "40-44" THEN cast(population AS INTEGER)
                        ELSE 0
                    END AS "pop_25_44",
                    CASE
                        WHEN age_group_code = "45-49" THEN cast(population AS INTEGER)
                        WHEN age_group_code = "50-54" THEN cast(population AS INTEGER)
                        WHEN age_group_code = "55-59" THEN cast(population AS INTEGER)
                        WHEN age_group_code = "60-64" THEN cast(population AS INTEGER)
                        ELSE 0
                    END AS "pop_45_64",
                    CASE
                        WHEN age_group_code = "65-69" THEN cast(population AS INTEGER)
                        WHEN age_group_code = "70-74" THEN cast(population AS INTEGER)
                        ELSE 0
                    END AS "pop_65_74",
                    CASE
                        WHEN age_group_code = "75-79" THEN cast(population AS INTEGER)
                        WHEN age_group_code = "80-84" THEN cast(population AS INTEGER)
                        ELSE 0
                    END AS "pop_75_84",
                    CASE
                        WHEN age_group_code = "85+" THEN cast(population AS INTEGER)
                        ELSE 0
                    END AS "pop_85"
                FROM
                    population.state_year_age d
                UNION
                ALL -- 1990-2019 US
                SELECT
                    "United States" AS state,
                    cast(yearly_july_1st_estimates_code AS INTEGER) AS "year_code",
                    CASE
                        WHEN age_group_code = "1" THEN cast(population AS INTEGER)
                        WHEN age_group_code = "1-4" THEN cast(population AS INTEGER)
                        WHEN age_group_code = "5-9" THEN cast(population AS INTEGER)
                        WHEN age_group_code = "10-14" THEN cast(population AS INTEGER)
                        WHEN age_group_code = "15-19" THEN cast(population AS INTEGER)
                        WHEN age_group_code = "20-24" THEN cast(population AS INTEGER)
                        ELSE 0
                    END AS "pop_0_24",
                    CASE
                        WHEN age_group_code = "25-29" THEN cast(population AS INTEGER)
                        WHEN age_group_code = "30-34" THEN cast(population AS INTEGER)
                        WHEN age_group_code = "35-39" THEN cast(population AS INTEGER)
                        WHEN age_group_code = "40-44" THEN cast(population AS INTEGER)
                        ELSE 0
                    END AS "pop_25_44",
                    CASE
                        WHEN age_group_code = "45-49" THEN cast(population AS INTEGER)
                        WHEN age_group_code = "50-54" THEN cast(population AS INTEGER)
                        WHEN age_group_code = "55-59" THEN cast(population AS INTEGER)
                        WHEN age_group_code = "60-64" THEN cast(population AS INTEGER)
                        ELSE 0
                    END AS "pop_45_64",
                    CASE
                        WHEN age_group_code = "65-69" THEN cast(population AS INTEGER)
                        WHEN age_group_code = "70-74" THEN cast(population AS INTEGER)
                        ELSE 0
                    END AS "pop_65_74",
                    CASE
                        WHEN age_group_code = "75-79" THEN cast(population AS INTEGER)
                        WHEN age_group_code = "80-84" THEN cast(population AS INTEGER)
                        ELSE 0
                    END AS "pop_75_84",
                    CASE
                        WHEN age_group_code = "85+" THEN cast(population AS INTEGER)
                        ELSE 0
                    END AS "pop_85"
                FROM
                    population.imp_Bridged_Race_Population_Estimates_1990_2019_US
                WHERE
                    yearly_july_1st_estimates_code <> ""
                    AND age_group_code <> ""
            ) a
        GROUP BY
            state,
            year_code
    ) b
    CROSS JOIN (
        SELECT
            lpad(seq, 2, 0) AS MONTH
        FROM
            seq_1_to_12
    ) c
WHERE
    year_code >= 1999
ORDER BY
    state,
    month_code;

SELECT
    *
FROM
    population.exp_population;