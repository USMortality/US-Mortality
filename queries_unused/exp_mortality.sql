DROP TABLE IF EXISTS deaths.adj_mortality;

CREATE INDEX IF NOT EXISTS state_month ON population.exp_population (state, month_code);

CREATE INDEX IF NOT EXISTS state_month ON deaths.exp_deaths (state, month_code);

-- ajd mortality
CREATE TABLE deaths.adj_mortality AS
SELECT
    state,
    right(month_code, 2) AS MONTH,
    left(month_code, 4) AS year,
    month_code,
    adj_0_24,
    adj_25_44,
    adj_45_64,
    adj_65_74,
    adj_75_84,
    adj_85,
    adj_0_24 + adj_25_44 + adj_45_64 + adj_65_74 + adj_75_84 + adj_85 AS "adj_mortality"
FROM
    (
        -- deaths per 100k corrected for 2020 population
        SELECT
            m.state,
            month_code,
            deaths_0_24_100k * f_0_24 AS "adj_0_24",
            deaths_25_44_100k * f_25_44 AS "adj_25_44",
            deaths_45_64_100k * f_45_64 AS "adj_45_64",
            deaths_65_74_100k * f_65_74 AS "adj_65_74",
            deaths_75_84_100k * f_75_84 AS "adj_75_84",
            deaths_85_100k * f_85 AS "adj_85"
        FROM
            (
                -- deaths per 100k
                SELECT
                    d.state,
                    left(d.month_code, 4) AS year,
                    d.month_code,
                    (deaths_0_24 / pop_0_24) * 100000 AS "deaths_0_24_100k",
                    (deaths_25_44 / pop_25_44) * 100000 AS "deaths_25_44_100k",
                    (deaths_45_64 / pop_45_64) * 100000 AS "deaths_45_64_100k",
                    (deaths_65_74 / pop_65_74) * 100000 AS "deaths_65_74_100k",
                    (deaths_75_84 / pop_75_84) * 100000 AS "deaths_75_84_100k",
                    (deaths_85 / pop_85) * 100000 AS "deaths_85_100k"
                FROM
                    deaths.exp_deaths d
                    JOIN population.exp_population p ON d.state = p.state
                    AND d.month_code = p.month_code
            ) m
            JOIN (
                -- correction factor 2020
                SELECT
                    state,
                    year,
                    pop_0_24 / total AS "f_0_24",
                    pop_25_44 / total AS "f_25_44",
                    pop_45_64 / total AS "f_45_64",
                    pop_65_74 / total AS "f_65_74",
                    pop_75_84 / total AS "f_75_84",
                    pop_85 / total AS "f_85"
                FROM
                    (
                        SELECT
                            DISTINCT state,
                            left(month_code, 4) AS year,
                            pop_0_24,
                            pop_25_44,
                            pop_45_64,
                            pop_65_74,
                            pop_75_84,
                            pop_85,
                            pop_0_24 + pop_25_44 + pop_45_64 + pop_65_74 + pop_75_84 + pop_85 AS total
                        FROM
                            population.exp_population
                    ) a
                WHERE
                    year = 2020
            ) c ON m.state = c.state -- AND m.year = c.year
        ORDER BY
            m.state,
            m.month_code
    ) y;

SELECT
    a.state,
    adj_mortality_2020,
    adj_mortality_avg5,
    (adj_mortality_2020 - adj_mortality_avg5) AS "excess_mortality",
    (adj_mortality_2020 - adj_mortality_avg5) / adj_mortality_avg5 AS "excess_mortality_incr"
FROM
    (
        -- 5y avg
        SELECT
            state,
            sum(adj_mortality) / 5 AS "adj_mortality_avg5"
        FROM
            deaths.adj_mortality
        WHERE
            year IN (2015, 2016, 2017, 2018, 2019)
        GROUP BY
            state
    ) a
    JOIN (
        SELECT
            state,
            sum(adj_mortality) AS "adj_mortality_2020"
        FROM
            deaths.adj_mortality
        WHERE
            year = 2020
        GROUP BY
            state
    ) b ON a.state = b.state