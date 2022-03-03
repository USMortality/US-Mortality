SELECT
    count(DISTINCT state)
FROM
    deaths.exp_deaths;

SELECT
    state,
    round(
        sum(deaths_0_24) + sum(deaths_25_44) + sum(deaths_45_64) + sum(deaths_65_74) + sum(deaths_75_84) + sum(deaths_85)
    )
FROM
    deaths.exp_deaths
WHERE
    left(month_code, 4) = '2020'
GROUP BY
    state;