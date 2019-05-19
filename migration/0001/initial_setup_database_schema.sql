BEGIN TRANSACTION;

-------------
--- TYPES ---
-------------

CREATE DOMAIN slugid AS VARCHAR CHECK (VALUE ~ '^[a-zA-Z0-9_-]{22}$');

-------------------------
--- TRIGGER FUNCTIONS ---
-------------------------

CREATE OR REPLACE FUNCTION set_updated_at()
    RETURNS TRIGGER AS
$$
BEGIN
    NEW.updated_at = now()::timestamp;
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION set_timestamps()
    RETURNS TRIGGER AS
$$
BEGIN
    NEW.created_at = now()::timestamp;
    NEW.updated_at = now()::timestamp;
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

---------------------
--- TABLES - JOKE ---
---------------------

CREATE TABLE IF NOT EXISTS joke
(
    categories JSONB,
    created_at TIMESTAMP,
    joke_id    SLUGID PRIMARY KEY,
    updated_at TIMESTAMP,
    value      TEXT UNIQUE
);

CREATE TRIGGER trig_joke_insert
    BEFORE INSERT
    ON joke
    FOR EACH ROW
EXECUTE PROCEDURE set_timestamps();
CREATE TRIGGER trig_joke_update
    BEFORE UPDATE
    ON joke
    FOR EACH ROW
EXECUTE PROCEDURE set_updated_at();

COMMENT ON COLUMN joke.categories IS 'List of categories.';
COMMENT ON COLUMN joke.created_at IS 'Timestamp when the joke was inserted.';
COMMENT ON COLUMN joke.joke_id IS 'URL-safe Base64-encoded UUID for a joke.';
COMMENT ON COLUMN joke.updated_at IS 'Timestamp when the joke was updated.';
COMMENT ON COLUMN joke.value IS 'An incredible funny joke.';

COMMIT TRANSACTION;
