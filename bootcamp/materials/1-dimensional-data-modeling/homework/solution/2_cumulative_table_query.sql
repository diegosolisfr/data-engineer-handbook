WITH last_year AS (
    SELECT actor
            , actorid
            , year
            , films
            , quality_class
            , is_active
      FROM actors
     WHERE year = 1969
), this_year AS (
    SELECT actor
            , actorid
            , year
            , ARRAY_AGG(
                ROW(
                    film,
                    votes,
                    rating,
                    filmid
                )::film
            ) AS films
      FROM actor_films
     WHERE year = 1970
     GROUP BY actor, actorid, year
), cumulative AS (
    SELECT
            COALESCE(ly.actor, ty.actor) AS actor
            , COALESCE(ly.actorid, ty.actorid) AS actorid
            , COALESCE(ty.year, ly.year + 1) AS year
            , COALESCE(ly.films, ARRAY[]::film[]) || COALESCE(ty.films, ARRAY[]::film[]) AS films
            , CASE
                WHEN ty.actorid IS NOT NULL THEN
                    (
                        CASE
                            WHEN (ty.films[CARDINALITY(ty.films)]::film).rating > 8 THEN 'star'
                            WHEN (ty.films[CARDINALITY(ty.films)]::film).rating > 7 THEN 'good'
                            WHEN (ty.films[CARDINALITY(ty.films)]::film).rating > 6 THEN 'average'
                            ELSE 'bad'
                        END
                    )::quality_class
                ELSE ly.quality_class
            END AS quality_class
            , CASE WHEN ty.actorid IS NOT NULL THEN TRUE ELSE FALSE END AS is_active
    FROM last_year ly
            FULL OUTER JOIN this_year ty
            ON ly.actorid = ty.actorid
)
INSERT INTO actors
SELECT actor
        , actorid
        , year
        , films
        , quality_class
        , is_active
  FROM cumulative
;
