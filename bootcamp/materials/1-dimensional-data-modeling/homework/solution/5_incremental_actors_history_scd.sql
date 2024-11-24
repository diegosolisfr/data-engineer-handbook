WITH last_year AS (
    SELECT actor
            , actorid
            , quality_class
            , is_active
            , start_year
            , end_year
            , year
      FROM actors_history_scd
     WHERE year = 1976
), this_year AS (
    SELECT actor
            , actorid
            , quality_class
            , is_active
            , year
      FROM actors
     WHERE year = 1977
), historical AS (
    SELECT actor
            , actorid
            , quality_class
            , is_active
            , start_year
            , end_year
            , 1977 AS year
     FROM last_year
    WHERE end_year < year
), new AS (
    SELECT ty.actor
            , ty.actorid
            , ty.quality_class
            , ty.is_active
            , ty.year AS start_year
            , ty.year AS end_year
            , ty.year
      FROM this_year ty
            LEFT JOIN last_year ly
            ON ty.actorid = ly.actorid
     WHERE ly.actorid IS NULL
), unchanged AS (
    SELECT ly.actor
            , ly.actorid
            , ly.quality_class
            , ly.is_active
            , ly.start_year
            , ty.year AS end_year
            , ty.year
      FROM last_year ly
            INNER JOIN this_year ty
            ON ly.actorid = ty.actorid
     WHERE ly.end_year = ly.year
            AND ly.quality_class = ty.quality_class
            AND ly.is_active = ty.is_active
), unnested_changed AS (
    SELECT ly.actor
            , ly.actorid
            , UNNEST(
                ARRAY[
                    ROW(
                        ly.quality_class,
                        ly.is_active,
                        ly.start_year,
                        ly.end_year
                    )::scd_type,
                    ROW(
                        ty.quality_class,
                        ty.is_active,
                        ty.year,
                        ty.year
                    )::scd_type
                ]
            ) AS records
            , ty.year
      FROM last_year ly
            INNER JOIN this_year ty
            ON ly.actorid = ty.actorid
    WHERE ly.end_year = ly.year
            AND (ly.quality_class <> ty.quality_class
            OR ly.is_active <> ty.is_active)
), changed AS (
    SELECT actor
            , actorid
            , (records::scd_type).quality_class
            , (records::scd_type).is_active
            , (records::scd_type).start_year
            , (records::scd_type).end_year
            , year
      FROM unnested_changed
)
INSERT INTO actors_history_scd
SELECT *
  FROM historical
UNION ALL
SELECT *
  FROM new
UNION ALL
SELECT *
  FROM unchanged
UNION ALL
SELECT *
  FROM changed
;
