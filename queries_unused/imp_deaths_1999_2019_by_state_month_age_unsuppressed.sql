DROP TABLE IF EXISTS deaths.tran_Underlying_Cause_of_Death_1999_2019_by_state_month_age;

CREATE TABLE deaths.tran_Underlying_Cause_of_Death_1999_2019_by_state_month_age
SELECT
    state,
    left(month_code, 4) AS "year",
    right(month_code, 2) AS "month",
    tenyear_age_groups_code,
    deaths
FROM
    deaths.imp_Underlying_Cause_of_Death_1999_2019_by_state_month_age;

DROP VIEW IF EXISTS deaths.1999_2019_by_state_month_age_unsuppressed;

CREATE INDEX state_year_age ON deaths.tran_Underlying_Cause_of_Death_1999_2019_by_state_month_age (state, year, tenyear_age_groups_code);

CREATE VIEW deaths.1999_2019_by_state_month_age_unsuppressed AS
SELECT
    x.state,
    x.year,
    x.month,
    x.tenyear_age_groups_code,
    CASE
        WHEN x.deaths = "Suppressed" THEN y.suppressed_value
        ELSE x.deaths
    END AS "deaths"
FROM
    deaths.tran_Underlying_Cause_of_Death_1999_2019_by_state_month_age x
    JOIN (
        SELECT
            b.state,
            b.year,
            b.tenyear_age_groups_code,
            (c.deaths - b.total_deaths_year) / n_suppressed AS "suppressed_value"
        FROM
            (
                -- count deaths per year and suppressed cells
                SELECT
                    state,
                    year,
                    tenyear_age_groups_code,
                    sum(deaths) AS total_deaths_year,
                    sum(is_suppressed) AS n_suppressed
                FROM
                    (
                        SELECT
                            state,
                            year,
                            tenyear_age_groups_code,
                            CASE
                                WHEN deaths <> "Suppressed" THEN deaths
                                ELSE 0
                            END AS deaths,
                            CASE
                                WHEN deaths = "Suppressed" THEN 1
                                ELSE 0
                            END AS is_suppressed
                        FROM
                            deaths.tran_Underlying_Cause_of_Death_1999_2019_by_state_month_age
                        WHERE
                            state IS NOT NULL
                            AND state <> "State"
                    ) a
                GROUP BY
                    state,
                    year,
                    tenyear_age_groups_code
            ) b
            JOIN deaths.1999_2019_by_state_year_age_unsuppressed c ON b.state = c.state
            AND b.year = c.year
            AND b.tenyear_age_groups_code = c.tenyear_age_groups_code
    ) y ON x.state = y.state
    AND x.year = y.year
    AND x.tenyear_age_groups_code = y.tenyear_age_groups_code
ORDER BY
    x.state,
    x.year,
    x.tenyear_age_groups_code;