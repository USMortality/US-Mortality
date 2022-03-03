DROP VIEW IF EXISTS baseline;

-- 5y avg baseline; use week 52 data for week 53
CREATE VIEW baseline AS
SELECT
    state,
    week,
    AVG(mortality_0_24) AS "mortality_0_24_avg",
    STDDEV(mortality_0_24) AS "mortality_0_24_sd",
    AVG(mortality_25_44) AS "mortality_25_44_avg",
    STDDEV(mortality_25_44) AS "mortality_25_44_sd",
    AVG(mortality_45_64) AS "mortality_45_64_avg",
    STDDEV(mortality_45_64) AS "mortality_45_64_sd",
    AVG(mortality_65_74) AS "mortality_65_74_avg",
    STDDEV(mortality_65_74) AS "mortality_65_74_sd",
    AVG(mortality_75_84) AS "mortality_75_84_avg",
    STDDEV(mortality_75_84) AS "mortality_75_84_sd",
    AVG(mortality_85) AS "mortality_85_avg",
    STDDEV(mortality_85) AS "mortality_85_sd",
    AVG(adj_mortality) AS "adj_mortality_avg",
    STDDEV(adj_mortality) AS "adj_mortality_sd",
    AVG(adj_mortality_std) AS "adj_mortality_std_avg",
    STDDEV(adj_mortality_std) AS "adj_mortality_std_sd"
FROM
    deaths.adj_mortality_week
WHERE
    year IN (2015, 2016, 2017, 2018, 2019)
GROUP BY
    state,
    week
UNION
ALL
SELECT
    state,
    53 AS week,
    AVG(mortality_0_24) AS "mortality_0_24_avg",
    STDDEV(mortality_0_24) AS "mortality_0_24_sd",
    AVG(mortality_25_44) AS "mortality_25_44_avg",
    STDDEV(mortality_25_44) AS "mortality_25_44_sd",
    AVG(mortality_45_64) AS "mortality_45_64_avg",
    STDDEV(mortality_45_64) AS "mortality_45_64_sd",
    AVG(mortality_65_74) AS "mortality_65_74_avg",
    STDDEV(mortality_65_74) AS "mortality_65_74_sd",
    AVG(mortality_75_84) AS "mortality_75_84_avg",
    STDDEV(mortality_75_84) AS "mortality_75_84_sd",
    AVG(mortality_85) AS "mortality_85_avg",
    STDDEV(mortality_85) AS "mortality_85_sd",
    AVG(adj_mortality) AS "adj_mortality_avg",
    STDDEV(adj_mortality) AS "adj_mortality_sd",
    AVG(adj_mortality_std) AS "adj_mortality_std_avg",
    STDDEV(adj_mortality_std) AS "adj_mortality_std_sd"
FROM
    deaths.adj_mortality_week
WHERE
    year IN (2015, 2016, 2017, 2018, 2019)
    AND week = 52
GROUP BY
    state,
    week;

-- Final Query
DROP TABLE IF EXISTS exp_mortality_week;

CREATE TABLE exp_mortality_week AS
SELECT
    a.state,
    a.year,
    a.week,
    concat(a.year, '_', lpad(a.week, 2, 0)) AS 'year_week',
    deaths_0_24,
    deaths_25_44,
    deaths_45_64,
    deaths_65_74,
    deaths_75_84,
    deaths_85,
    deaths,
    deaths_covid,
    deaths - deaths_covid AS "deaths_non_covid",
    adj_mortality_std,
    round(adj_mortality_sd / 100000 * pop_total) AS 'stddv_abs',
    round(adj_mortality_std_sd) AS 'sdddv_std',
    round(mortality_0_24_sd / 100000 * pop_0_24) AS 'stddv_0_24_abs',
    round(mortality_25_44_sd / 100000 * pop_25_44) AS 'stddv_25_44_abs',
    round(mortality_45_64_sd / 100000 * pop_45_64) AS 'stddv_45_64_abs',
    round(mortality_65_74_sd / 100000 * pop_65_74) AS 'stddv_65_74_abs',
    round(mortality_75_84_sd / 100000 * pop_75_84) AS 'stddv_75_84_abs',
    round(mortality_85_sd / 100000 * pop_85) AS 'stddv_85_abs',
    round(adj_mortality_avg / 100000 * pop_total) AS 'baseline',
    round(adj_mortality_std_avg) AS 'baseline_std',
    round(mortality_0_24_avg / 100000 * pop_0_24) AS 'baseline_0_24',
    round(mortality_25_44_avg / 100000 * pop_25_44) AS 'baseline_25_44',
    round(mortality_45_64_avg / 100000 * pop_45_64) AS 'baseline_45_64',
    round(mortality_65_74_avg / 100000 * pop_65_74) AS 'baseline_65_74',
    round(mortality_75_84_avg / 100000 * pop_75_84) AS 'baseline_75_84',
    round(mortality_85_avg / 100000 * pop_85) AS 'baseline_85'
FROM
    deaths.adj_mortality_week a
    JOIN deaths.baseline b
    JOIN deaths.covid_week c ON a.state = b.state
    AND a.week = b.week
    AND a.state = c.state
    AND a.year = c.year
    AND a.week = c.week
ORDER BY
    state,
    year_week;

SELECT
    *
FROM
    exp_mortality_week;