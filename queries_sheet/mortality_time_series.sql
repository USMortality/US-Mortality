SELECT
    year,
    week,
    adj_mortality,
    adj_mortality_baseline,
    excess_adj_mortality,
    excess_adj_mortality / adj_mortality_baseline AS 'excess_adj_mortality_pct'
FROM
    (
        SELECT
            a.year,
            a.week,
            a.adj_mortality,
            b.adj_mortality_baseline,
            a.adj_mortality - b.adj_mortality_baseline AS excess_adj_mortality
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
    ) a
GROUP BY
    year,
    week