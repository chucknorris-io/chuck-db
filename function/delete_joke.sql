CREATE OR REPLACE FUNCTION delete_joke(
    joke_id SLUGID
) RETURNS bigint AS
$$

WITH deletions AS (
    DELETE FROM joke WHERE joke_id = delete_joke.joke_id RETURNING 1
)
SELECT count(*)
FROM deletions;

$$ LANGUAGE sql;

COMMENT ON FUNCTION delete_joke(SLUGID) IS 'Delete a joke by a given joke id.';
