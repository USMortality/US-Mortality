DROP TABLE IF EXISTS deaths.daily_counts_of_deaths_by_jurisdiction_and_age_group;

CREATE INDEX state_age_week ON deaths.imp_Weekly_counts_of_deaths_by_jurisdiction_and_age_group (jurisdiction, age_group, week_ending_date);

CREATE TABLE deaths.daily_counts_of_deaths_by_jurisdiction_and_age_group AS
SELECT
    state,
    age_group,
    date,
    DATE_FORMAT(`date`, '%m') AS 'month',
    year(date) AS 'year',
    deaths
FROM
    (
        SELECT
            a.state,
            CASE
                WHEN age_group = "25-44 years" THEN "25-44"
                WHEN age_group = "45-64 years" THEN "45-64"
                WHEN age_group = "65-74 years" THEN "65-74"
                WHEN age_group = "75-84 years" THEN "75-84"
                WHEN age_group = "85 years and older" THEN "85+"
                WHEN age_group = "Under 25 years" THEN "0-24"
            END AS "age_group",
            STR_TO_DATE(week_ending_date, '%m/%d/%Y') - INTERVAL b.seq DAY AS "date",
            a.number_of_deaths / 7 AS deaths
        FROM
            (
                SELECT
                    CASE
                        WHEN a.jurisdiction IN ("New York", "New York City") THEN "New York"
                        ELSE a.jurisdiction
                    END AS "state",
                    a.age_group,
                    a.week_ending_date,
                    CASE
                        WHEN b.number_of_deaths IS NULL
                        OR b.number_of_deaths = '' THEN 0
                        ELSE cast(b.number_of_deaths AS DECIMAL)
                    END AS number_of_deaths
                FROM
                    deaths.imp_state_age_group_weekdate_structure a
                    LEFT JOIN deaths.imp_Weekly_counts_of_deaths_by_jurisdiction_and_age_group b ON a.jurisdiction = b.jurisdiction
                    AND a.age_group = b.age_group
                    AND a.week_ending_date = b.week_ending_date
                    AND b.type = "Predicted (weighted)"
            ) a
            CROSS JOIN seq_0_to_6 b
    ) a;

CREATE INDEX year ON deaths.daily_counts_of_deaths_by_jurisdiction_and_age_group (year);