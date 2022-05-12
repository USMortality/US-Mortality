SELECT
    max(cast(week AS INTEGER)) INTO @max_week
FROM
    deaths.adj_mortality_week
WHERE
    year = 2022
    AND adj_mortality > 0;

SELECT
    state,
    year,
    @max_week 'max_week',
    sum(adj_mortality)
FROM
    deaths.adj_mortality_week_predicted
WHERE
    year IN (2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022)
    AND week <= @max_week
    AND state = "United States"
GROUP BY
    year;