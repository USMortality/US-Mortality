SELECT
    a.state,
    mortality2020_40_52,
    mortality2021_40_52,
    mortality2021_40_52 - mortality2020_40_52 AS delta
FROM
    (
        SELECT
            state,
            sum(adj_mortality_std) AS mortality2020_40_52
        FROM
            deaths.adj_mortality_week
        WHERE
            (
                year = 2020
                AND week >= 40
                AND week <= 52
            )
            OR (
                year = 2021
                AND week >= 1
                AND week <= 13
            )
        GROUP BY
            state
    ) a
    JOIN (
        SELECT
            state,
            sum(adj_mortality_std) AS mortality2021_40_52
        FROM
            deaths.adj_mortality_week
        WHERE
            (
                year = 2021
                AND week >= 40
                AND week <= 52
            )
            OR (
                year = 2022
                AND week >= 1
                AND week <= 13
            )
        GROUP BY
            state
    ) b ON a.state = b.state;