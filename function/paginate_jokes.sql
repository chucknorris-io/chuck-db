CREATE OR REPLACE FUNCTION paginate_jokes(size integer DEFAULT 500,
                                          start integer DEFAULT 0,
                                          category varchar DEFAULT NULL) RETURNS json AS
$$

WITH total_count AS (
    SELECT count(*)
    FROM joke
    WHERE CASE
              WHEN paginate_jokes.category IS NOT NULL
                  THEN categories IS NOT NULL AND categories ?| array [ paginate_jokes.category ]
              ELSE true
              END
)
SELECT JSON_BUILD_OBJECT(
               'total', (SELECT * FROM total_count),
               'count', count(jokes),
               'items', JSON_AGG(
                       get_joke(joke_id)
                   )
           )
FROM (
         SELECT joke_id
         FROM joke
         WHERE CASE
                   WHEN paginate_jokes.category IS NOT NULL
                       THEN categories IS NOT NULL AND categories ?| array [ paginate_jokes.category ]
                   ELSE true
                   END
         LIMIT
             paginate_jokes.size
             OFFSET
             paginate_jokes.start
     ) as jokes;

$$ LANGUAGE sql;

COMMENT ON FUNCTION paginate_jokes(INTEGER, INTEGER, VARCHAR) IS 'Get a subset of jokes defined by a given SIZE and START and an optional category.';
