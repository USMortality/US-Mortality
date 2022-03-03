SELECT
    count(age_group_code)
FROM
    population.2020_states_age_group
WHERE
    state = "United States";

SELECT
    sum(population)
FROM
    population.2020_states_age_group
WHERE
    state = "United States";

SELECT
    state,
    sum(population)
FROM
    population.2020_states_age_group
GROUP BY
    state;

SELECT
    count(DISTINCT state)
FROM
    population.exp_population;

SELECT
    count(DISTINCT month_code)
FROM
    population.exp_population;