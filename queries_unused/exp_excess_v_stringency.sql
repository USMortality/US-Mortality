SELECT
    *
FROM
    (
        SELECT
            x.state,
            x.month,
            y.adj_mortality - x.adj_mortality_avg3 AS excess_mortality
        FROM
            (
                SELECT
                    state,
                    MONTH,
                    -- min(adj_mortality) AS "adj_mortality_min3",
                    -- max(adj_mortality) AS "adj_mortality_max3",
                    avg(adj_mortality) AS "adj_mortality_avg3"
                FROM
                    adj_mortality
                WHERE
                    year IN (2017, 2018, 2019)
                GROUP BY
                    state,
                    MONTH
            ) x
            JOIN (
                SELECT
                    *
                FROM
                    adj_mortality
                WHERE
                    year = 2020
            ) y ON x.state = y.state
            AND x.month = y.month
    ) a
    JOIN (
        -- stringency
        SELECT
            CASE
                WHEN regionname = "" THEN "United States"
                WHEN regionname = "Washington DC" THEN "District of Columbia"
                ELSE regionname
            END AS "regionname",
            date_month,
            round(sum(stringencyindex)) AS "monthly_stringency_sum"
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
            date_month
    ) b ON a.state = b.regionname
    AND a.month = b.date_month
ORDER BY
    state,
    MONTH