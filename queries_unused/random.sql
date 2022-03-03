SELECT
    *
FROM
    mortality_99_19
WHERE
    state = "United States";

SELECT
    "United States" AS state,
    month_code,
    -- ten_year_age_group,
    sum(deaths)
FROM
    mortality_99_19
GROUP BY
    month_code
    -- ten_year_age_group
    ;

-- Create US Pop Value 20
INSERT INTO
    pop20
SELECT
    "United States" AS state,
    year_code,
    age_group_code,
    sum(population)
FROM
    pop20
GROUP BY
    year_code,
    age_group_code;

-- Create US Pop Values 90_19
INSERT INTO
    pop90_19
SELECT
    "United States" AS state,
    year_code,
    age_group_code,
    sum(population)
FROM
    pop90_19
GROUP BY
    year_code,
    age_group_code;

-- Incomplete States
SELECT
    DISTINCT state
FROM
    (
        SELECT
            state,
            WEEK,
            COUNT(age_group) AS cnt
        FROM
            `mortality_20`
        GROUP BY
            state,
            WEEK
    ) a
WHERE
    a.cnt = 6