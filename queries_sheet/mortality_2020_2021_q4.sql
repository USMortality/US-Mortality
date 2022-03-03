SELECT
    a.state,
    mortality2020_40_52,
    mortality2021_40_52,
    mortality2021_40_52 - mortality2020_40_52 AS delta
FROM
    (
        SELECT
            year,
            state,
            sum(adj_mortality_std) AS mortality2020_40_52
        FROM
            deaths.adj_mortality_week
        WHERE
            year = 2020
            AND week >= 40
            AND week <= 52
        GROUP BY
            state
    ) a
    JOIN (
        SELECT
            year,
            state,
            sum(adj_mortality_std) AS mortality2021_40_52
        FROM
            deaths.adj_mortality_week
        WHERE
            year = 2021
            AND week >= 40
            AND week <= 52
            AND state IN (
                SELECT
                    state
                FROM
                    deaths.adj_mortality_week
                WHERE
                    adj_mortality_std > 0
                    AND year = 2021
                    AND week = 52
            )
        GROUP BY
            state
    ) b ON a.state = b.state;