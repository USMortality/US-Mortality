-- yearly stringency
SELECT
    *
FROM
    (
        SELECT
            CASE
                WHEN regionname = "" THEN "United States"
                WHEN regionname = "Washington DC" THEN "District of Columbia"
                ELSE regionname
            END AS "state",
            date_year,
            (sum(stringencyindex) / (366 * 100)) AS "yearly_stringency_sum"
        FROM
            (
                SELECT
                    regionname,
                    year(STR_TO_DATE(date, '%Y%m%d')) AS 'date_year',
                    MONTH(STR_TO_DATE(date, '%Y%m%d')) AS 'date_month',
                    stringencyindex
                FROM
                    OxCGRT_US_latest
            ) a
        WHERE
            date_year = 2020
        GROUP BY
            regionname,
            date_year
    ) x
    JOIN (
        -- 2020 vs 5y excess
        SELECT
            a.state,
            adj_mortality_2020,
            adj_mortality_avg5,
            (adj_mortality_2020 - adj_mortality_avg5) AS "excess_mortality",
            (adj_mortality_2020 - adj_mortality_avg5) / adj_mortality_avg5 AS "excess_mortality_incr"
        FROM
            (
                -- 5y avg
                SELECT
                    state,
                    sum(adj_mortality) / 5 AS "adj_mortality_avg5"
                FROM
                    adj_mortality
                WHERE
                    year IN (2015, 2016, 2017, 2018, 2019)
                GROUP BY
                    state
            ) a
            JOIN (
                SELECT
                    state,
                    sum(adj_mortality) AS "adj_mortality_2020"
                FROM
                    adj_mortality
                WHERE
                    year = 2020
                GROUP BY
                    state
            ) b ON a.state = b.state
    ) y ON x.state = y.state
ORDER BY
    x.state -- AND excess_mortality_incr desc