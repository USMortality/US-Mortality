SELECT
    state,
    year,
    week,
    concat(year, '_', lpad(week, 2, 0)) AS 'year_week',
    deaths_25_44,
    mortality_25_44
FROM
    deaths.adj_mortality_week
WHERE
    state = "United States"
ORDER BY
    concat(year, '_', lpad(week, 2, 0))