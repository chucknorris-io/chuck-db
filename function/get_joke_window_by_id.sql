CREATE OR REPLACE FUNCTION get_joke_window_by_joke_id(
  joke_id SLUGID
) RETURNS json AS $$

WITH joke AS (
  SELECT
    joke_id,
    ROW_NUMBER () OVER (ORDER BY joke.created_at ASC, joke.joke_id ASC) AS row_number
  FROM joke
), current AS (
  SELECT * FROM joke WHERE joke_id = get_joke_window_by_joke_id.joke_id LIMIT 1
), prev AS (
  SELECT
    (CASE
      WHEN (SELECT min(row_number) FROM joke) >= current.row_number - 1
      THEN (SELECT joke_id FROM joke WHERE row_number = (SELECT max(row_number) FROM joke))
      ELSE (SELECT joke_id FROM joke WHERE row_number = current.row_number - 1)
    END) AS joke_id
  FROM joke, current LIMIT 1
), next AS (
  SELECT
    (CASE
      WHEN (SELECT max(row_number) FROM joke) <= current.row_number + 1
      THEN (SELECT joke_id FROM joke WHERE row_number = (SELECT min(row_number) FROM joke))
      ELSE (SELECT joke_id FROM joke WHERE row_number = current.row_number + 1)
    END) AS joke_id
  FROM joke, current LIMIT 1
)
SELECT
  JSON_BUILD_OBJECT (
    'current',  get_joke(current.joke_id),
    'next',     get_joke(next.joke_id),
    'previous', get_joke(prev.joke_id)
  )
FROM current, prev, next;

$$ LANGUAGE sql;

COMMENT ON FUNCTION get_joke_window_by_joke_id(SLUGID) IS 'Get a joke by a given id including the previous and next joke.';
