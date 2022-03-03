SELECT
    count(DISTINCT regionname)
FROM
    stringency.exp_stringency;

SELECT
    count(DISTINCT date_month)
FROM
    stringency.exp_stringency;