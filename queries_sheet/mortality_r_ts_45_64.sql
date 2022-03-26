SELECT
    concat(a.year, '_', lpad(a.week, 2, 0)) AS 'year_week',
    a.year,
    a.week,
    sum(excess_adj_mortality_capita) * pop_45_64_all / 100000 AS excess_ttl
FROM
    (
        SELECT
            a.state,
            a.year,
            a.week,
            a.adj_mortality,
            b.adj_mortality_baseline,
            a.adj_mortality / b.adj_mortality_baseline -1 AS excess_adj_mortality,
            ((a.adj_mortality / b.adj_mortality_baseline) -1) / a.pop AS excess_adj_mortality_capita
        FROM
            (
                SELECT
                    `state`,
                    year,
                    week,
                    adj_mortality_45_64 AS adj_mortality,
                    pop_45_64 AS pop
                FROM
                    deaths.adj_mortality_week
                WHERE
                    year IN (2020, 2021, 2022)
                    AND `state` IN (
                        "Alaska",
                        "South Carolina",
                        "Kansas",
                        "Missouri",
                        "Indiana",
                        "Montana",
                        "Mississippi",
                        "Louisiana",
                        "Nebraska",
                        "Utah",
                        "Tennessee",
                        "Alabama",
                        "Kentucky",
                        "South Dakota",
                        "Arkansas",
                        "Idaho",
                        "Oklahoma",
                        "North Dakota",
                        "West Virginia",
                        "Wyoming"
                    )
                GROUP BY
                    `state`,
                    year,
                    week
            ) a
            JOIN (
                SELECT
                    `state`,
                    week,
                    AVG(adj_mortality_45_64) AS adj_mortality_baseline
                FROM
                    deaths.adj_mortality_week
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
            sum(pop_45_64) AS pop_45_64_all
        FROM
            deaths.adj_mortality_week
        WHERE
            year IN (2020, 2021, 2022)
            AND `state` IN (
                "Alaska",
                "South Carolina",
                "Kansas",
                "Missouri",
                "Indiana",
                "Montana",
                "Mississippi",
                "Louisiana",
                "Nebraska",
                "Utah",
                "Tennessee",
                "Alabama",
                "Kentucky",
                "South Dakota",
                "Arkansas",
                "Idaho",
                "Oklahoma",
                "North Dakota",
                "West Virginia",
                "Wyoming"
            )
        GROUP BY
            year,
            week
    ) b ON a.year = b.year
    AND b.week = b.week
GROUP BY
    year,
    week