DROP VIEW IF EXISTS deaths.1999_2019_by_state_year_age_unsuppressed;

CREATE VIEW deaths.1999_2019_by_state_year_age_unsuppressed AS
SELECT
    x.state,
    x.year,
    x.tenyear_age_groups_code,
    CASE
        WHEN x.deaths = "Suppressed" THEN y.suppressed_value
        ELSE x.deaths
    END AS "deaths"
FROM
    deaths.imp_Underlying_Cause_of_Death_1999_2019_by_state_year_age x
    JOIN (
        SELECT
            b.state,
            b.year,
            (c.deaths - b.deaths) / n_suppressed AS "suppressed_value"
        FROM
            (
                -- count deaths and suppressed cells
                SELECT
                    state,
                    year,
                    sum(deaths) AS deaths,
                    sum(is_suppressed) AS n_suppressed
                FROM
                    (
                        SELECT
                            state,
                            year,
                            CASE
                                WHEN deaths <> "Suppressed" THEN deaths
                                ELSE 0
                            END AS deaths,
                            CASE
                                WHEN deaths = "Suppressed" THEN 1
                                ELSE 0
                            END AS is_suppressed
                        FROM
                            deaths.imp_Underlying_Cause_of_Death_1999_2019_by_state_year_age
                        WHERE
                            state IS NOT NULL
                    ) a
                GROUP BY
                    state,
                    year
            ) b
            JOIN -- total deaths
            deaths.imp_Underlying_Cause_of_Death_1999_2019_by_state_year c ON b.state = c.state
            AND b.year = c.year
    ) y ON x.state = y.state
    AND x.year = y.year
ORDER BY
    x.state,
    x.year,
    x.tenyear_age_groups_code;