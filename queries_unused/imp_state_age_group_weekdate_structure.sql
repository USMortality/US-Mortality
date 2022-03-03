-- Create expected structure: 6 age groups per state
DROP TABLE IF EXISTS deaths.imp_state_age_group_weekdate_structure;

CREATE TABLE deaths.imp_state_age_group_weekdate_structure AS
SELECT
    *
FROM
    (
        SELECT
            DISTINCT jurisdiction
        FROM
            deaths.imp_Weekly_counts_of_deaths_by_jurisdiction_and_age_group
    ) a
    CROSS JOIN (
        SELECT
            DISTINCT age_group
        FROM
            deaths.imp_Weekly_counts_of_deaths_by_jurisdiction_and_age_group -- WHERE
    ) b
    CROSS JOIN (
        SELECT
            DISTINCT week_ending_date
        FROM
            deaths.imp_Weekly_counts_of_deaths_by_jurisdiction_and_age_group
        WHERE
            year IN (2020, 2021)
    ) c;

CREATE INDEX state_age_week ON deaths.imp_state_age_group_weekdate_structure (jurisdiction, age_group, week_ending_date);