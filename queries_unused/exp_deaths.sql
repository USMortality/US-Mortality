DROP VIEW IF EXISTS deaths.deaths_1999_2009_US;

CREATE VIEW deaths.deaths_1999_2009_US AS
SELECT
    state,
    concat(year, "/", MONTH) AS month_code,
    CASE
        WHEN tenyear_age_groups_code = "1" THEN deaths
        WHEN tenyear_age_groups_code = "1-4" THEN deaths
        WHEN tenyear_age_groups_code = "5-14" THEN deaths
        WHEN tenyear_age_groups_code = "15-24" THEN deaths
        ELSE 0
    END AS "deaths_0_24",
    CASE
        WHEN tenyear_age_groups_code = "25-34" THEN deaths
        WHEN tenyear_age_groups_code = "35-44" THEN deaths
        ELSE 0
    END AS "deaths_25_44",
    CASE
        WHEN tenyear_age_groups_code = "45-54" THEN deaths
        WHEN tenyear_age_groups_code = "55-64" THEN deaths
        ELSE 0
    END AS "deaths_45_64",
    CASE
        WHEN tenyear_age_groups_code = "65-74" THEN deaths
        ELSE 0
    END AS "deaths_65_74",
    CASE
        WHEN tenyear_age_groups_code = "75-84" THEN deaths
        ELSE 0
    END AS "deaths_75_84",
    CASE
        WHEN tenyear_age_groups_code = "85+" THEN deaths
        ELSE 0
    END AS "deaths_85"
FROM
    deaths.1999_2019_by_state_month_age_unsuppressed
WHERE
    tenyear_age_groups_code IN (
        "1",
        "1-4",
        "5-14",
        "15-24",
        "25-34",
        "35-44",
        "45-54",
        "55-64",
        "65-74",
        "75-84",
        "85+"
    );

DROP VIEW IF EXISTS deaths.deaths_1999_2009_States;

CREATE VIEW deaths.deaths_1999_2009_States AS -- 1999-2009 United States
SELECT
    "United States" AS "state",
    month_code,
    CASE
        WHEN tenyear_age_groups_code = "1" THEN deaths
        WHEN tenyear_age_groups_code = "1-4" THEN deaths
        WHEN tenyear_age_groups_code = "5-14" THEN deaths
        WHEN tenyear_age_groups_code = "15-24" THEN deaths
        ELSE 0
    END AS "deaths_0_24",
    CASE
        WHEN tenyear_age_groups_code = "25-34" THEN deaths
        WHEN tenyear_age_groups_code = "35-44" THEN deaths
        ELSE 0
    END AS "deaths_25_44",
    CASE
        WHEN tenyear_age_groups_code = "45-54" THEN deaths
        WHEN tenyear_age_groups_code = "55-64" THEN deaths
        ELSE 0
    END AS "deaths_45_64",
    CASE
        WHEN tenyear_age_groups_code = "65-74" THEN deaths
        ELSE 0
    END AS "deaths_65_74",
    CASE
        WHEN tenyear_age_groups_code = "75-84" THEN deaths
        ELSE 0
    END AS "deaths_75_84",
    CASE
        WHEN tenyear_age_groups_code = "85+" THEN deaths
        ELSE 0
    END AS "deaths_85"
FROM
    deaths.imp_Underlying_Cause_of_Death_1999_2019
WHERE
    tenyear_age_groups_code IN (
        "1",
        "1-4",
        "5-14",
        "15-24",
        "25-34",
        "35-44",
        "45-54",
        "55-64",
        "65-74",
        "75-84",
        "85+"
    );

DROP VIEW IF EXISTS deaths.deaths_2020;

CREATE VIEW deaths.deaths_2020 AS
SELECT
    -- 2020
    state,
    concat("2020/", MONTH) AS "month_code",
    CASE
        WHEN tenyear_age_groups_code = "0-24" THEN deaths
        ELSE 0
    END AS "deaths_0_24",
    CASE
        WHEN tenyear_age_groups_code = "25-44" THEN deaths
        ELSE 0
    END AS "deaths_25_44",
    CASE
        WHEN tenyear_age_groups_code = "45-64" THEN deaths
        ELSE 0
    END AS "deaths_45_64",
    CASE
        WHEN tenyear_age_groups_code = "65-74" THEN deaths
        ELSE 0
    END AS "deaths_65_74",
    CASE
        WHEN tenyear_age_groups_code = "75-84" THEN deaths
        ELSE 0
    END AS "deaths_75_84",
    CASE
        WHEN tenyear_age_groups_code = "85+" THEN deaths
        ELSE 0
    END AS "deaths_85"
FROM
    deaths.2020_state_month_age_unsuppressed;

DROP TABLE IF EXISTS deaths.exp_deaths;

CREATE TABLE deaths.exp_deaths AS
SELECT
    state,
    month_code,
    SUM(deaths_0_24) AS deaths_0_24,
    SUM(deaths_25_44) AS deaths_25_44,
    SUM(deaths_45_64) AS deaths_45_64,
    SUM(deaths_65_74) AS deaths_65_74,
    SUM(deaths_75_84) AS deaths_75_84,
    SUM(deaths_85) AS deaths_85
FROM
    (
        SELECT
            *
        FROM
            deaths.deaths_1999_2009_US
        UNION
        ALL
        SELECT
            *
        FROM
            deaths.deaths_1999_2009_States
        UNION
        ALL
        SELECT
            *
        FROM
            deaths.deaths_2020
    ) a
WHERE
    state <> "Puerto Rico"
GROUP BY
    state,
    month_code
ORDER BY
    state,
    month_code;

SELECT
    *
FROM
    deaths.exp_deaths;