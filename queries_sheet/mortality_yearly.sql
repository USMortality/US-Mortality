SELECT
    state,
    year,
    sum(adj_mortality)
FROM
    deaths.adj_mortality_week_predicted
WHERE
    year IN (2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022)
    AND state = "United States"
    AND week <= 52
GROUP BY
    year
ORDER BY
    year;