DROP TABLE IF EXISTS stringency.exp_stringency;

CREATE TABLE stringency.exp_stringency AS
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
            stringency.imp_OxCGRT_US_latest_filtered
    ) a
WHERE
    date_year = 2020
GROUP BY
    regionname,
    date_month;

SELECT
    *
FROM
    stringency.exp_stringency;