CREATE OR REPLACE FUNCTION count_jokes() RETURNS bigint AS
$$

SELECT count(*)
FROM joke;

$$ LANGUAGE sql;

COMMENT ON FUNCTION count_jokes() IS 'Get the total number of jokes.';
