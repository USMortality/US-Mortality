SELECT
    concat(a.year, '_', lpad(a.week, 2, 0)) AS 'year_week',
    deaths
FROM
    deaths.adj_mortality_week a
GROUP BY
    year,
    week
ORDER BY
    year_week ASC;