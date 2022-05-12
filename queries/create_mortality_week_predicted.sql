DROP TABLE IF EXISTS deaths.adj_mortality_week_predicted;

CREATE TABLE deaths.adj_mortality_week_predicted AS
SELECT
    a.state,
    a.year,
    a.week,
    CASE
        WHEN a.rank = b.rank THEN adj_mortality * mean_cum
        ELSE adj_mortality
    END adj_mortality,
    a.pop_total
FROM
    (
        SELECT
            state,
            year,
            week,
            concat(year, '_', lpad(week, 2, 0)) AS 'year_week',
            adj_mortality,
            rank() over (
                PARTITION by state
                ORDER BY
                    year_week DESC
            ) 'rank',
            pop_total
        FROM
            deaths.adj_mortality_week
        GROUP BY
            state,
            year,
            week
    ) a
    LEFT JOIN archive.exp_delay_correction_mean_cum b ON a.state = b.state
    AND a.rank = b.rank;

CREATE INDEX idx_state ON deaths.adj_mortality_week_predicted (state);

CREATE INDEX idx_year ON deaths.adj_mortality_week_predicted (year);

CREATE INDEX idx_week ON deaths.adj_mortality_week_predicted (week);