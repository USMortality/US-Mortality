SELECT
    a.state,
    (adj_0_24_2020 / adj_0_24_avg5) -1,
    (adj_25_44_2020 / adj_25_44_avg5) -1,
    (adj_45_64_2020 / adj_45_64_avg5) -1,
    (adj_65_74_2020 / adj_65_74_avg5) -1,
    (adj_75_84_2020 / adj_75_84_avg5) -1,
    (adj_85_2020 / adj_85_avg5) -1,
    (
        adj_0_24_2020 + adj_25_44_2020 + adj_45_64_2020 + adj_65_74_2020 + adj_75_84_2020 + adj_85_2020
    ) / (
        adj_0_24_avg5 + adj_25_44_avg5 + adj_45_64_avg5 + adj_65_74_avg5 + adj_75_84_avg5 + adj_85_avg5
    ) AS "total"
FROM
    (
        -- avg 
        SELECT
            state,
            sum(adj_0_24) / 5 AS "adj_0_24_avg5",
            sum(adj_25_44) / 5 AS "adj_25_44_avg5",
            sum(adj_45_64) / 5 AS "adj_45_64_avg5",
            sum(adj_65_74) / 5 AS "adj_65_74_avg5",
            sum(adj_75_84) / 5 AS "adj_75_84_avg5",
            sum(adj_85) / 5 AS "adj_85_avg5"
        FROM
            adj_mortality
        WHERE
            year IN (2015, 2016, 2017, 2018, 2019)
            AND state = "California"
        GROUP BY
            state
    ) a
    JOIN (
        SELECT
            state,
            sum(adj_0_24) AS "adj_0_24_2020",
            sum(adj_25_44) AS "adj_25_44_2020",
            sum(adj_45_64) AS "adj_45_64_2020",
            sum(adj_65_74) AS "adj_65_74_2020",
            sum(adj_75_84) AS "adj_75_84_2020",
            sum(adj_85) AS "adj_85_2020"
        FROM
            adj_mortality
        WHERE
            year = 2020
        GROUP BY
            state
    ) b ON a.state = b.state -- WHERE
    --     b.state = "California"