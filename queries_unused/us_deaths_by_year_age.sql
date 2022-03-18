SELECT
    year,
    age_group,
    sum(number_of_deaths) AS "deaths"
FROM
    deaths.`imp_Weekly_counts_of_deaths_by_jurisdiction_and_age_group`
WHERE
    jurisdiction = "United States"
    AND year = 2019
    AND TYPE = "Unweighted"
GROUP BY
    year,
    age_group