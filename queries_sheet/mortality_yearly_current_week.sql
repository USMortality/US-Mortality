-- -------------------------
DROP VIEW IF EXISTS archive.exp_delay_correction_mean_cum;

CREATE VIEW archive.exp_delay_correction_mean_cum AS
SELECT
    state,
    rank,
    mean,
    (
        SELECT
            EXP(SUM(LOG(mean)))
        FROM
            deaths.delay_correction
        WHERE
            state = a.state
            AND rank >= a.rank
    ) AS mean_cum
FROM
    deaths.delay_correction a
GROUP BY
    state,
    rank;

SELECT
    state,
    year,
    sum(adj_mortality)
FROM
    (
        SELECT
            a.state,
            a.year,
            a.week,
            CASE
                WHEN a.rank = b.rank THEN adj_mortality * mean_cum
                ELSE adj_mortality
            END adj_mortality
        FROM
            (
                SELECT
                    state,
                    year,
                    week,
                    concat(year, '_', lpad(week, 2, 0)) AS 'year_week',
                    adj_mortality,
                    rank() over (
                        PARTITION by state
                        ORDER BY
                            year_week DESC
                    ) 'rank'
                FROM
                    deaths.adj_mortality_week
                WHERE
                    year IN (2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022)
                    AND week <= (
                        SELECT
                            max(week)
                        FROM
                            deaths.adj_mortality_week
                        WHERE
                            year = 2022
                    )
                    AND state = "United States"
                GROUP BY
                    year,
                    week
            ) a
            LEFT JOIN archive.exp_delay_correction_mean_cum b ON a.state = b.state
            AND a.rank = b.rank
    ) a
GROUP BY
    year;