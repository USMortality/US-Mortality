-- baseline 2020
DROP VIEW IF EXISTS deaths.baseline;

CREATE VIEW deaths.baseline AS
SELECT
    state,
    week,
    avg(adj_mortality_std) AS "baseline",
    avg(adj_mortality_std_0_24) AS "baseline_0_24",
    avg(adj_mortality_std_25_44) AS "baseline_25_44",
    avg(adj_mortality_std_45_64) AS "baseline_45_64",
    avg(adj_mortality_std_65_74) AS "baseline_65_74",
    avg(adj_mortality_std_75_84) AS "baseline_75_84",
    avg(adj_mortality_std_85) AS "baseline_85"
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
    avg(adj_mortality_std) AS "baseline",
    avg(adj_mortality_std_0_24) AS "baseline_0_24",
    avg(adj_mortality_std_25_44) AS "baseline_25_44",
    avg(adj_mortality_std_45_64) AS "baseline_45_64",
    avg(adj_mortality_std_65_74) AS "baseline_65_74",
    avg(adj_mortality_std_75_84) AS "baseline_75_84",
    avg(adj_mortality_std_85) AS "baseline_85"
FROM
    deaths.adj_mortality_week
WHERE
    year IN (2015, 2016, 2017, 2018, 2019)
    AND week = 52
GROUP BY
    state,
    week;

WITH data AS (
    SELECT
        a.state,
        b.year,
        a.week,
        baseline,
        baseline_0_24,
        baseline_25_44,
        baseline_45_64,
        baseline_65_74,
        baseline_75_84,
        baseline_85,
        adj_mortality_std - baseline AS "excess",
        adj_mortality_std_0_24 - baseline_0_24 AS "excess_0_24",
        adj_mortality_std_25_44 - baseline_25_44 AS "excess_25_44",
        adj_mortality_std_45_64 - baseline_45_64 AS "excess_45_64",
        adj_mortality_std_65_74 - baseline_65_74 AS "excess_65_74",
        adj_mortality_std_75_84 - baseline_75_84 AS "excess_75_84",
        adj_mortality_std_85 - baseline_85 AS "excess_85"
    FROM
        deaths.baseline a
        JOIN (
            SELECT
                state,
                year,
                week,
                adj_mortality_std,
                adj_mortality_std_0_24,
                adj_mortality_std_25_44,
                adj_mortality_std_45_64,
                adj_mortality_std_65_74,
                adj_mortality_std_75_84,
                adj_mortality_std_85
            FROM
                deaths.adj_mortality_week
            WHERE
                (
                    year = 2020
                    AND week >= 11
                )
                OR year > 2020
        ) b ON a.state = b.state
        AND a.week = b.week
    ORDER BY
        state,
        year,
        week
)
SELECT
    state,
    concat(year, '_', lpad(week, 2, 0)) AS 'year_week',
    sum(baseline) over (
        PARTITION by state
        ORDER BY
            year,
            week
    ) AS cum_baseline,
    sum(baseline_0_24) over (
        PARTITION by state
        ORDER BY
            year,
            week
    ) AS cum_baseline_0_24,
    sum(baseline_25_44) over (
        PARTITION by state
        ORDER BY
            year,
            week
    ) AS cum_baseline_25_44,
    sum(baseline_45_64) over (
        PARTITION by state
        ORDER BY
            year,
            week
    ) AS cum_baseline_45_64,
    sum(baseline_65_74) over (
        PARTITION by state
        ORDER BY
            year,
            week
    ) AS cum_baseline_65_74,
    sum(baseline_75_84) over (
        PARTITION by state
        ORDER BY
            year,
            week
    ) AS cum_baseline_75_84,
    sum(baseline_85) over (
        PARTITION by state
        ORDER BY
            year,
            week
    ) AS cum_baseline_85,
    sum(excess) over (
        PARTITION by state
        ORDER BY
            year,
            week
    ) AS cum_excess,
    sum(excess_0_24) over (
        PARTITION by state
        ORDER BY
            year,
            week
    ) AS cum_excess_0_24,
    sum(excess_25_44) over (
        PARTITION by state
        ORDER BY
            year,
            week
    ) AS cum_excess_25_44,
    sum(excess_45_64) over (
        PARTITION by state
        ORDER BY
            year,
            week
    ) AS cum_excess_45_64,
    sum(excess_65_74) over (
        PARTITION by state
        ORDER BY
            year,
            week
    ) AS cum_excess_65_74,
    sum(excess_75_84) over (
        PARTITION by state
        ORDER BY
            year,
            week
    ) AS cum_excess_75_84,
    sum(excess_85) over (
        PARTITION by state
        ORDER BY
            year,
            week
    ) AS cum_excess_85
FROM
    data;