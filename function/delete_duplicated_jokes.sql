CREATE OR REPLACE FUNCTION delete_duplicated_jokes() RETURNS bigint AS $$

    WITH deletions AS (
        DELETE FROM joke WHERE joke_id IN (
            SELECT joke_id FROM (SELECT joke_id, ROW_NUMBER() OVER (partition BY joke ORDER BY created_at) AS row_num FROM joke) AS t
        WHERE t.row_num > 1) RETURNING 1
    )
    SELECT count(*) FROM deletions;

$$ LANGUAGE sql;

COMMENT ON FUNCTION delete_duplicated_jokes() IS 'Deleting duplicated jokes.';