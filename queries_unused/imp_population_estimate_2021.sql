-- create view with population numbers (uncorrected for total pop) per age bracket for 2021
DROP VIEW IF EXISTS population.estimate_2021;

CREATE VIEW population.estimate_2021 AS
SELECT
    state,
    round(pop_0_24_20 * (pop_0_24_20 / pop_0_24_19)) AS pop_0_24,
    round(pop_25_44_20 * (pop_25_44_20 / pop_25_44_19)) AS pop_25_44,
    round(pop_45_64_20 * (pop_45_64_20 / pop_45_64_19)) AS pop_45_64,
    round(pop_65_74_20 * (pop_65_74_20 / pop_65_74_19)) AS pop_65_74,
    round(pop_75_84_20 * (pop_75_84_20 / pop_75_84_19)) AS pop_75_84,
    round(pop_85_20 * (pop_85_20 / pop_85_19)) AS pop_85,
    round(pop_total_20 * (pop_total_20 / pop_total_19)) AS pop_total
FROM
    (
        SELECT
            a.state,
            a.pop_0_24 AS "pop_0_24_19",
            b.pop_0_24 AS "pop_0_24_20",
            a.pop_25_44 AS "pop_25_44_19",
            b.pop_25_44 AS "pop_25_44_20",
            a.pop_45_64 AS "pop_45_64_19",
            b.pop_45_64 AS "pop_45_64_20",
            a.pop_65_74 AS "pop_65_74_19",
            b.pop_65_74 AS "pop_65_74_20",
            a.pop_75_84 AS "pop_75_84_19",
            b.pop_75_84 AS "pop_75_84_20",
            a.pop_85 AS "pop_85_19",
            b.pop_85 AS "pop_85_20",
            a.pop_total AS "pop_total_19",
            b.pop_total AS "pop_total_20"
        FROM
            population.exp_population a
            JOIN population.exp_population b ON a.state = b.state
            AND a.month_code = '2019/01'
            AND b.month_code = '2020/01'
    ) a;

DROP VIEW IF EXISTS population.population_1999_2021;

CREATE VIEW population.population_1999_2021 AS
SELECT
    DISTINCT state,
    left(month_code, 4) AS year,
    pop_0_24,
    pop_25_44,
    pop_45_64,
    pop_65_74,
    pop_75_84,
    pop_85,
    pop_total
FROM
    population.exp_population
WHERE
    left(month_code, 4) > 2014
UNION
ALL
SELECT
    state,
    2021 AS year,
    pop_0_24,
    pop_25_44,
    pop_45_64,
    pop_65_74,
    pop_75_84,
    pop_85,
    pop_total
FROM
    population.estimate_2021
ORDER BY
    state,
    year;