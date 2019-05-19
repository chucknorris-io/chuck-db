CREATE OR REPLACE FUNCTION insert_joke(joke_id SLUGID,
                                       categories JSONB,
                                       value VARCHAR) RETURNS json AS
$$

INSERT INTO joke (joke_id,
                  categories,
                  value)
VALUES (insert_joke.joke_id,
        insert_joke.categories,
        insert_joke.value) RETURNING get_joke(insert_joke.joke_id);

$$ LANGUAGE sql;

COMMENT ON FUNCTION insert_joke(SLUGID, JSONB, VARCHAR) IS 'Insert a joke.';
