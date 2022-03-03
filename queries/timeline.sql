SELECT
    concat(a.year, '_', lpad(a.week, 2, 0)) AS 'year_week',
    @deaths_0_24 := round(mortality_0_24 * b.pop_0_24 / 100000) AS deaths_0_24,
    @deaths_25_44 := round(mortality_25_44 * b.pop_25_44 / 100000) AS deaths_25_44,
    @deaths_45_64 := round(mortality_45_64 * b.pop_45_64 / 100000) AS deaths_45_64,
    @deaths_65_74 := round(mortality_65_74 * b.pop_65_74 / 100000) AS deaths_65_74,
    @deaths_75_84 := round(mortality_75_84 * b.pop_75_84 / 100000) AS deaths_75_84,
    @deaths_85 := round(mortality_85 * b.pop_85 / 100000) AS deaths_85,
    @deaths_0_24 + @deaths_25_44 + @deaths_45_64 + @deaths_65_74 + @deaths_75_84 + @deaths_85 AS 'deaths'
FROM
    deaths.adj_mortality_week a
    JOIN (
        SELECT
            *
        FROM
            population.imp_population20152021
        WHERE
            year = 2022
            AND state = "United States"
    ) b ON a.state = b.state
ORDER BY
    year_week ASC;