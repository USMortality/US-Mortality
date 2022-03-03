DROP VIEW IF EXISTS deaths.2020_state_month;

CREATE VIEW deaths.2020_state_month AS
SELECT
    state,
    MONTH(date) AS "month",
    round(sum(deaths)) AS "deaths"
FROM
    (
        SELECT
            state,
            STR_TO_DATE(week_ending_date, '%Y-%m-%d') - INTERVAL b.day DAY AS `date`,
            a.observed_number / 7 AS deaths
        FROM
            (
                SELECT
                    *
                FROM
                    deaths.imp_National_and_state_estimates_of_excess_deaths
                WHERE
                    outcome = "All causes"
                    AND TYPE = "Predicted (weighted)"
            ) a
            CROSS JOIN (
                SELECT
                    0 AS DAY
                UNION
                SELECT
                    1
                UNION
                SELECT
                    2
                UNION
                SELECT
                    3
                UNION
                SELECT
                    4
                UNION
                SELECT
                    5
                UNION
                SELECT
                    6
            ) b
    ) x
WHERE
    year(date) = 2020
GROUP BY
    state,
    MONTH(date)