CREATE OR REPLACE FUNCTION get_random_personalized_joke(substitute VARCHAR,
                                                        categories TEXT DEFAULT null) RETURNS joke AS
$$

SELECT j.categories,
       j.created_at,
       j.joke_id,
       j.updated_at,
       REGEXP_REPLACE(
               REGEXP_REPLACE(
                       REGEXP_REPLACE(j.value, 'Chuck Norris', get_random_personalized_joke.substitute, 'ig'),
                       'Chuck', get_random_personalized_joke.substitute, 'ig'),
               'Norris', get_random_personalized_joke.substitute, 'ig') as value
FROM joke AS j
WHERE CASE
          WHEN get_random_personalized_joke.categories IS NOT NULL
              THEN j.categories IS NOT NULL AND
                   j.categories ?| regexp_split_to_array(get_random_personalized_joke.categories, ',')
          ELSE true
    END
  AND (j.value LIKE ('%Chuck Norris %') OR j.value LIKE ('%Chuck %'))
  AND j.value NOT ILIKE ('% he %')
  AND j.value NOT ILIKE ('% him %')
  AND j.value NOT ILIKE ('% his %')
ORDER BY RANDOM()
LIMIT 1;

$$ LANGUAGE sql;

COMMENT ON FUNCTION get_random_personalized_joke(VARCHAR, TEXT) IS 'Get a random personalized joke.';
