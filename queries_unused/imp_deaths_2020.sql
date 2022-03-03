DROP TABLE IF EXISTS mortality.deaths_2020_state_month_age;

CREATE TABLE deaths_2020_state_month_age AS
SELECT
    state,
    month_code,
    age_group,
    SUM(deaths) AS `deaths`
FROM
    (
        SELECT
            state,
            DATE_FORMAT(`date`, '%Y/%m') AS `month_code`,
            YEAR(DATE) AS `year`,
            age_group,
            deaths
        FROM
            (
                SELECT
                    jurisdiction AS "state",
                    STR_TO_DATE(week_ending_date, '%m/%d/%Y') - INTERVAL w.day DAY AS `date`,
                    age_group,
                    m.number_of_deaths / 7 AS deaths
                FROM
                    Weekly_counts_of_deaths_by_jurisdiction_and_age_group m
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
                    ) w
                WHERE
                    m.year = 2020
                    AND TYPE = "Predicted (weighted)"
            ) a
    ) b
WHERE
    YEAR = 2020
GROUP BY
    state,
    month_code,
    age_group;