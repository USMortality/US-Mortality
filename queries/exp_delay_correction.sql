DELIMITER $ $
SET
    @n = 13;

SET
    @z = 2.179;

DROP PROCEDURE IF EXISTS diffWeeks;

CREATE PROCEDURE diffWeeks() BEGIN DECLARE counter INT DEFAULT 0;

DECLARE counter_p INT DEFAULT 1;

DECLARE result VARCHAR(1024) DEFAULT 'CREATE TABLE archive.diff_all AS ';

REPEAT
SELECT
    week INTO @week_to
FROM
    archive.mortality_weeks
ORDER BY
    id DESC
LIMIT
    counter, 1;

SELECT
    week INTO @week_from
FROM
    archive.mortality_weeks
ORDER BY
    id DESC
LIMIT
    counter_p, 1;

SET
    @weeks = CONCAT(@week_from, '_', @week_to);

-- ------------------------------------------------------------
SET
    @sql = CONCAT(
        'DROP TABLE IF EXISTS archive.diff_',
        @weeks,
        ';'
    );

PREPARE stmt
FROM
    @sql;

EXECUTE stmt;

DEALLOCATE PREPARE stmt;

-- ------------------------------------------------------------
SET
    @sql = CONCAT(
        'CREATE TABLE archive.diff_',
        @weeks,
        ' AS ',
        'SELECT',
        '    a.state,',
        '    a.week,',
        '    b.rank,',
        '    a.deaths / NULLIF(b.deaths, 0) AS "increase",',
        '    a.deaths_0_24 / NULLIF(b.deaths_0_24, 0) AS "increase_0_24",',
        '    a.deaths_25_44 / NULLIF(b.deaths_25_44, 0) AS "increase_25_44",',
        '    a.deaths_45_64 / NULLIF(b.deaths_45_64, 0) AS "increase_45_64",',
        '    a.deaths_65_74 / NULLIF(b.deaths_65_74, 0) AS "increase_65_74",',
        '    a.deaths_75_84 / NULLIF(b.deaths_75_84, 0) AS "increase_75_84",',
        '    a.deaths_85 / NULLIF(b.deaths_85, 0) AS "increase_85"',
        'FROM',
        '    archive.mortality_week_',
        @week_to,
        ' a',
        '    JOIN (',
        '        SELECT',
        '            *,',
        '            rank() over (',
        '                PARTITION by state',
        '                ORDER BY',
        '                    year DESC,',
        '                    week DESC',
        '            ) AS rank',
        '        FROM',
        '            archive.mortality_week_',
        @week_from,
        '        WHERE',
        '            deaths > 0',
        '    ) b ON a.state = b.state',
        '    AND a.year = b.year',
        '    AND a.week = b.week;'
    );

PREPARE stmt
FROM
    @sql;

EXECUTE stmt;

DEALLOCATE PREPARE stmt;

-- ------------------------------------------------------------
SET
    @sql = CONCAT(
        'CREATE INDEX idx_all ON archive.diff_',
        @weeks,
        ' (state, week, rank);'
    );

PREPARE stmt
FROM
    @sql;

EXECUTE stmt;

DEALLOCATE PREPARE stmt;

-- ------------------------------------------------------------
SET
    result = CONCAT(
        result,
        " ",
        'SELECT * FROM archive.diff_',
        @weeks,
        ' WHERE RANK <= ',
        @n,
        ' UNION ALL '
    );

SET
    counter = counter + 1;

SET
    counter_p = counter + 1;

UNTIL counter = @n
END REPEAT;

-- Create final table
SET
    @sql = "DROP TABLE IF EXISTS archive.diff_all;";

PREPARE stmt
FROM
    @sql;

EXECUTE stmt;

DEALLOCATE PREPARE stmt;

SET
    @sql = CONCAT(
        trim(
            TRAILING ' UNION ALL '
            FROM
                result
        ),
        ";"
    );

PREPARE stmt
FROM
    @sql;

EXECUTE stmt;

DEALLOCATE PREPARE stmt;

END $ $ DELIMITER;

