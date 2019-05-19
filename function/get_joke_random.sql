CREATE OR REPLACE FUNCTION get_joke_random(category VARCHAR DEFAULT NULL,
                                           parental_control BOOLEAN DEFAULT false) RETURNS json AS
$$

SELECT get_joke(j.joke_id)
FROM joke AS j
WHERE CASE
          WHEN get_joke_random.parental_control = true
              THEN categories IS NOT NULL AND NOT (categories ?| array [ 'explicit' ])
          ELSE true
    END
  AND CASE
          WHEN get_joke_random.category IS NOT NULL AND get_joke_random.category != 'explicit'
              THEN categories IS NOT NULL AND categories ?| array [ get_joke_random.category ]
          ELSE true
    END
ORDER BY RANDOM()
LIMIT
    1;

$$ LANGUAGE sql;

COMMENT ON FUNCTION get_joke_random(VARCHAR, BOOLEAN) IS 'Get a random joke.';
