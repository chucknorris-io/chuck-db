CREATE OR REPLACE FUNCTION find_by_by_value_contains_and_filter(
    query varchar,
    categories text
) RETURNS TABLE (
    categories JSONB,
    created_at TIMESTAMP,
    joke_id    SLUGID,
    updated_at TIMESTAMP,
    value      TEXT
) AS $$

SELECT
  j.categories, j.created_at, j.joke_id, j.updated_at, j.value
FROM
  joke AS j
WHERE
  j.categories IS NOT NULL
  AND
  j.categories ?| regexp_split_to_array(find_by_by_value_contains_and_filter.categories, ',')
  AND
  lower(j.value) LIKE CONCAT('%', lower(
      find_by_by_value_contains_and_filter.query
  ), '%');

$$ LANGUAGE sql;

COMMENT ON FUNCTION find_by_by_value_contains_and_filter(
  varchar,
  text
) IS 'Search jokes by query and with category filter.';
