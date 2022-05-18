DROP VIEW IF EXISTS deaths.mortality_lreg;

CREATE VIEW deaths.mortality_lreg AS
SELECT
    slope,
    y_bar_max - x_bar_max * slope AS intercept
FROM
    (
        SELECT
            sum((x - x_bar) * (y - y_bar)) / sum((x - x_bar) * (x - x_bar)) AS slope,
            max(x_bar) AS x_bar_max,
            max(y_bar) AS y_bar_max
        FROM
            (
                SELECT
                    x,
                    avg(x) over () AS x_bar,
                    y,
                    avg(y) over () AS y_bar
                FROM
                    (
                        SELECT
                            year AS x,
                            sum(adj_mortality) AS y
                        FROM
                            deaths.adj_mortality_week_predicted
                        WHERE
                            year IN (2015, 2016, 2017, 2018, 2019)
                            AND state = "United States"
                            AND week <= 52
                        GROUP BY
                            year
                        ORDER BY
                            year
                    ) a
            ) a
    ) a;

DROP VIEW IF EXISTS deaths.mortality_baseline_correction;

CREATE VIEW deaths.mortality_baseline_correction AS
SELECT
    year,
    b.baseline / a.baseline AS baseline_correction
FROM
    (
        SELECT
            avg(year * slope + intercept) AS baseline
        FROM
            (
                SELECT
                    2015 AS year
                UNION
                SELECT
                    2016 AS year
                UNION
                SELECT
                    2017 AS year
                UNION
                SELECT
                    2018 AS year
                UNION
                SELECT
                    2019 AS year
            ) a
            JOIN deaths.mortality_lreg b
    ) a
    JOIN (
        SELECT
            year,
            year * slope + intercept AS baseline
        FROM
            (
                SELECT
                    2020 AS year
                UNION
                SELECT
                    2021 AS year
                UNION
                SELECT
                    2022 AS year
            ) a
            JOIN deaths.mortality_lreg b
    ) b;

SELECT
    a.year,
    a.week,
    a.adj_mortality,
    @bl := b.adj_mortality_baseline * c.baseline_correction 'baseline',
    a.adj_mortality - @bl AS "excess_adj_mortality",
    a.adj_mortality / @bl -1 AS "excess_adj_mortality_pct"
FROM
    (
        SELECT
            year,
            week,
            adj_mortality
        FROM
            deaths.adj_mortality_week_predicted
        WHERE
            year IN (2020, 2021, 2022)
            AND `state` = "United States"
        GROUP BY
            year,
            week
    ) a
    JOIN (
        SELECT
            week,
            AVG(adj_mortality) AS adj_mortality_baseline
        FROM
            deaths.adj_mortality_week_predicted
        WHERE
            year IN (2015, 2016, 2017, 2018, 2019)
            AND `state` = "United States"
        GROUP BY
            week
    ) b ON a.week = b.week
    JOIN deaths.mortality_baseline_correction c ON a.year = c.year;