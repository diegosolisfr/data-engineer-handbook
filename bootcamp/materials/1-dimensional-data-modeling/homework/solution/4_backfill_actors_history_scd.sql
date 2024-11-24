WITH track_changes AS (
    SELECT actor
            , actorid
            , year
            , quality_class
            , is_active
            , LAG(quality_class) OVER (PARTITION BY actorid ORDER BY year) <> quality_class OR LAG(is_active) OVER (PARTITION BY actorid ORDER BY year) <> is_active AS changed
    FROM actors
), streaks AS (
    SELECT actor
            , actorid
            , year
            , quality_class
            , is_active
            , SUM(CASE WHEN changed THEN 1 ELSE 0 END) OVER (PARTITION BY actorid ORDER BY year) AS streak
    FROM track_changes
), aggregated AS (
    SELECT actor
            , actorid
            , quality_class
            , is_active
            , MIN(year) AS start_year
            , MAX(year) AS end_year
    FROM streaks
    GROUP BY actor, actorid, quality_class, is_active, streak
)
INSERT INTO actors_history_scd
SELECT actor
    , actorid
    , quality_class
    , is_active
    , start_year
    , end_year
    , MAX(end_year) OVER() AS year
  FROM aggregated
 ORDER BY actor
;
