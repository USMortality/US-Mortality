SELECT
    a.year,
    a.week,
    sum(excess_adj_mortality_capita) * pop_total_all / 100000 AS excess_ttl
FROM
    (
        SELECT
            a.state,
            a.year,
            a.week,
            a.adj_mortality,
            b.adj_mortality_baseline,
            a.adj_mortality - b.adj_mortality_baseline AS excess_adj_mortality,
            (a.adj_mortality - b.adj_mortality_baseline) / a.pop_total AS excess_adj_mortality_capita
        FROM
            (
                SELECT
                    `state`,
                    year,
                    week,
                    adj_mortality,
                    pop_total
                FROM
                    deaths.adj_mortality_week_predicted
                WHERE
                    year IN (2020, 2021, 2022)
                    AND `state` IN (
                        "Vermont",
                        "Massachusetts",
                        "Maryland",
                        "Hawaii",
                        "California",
                        "New York",
                        "Rhode Island",
                        "Connecticut",
                        "Washington",
                        "Delaware",
                        "Illinois",
                        "Oregon",
                        "New Jersey"
                    ) -- AND year = 2020
                    -- AND week = 15
                GROUP BY
                    `state`,
                    year,
                    week
            ) a
            JOIN (
                SELECT
                    `state`,
                    week,
                    AVG(adj_mortality) AS adj_mortality_baseline
                FROM
                    deaths.adj_mortality_week_predicted
                WHERE
                    year IN (2015, 2016, 2017, 2018, 2019)
                GROUP BY
                    `state`,
                    week
            ) b ON a.state = b.state
            AND a.week = b.week
    ) a
    JOIN (
        SELECT
            year,
            week,
            sum(pop_total) AS pop_total_all
        FROM
            deaths.adj_mortality_week_predicted
        WHERE
            year IN (2020, 2021, 2022)
            AND `state` IN (
                "Vermont",
                "Massachusetts",
                "Maryland",
                "Hawaii",
                "California",
                "New York",
                "Rhode Island",
                "Connecticut",
                "Washington",
                "Delaware",
                "Illinois",
                "Oregon",
                "New Jersey"
            ) -- AND year = 2020
            -- AND week = 15
        GROUP BY
            year,
            week
    ) b ON a.year = b.year
    AND b.week = b.week
GROUP BY
    year,
    week