CREATE OR REPLACE FUNCTION get_joke_random_by_categories(
    categories text
) RETURNS joke AS
$$

SELECT
  j.categories, j.created_at, j.joke_id, j.updated_at, j.value
FROM
  joke AS j
WHERE
  j.categories IS NOT NULL
  AND
  j.categories ?| regexp_split_to_array(get_joke_random_by_categories.categories, ',')

ORDER BY
  RANDOM() LIMIT 1;

$$ LANGUAGE sql;

COMMENT ON FUNCTION get_joke_random_by_categories(text) IS 'Get a random joke by a comma separated list of categories.';
