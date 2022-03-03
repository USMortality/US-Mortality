SELECT
    state,
    year,
    @year_quarter := concat(year, "/", ceil(cast(week AS integer) / 13)) AS year_quarter,
    sum(adj_mortality) AS "mortality"
FROM
    deaths.adj_mortality_week
WHERE
    year IN (2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022)
    AND state = "United States"
    AND ceil(cast(week AS integer) / 13) < 5
GROUP BY
    year_quarter,
    year;