call diffWeeks();

-- -------------------------
DROP TABLE IF EXISTS archive.exp_delay_correction_mean_stddv;

CREATE TABLE archive.exp_delay_correction_mean_stddv AS
SELECT
    state,
    rank,
    AVG(increase) AS 'mean',
    STDDEV(increase) AS 'stddv',
    STDDEV(increase) / SQRT(@n) AS 'stderr',
    AVG(increase_0_24) AS 'mean_0_24',
    STDDEV(increase_0_24) AS 'stddv_0_24',
    STDDEV(increase_0_24) / SQRT(@n) AS 'stderr_0_24',
    AVG(increase_25_44) AS 'mean_25_44',
    STDDEV(increase_25_44) AS 'stddv_25_44',
    STDDEV(increase_25_44) / SQRT(@n) AS 'stderr_25_44',
    AVG(increase_45_64) AS 'mean_45_64',
    STDDEV(increase_45_64) AS 'stddv_45_64',
    STDDEV(increase_45_64) / SQRT(@n) AS 'stderr_45_64',
    AVG(increase_65_74) AS 'mean_65_74',
    STDDEV(increase_65_74) AS 'stddv_65_74',
    STDDEV(increase_65_74) / SQRT(@n) AS 'stderr_65_74',
    AVG(increase_75_84) AS 'mean_75_84',
    STDDEV(increase_75_84) AS 'stddv_75_84',
    STDDEV(increase_75_84) / SQRT(@n) AS 'stderr_75_84',
    AVG(increase_85) AS 'mean_85',
    STDDEV(increase_85) AS 'stddv_85',
    STDDEV(increase_85) / SQRT(@n) AS 'stderr_85'
FROM
    archive.diff_all
GROUP BY
    state,
    rank;

-- ----------------------------
DROP TABLE IF EXISTS deaths.delay_correction;

CREATE TABLE deaths.delay_correction AS
SELECT
    a.state,
    rank,
    mean,
    mean - @z * stderr AS 'lci',
    mean + @z * stderr AS 'uci',
    mean_0_24,
    mean_0_24 - @z * stderr_0_24 AS 'lci_0_24',
    mean_0_24 + @z * stderr_0_24 AS 'uci_0_24',
    mean_25_44,
    mean_25_44 - @z * stderr_25_44 AS 'lci_25_44',
    mean_25_44 + @z * stderr_25_44 AS 'uci_25_44',
    mean_45_64,
    mean_45_64 - @z * stderr_45_64 AS 'lci_45_64',
    mean_45_64 + @z * stderr_45_64 AS 'uci_45_64',
    mean_65_74,
    mean_65_74 - @z * stderr_65_74 AS 'lci_65_74',
    mean_65_74 + @z * stderr_65_74 AS 'uci_65_74',
    mean_75_84,
    mean_75_84 - @z * stderr_75_84 AS 'lci_75_84',
    mean_75_84 + @z * stderr_75_84 AS 'uci_75_84',
    mean_85,
    mean_85 - @z * stderr_85 AS 'lci_85',
    mean_85 + @z * stderr_85 AS 'uci_85'
FROM
    (
        SELECT
            *,
            rank() over (
                PARTITION by state
                ORDER BY
                    rank ASC
            ) AS a_rank
        FROM
            archive.exp_delay_correction_mean_stddv
    ) a
WHERE
    a_rank = rank
    AND rank <= @n
ORDER BY
    state,
    rank DESC;

-- -------------------------
-- Calculate cumulative correction factor
DROP VIEW IF EXISTS archive.exp_delay_correction_mean_cum;

CREATE VIEW archive.exp_delay_correction_mean_cum AS
SELECT
    state,
    rank,
    mean,
    (
        SELECT
            EXP(SUM(LOG(mean)))
        FROM
            deaths.delay_correction
        WHERE
            state = a.state
            AND rank >= a.rank
    ) AS mean_cum
FROM
    deaths.delay_correction a
GROUP BY
    state,
    rank;

-- -------------------------
SELECT
    *
FROM
    deaths.delay_correction;