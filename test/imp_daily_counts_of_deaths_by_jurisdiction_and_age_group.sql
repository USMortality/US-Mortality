SELECT
    count(*)
FROM
    deaths.daily_counts_of_deaths_by_jurisdiction_and_age_group
WHERE
    state = "United States"
    AND year(date) = 2020;