DROP VIEW IF EXISTS deaths.2020_state_month_age_unsuppressed_5yavg;

CREATE VIEW deaths.2020_state_month_age_unsuppressed_5yavg AS
SELECT
    a.state,
    a.MONTH,
    a.tenyear_age_groups_code,
    CASE
        WHEN a.deaths <> "Suppressed" THEN a.deaths
        ELSE 0
    END AS deaths,
    CASE
        WHEN a.deaths <> "Suppressed" THEN 0
        ELSE b.deaths_5y_avg
    END AS deaths_suppressed
FROM
    deaths.2020_state_month_age_suppressed a
    LEFT JOIN (
        -- 5y average
        SELECT
            state,
            MONTH,
            tenyear_age_groups_code,
            sum(deaths) / 5 AS "deaths_5y_avg"
        FROM
            (
                SELECT
                    state,
                    MONTH,
                    CASE
                        WHEN tenyear_age_groups_code = "1" THEN "0-24"
                        WHEN tenyear_age_groups_code = "1-4" THEN "0-24"
                        WHEN tenyear_age_groups_code = "5-14" THEN "0-24"
                        WHEN tenyear_age_groups_code = "15-24" THEN "0-24"
                        WHEN tenyear_age_groups_code = "25-34" THEN "25-44"
                        WHEN tenyear_age_groups_code = "35-44" THEN "25-44"
                        WHEN tenyear_age_groups_code = "45-54" THEN "45-64"
                        WHEN tenyear_age_groups_code = "55-64" THEN "45-64"
                        WHEN tenyear_age_groups_code = "65-74" THEN "65-74"
                        WHEN tenyear_age_groups_code = "75-84" THEN "75-84"
                        WHEN tenyear_age_groups_code = "85+" THEN "85+"
                    END AS "tenyear_age_groups_code",
                    deaths
                FROM
                    deaths.1999_2019_by_state_month_age_unsuppressed
                WHERE
                    year IN (2015, 2016, 2017, 2018, 2019)
            ) a
        GROUP BY
            state,
            MONTH,
            tenyear_age_groups_code
    ) b ON a.state = b.state
    AND a.month = b.month
    AND a.tenyear_age_groups_code = b.tenyear_age_groups_code
ORDER BY
    a.state,
    a.month,
    a.tenyear_age_groups_code;

DROP VIEW IF EXISTS deaths.2020_state_month_age_unsuppressed;

CREATE VIEW deaths.2020_state_month_age_unsuppressed AS
SELECT
    a.state,
    a.MONTH,
    a.tenyear_age_groups_code,
    CASE
        WHEN a.deaths = 0 THEN (a.deaths_suppressed * b.corr_factor)
        ELSE a.deaths
    END AS deaths
FROM
    deaths.2020_state_month_age_unsuppressed_5yavg a
    JOIN (
        SELECT
            a.state,
            a.deaths_actual,
            a.deaths_historical,
            a.deaths_actual + a.deaths_historical AS deaths_est,
            b.deaths,
            (b.deaths - a.deaths_actual) / a.deaths_historical AS corr_factor
        FROM
            (
                -- totals, w/ interpolated deaths per state.
                SELECT
                    state,
                    sum(deaths) AS deaths_actual,
                    sum(deaths_suppressed) AS deaths_historical
                FROM
                    deaths.2020_state_month_age_unsuppressed_5yavg
                GROUP BY
                    state
            ) a
            JOIN (
                -- Actual total deaths per state.
                SELECT
                    state,
                    sum(deaths) AS deaths
                FROM
                    deaths.2020_state_month
                GROUP BY
                    state
            ) b ON a.state = b.state
    ) b ON a.state = b.state
ORDER BY
    state,
    MONTH,
    tenyear_age_groups_code;