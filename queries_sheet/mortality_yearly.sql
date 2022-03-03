SELECT
    state,
    year,
    sum(adj_mortality)
FROM
    deaths.adj_mortality_week
WHERE
    year IN (2015, 2016, 2017, 2018, 2019, 2021, 2022)
    AND state = "United States"
GROUP BY
    year
UNION
ALL
SELECT
    state,
    year,
    sum(adj_mortality) * (52 /(52 + 5 / 7))
FROM
    deaths.adj_mortality_week
WHERE
    year = 2020
    AND state = "United States"
GROUP BY
    year
ORDER BY
    year;