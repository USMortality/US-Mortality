SELECT
    DISTINCT jurisdiction
FROM
    deaths.imp_state_age_group_weekdate_structure;

SELECT
    DISTINCT age_group
FROM
    deaths.imp_state_age_group_weekdate_structure;

SELECT
    count(*)
FROM
    deaths.imp_state_age_group_weekdate_structure;