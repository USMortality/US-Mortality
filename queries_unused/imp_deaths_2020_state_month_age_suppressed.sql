DROP VIEW IF EXISTS deaths.2020_state_month_age_suppressed;

CREATE VIEW deaths.2020_state_month_age_suppressed AS
SELECT
    state,
    MONTH,
    age_group AS "tenyear_age_groups_code",
    CASE
        WHEN weeks_suppressed = 0 THEN deaths
        ELSE "Suppressed"
    END AS deaths
FROM
    (
        SELECT
            state,
            age_group,
            MONTH,
            sum(deaths) AS deaths,
            sum(
                CASE
                    WHEN deaths = 0 THEN 1
                    ELSE 0
                END
            ) AS weeks_suppressed
        FROM
            deaths.daily_counts_of_deaths_by_jurisdiction_and_age_group
        WHERE
            year = 2020
        GROUP BY
            state,
            MONTH,
            age_group
    ) z
ORDER BY
    state,
    MONTH,
    age_group;