-- baseline 2020
DROP VIEW IF EXISTS deaths.baseline;

CREATE VIEW deaths.baseline AS
SELECT
    state,
    sum(baseline) AS baseline
FROM
    (
        -- 2020
        SELECT
            state,
            avg(adj_mortality_std) AS "baseline"
        FROM
            deaths.adj_mortality_week
        WHERE
            year IN (2015, 2016, 2017, 2018, 2019)
            AND week >= 11
        GROUP BY
            state,
            week
        UNION
        ALL -- 2020, week 53
        SELECT
            state,
            avg(adj_mortality_std) AS "baseline"
        FROM
            deaths.adj_mortality_week
        WHERE
            year IN (2015, 2016, 2017, 2018, 2019)
            AND week = 52
        GROUP BY
            state,
            week
        UNION
        ALL -- 2021
        SELECT
            state,
            avg(adj_mortality_std) AS "baseline"
        FROM
            deaths.adj_mortality_week
        WHERE
            year IN (2015, 2016, 2017, 2018, 2019)
            AND week <= 49
        GROUP BY
            state,
            week
    ) a
GROUP BY
    state;

SELECT
    a.state,
    mortality,
    baseline,
    mortality / baseline -1 AS excess
FROM
    deaths.baseline a
    JOIN (
        SELECT
            state,
            sum(adj_mortality_std) AS mortality
        FROM
            deaths.adj_mortality_week
        WHERE
            (
                year = 2020
                AND week >= 11
            )
            OR (
                year = 2021
                AND week <= 49
            )
        GROUP BY
            state
    ) b ON a.state = b.state
ORDER BY
    excess DESC;