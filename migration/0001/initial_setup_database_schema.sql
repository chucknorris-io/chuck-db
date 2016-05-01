BEGIN TRANSACTION;

-------------
--- TYPES ---
-------------

CREATE DOMAIN slugid AS VARCHAR CHECK (VALUE ~ '^[a-zA-Z0-9_-]{22}$');

-------------------------
--- TRIGGER FUNCTIONS ---
-------------------------

CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now()::timestamp;
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION set_timestamps()
RETURNS TRIGGER AS $$
BEGIN
    NEW.created_at = now()::timestamp;
    NEW.updated_at = now()::timestamp;
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

------------------------------
--- TABLES - AUTH PROVIDER ---
------------------------------

CREATE TABLE IF NOT EXISTS auth_provider (
    auth_provider_id SERIAL         PRIMARY KEY,
    created_at       TIMESTAMP,
    meta             JSONB,
    name             VARCHAR(1000)  UNIQUE,
    slug             VARCHAR(255)   UNIQUE,
    updated_at       TIMESTAMP
);

COMMENT ON COLUMN auth_provider.auth_provider_id IS 'Auth provider identifier.';
COMMENT ON COLUMN auth_provider.created_at       IS 'Timestamp when the auth provider was inserted.';
COMMENT ON COLUMN auth_provider.meta             IS 'Unstructured list of additional meta data';
COMMENT ON COLUMN auth_provider.name             IS 'Name of the auth provider.';
COMMENT ON COLUMN auth_provider.slug             IS 'Unique SEO-friendly string representation of the auth provider name for use in URLs';
COMMENT ON COLUMN auth_provider.updated_at       IS 'Timestamp when the auth provider was updated.';

CREATE TRIGGER trig_auth_provider_insert BEFORE INSERT ON auth_provider FOR EACH ROW EXECUTE PROCEDURE set_timestamps();
CREATE TRIGGER trig_auth_provider_update BEFORE UPDATE ON auth_provider FOR EACH ROW EXECUTE PROCEDURE set_updated_at();

---------------------
--- TABLES - AUTH ---
---------------------

CREATE TABLE IF NOT EXISTS auth (
    access_token     VARCHAR(1000),
    auth_id          SERIAL PRIMARY KEY,
    auth_provider_id INTEGER REFERENCES auth_provider,
    created_at       TIMESTAMP,
    expires_in       INTEGER,
    meta             JSONB,
    refresh_token    VARCHAR(1000),
    updated_at       TIMESTAMP,
    user_ref         VARCHAR(1000)
);

CREATE TRIGGER trig_auth_insert BEFORE INSERT ON auth FOR EACH ROW EXECUTE PROCEDURE set_timestamps();
CREATE TRIGGER trig_auth_update BEFORE UPDATE ON auth FOR EACH ROW EXECUTE PROCEDURE set_updated_at();

COMMENT ON COLUMN auth.access_token     IS 'Access token returned by OAuth provider.';
COMMENT ON COLUMN auth.auth_provider_id IS 'Reference to the auth provider.';
COMMENT ON COLUMN auth.created_at       IS 'Timestamp when the auth record was inserted.';
COMMENT ON COLUMN auth.expires_in       IS 'Expiry time of the token in seconds returned from by OAuth provider.';
COMMENT ON COLUMN auth.meta             IS 'Unstructured list of additional meta data';
COMMENT ON COLUMN auth.refresh_token    IS 'Refresh token returned by OAuth provider';
COMMENT ON COLUMN auth.updated_at       IS 'Timestamp when the auth record was updated.';
COMMENT ON COLUMN auth.user_ref         IS 'User identifier from the OAuth provider.';

---------------------
--- TABLES - JOKE ---
---------------------

CREATE TABLE IF NOT EXISTS joke (
    categories JSONB,
    created_at TIMESTAMP,
    joke_id    SLUGID     PRIMARY KEY,
    updated_at TIMESTAMP,
    value      TEXT       UNIQUE
);

CREATE TRIGGER trig_joke_insert BEFORE INSERT ON joke FOR EACH ROW EXECUTE PROCEDURE set_timestamps();
CREATE TRIGGER trig_joke_update BEFORE UPDATE ON joke FOR EACH ROW EXECUTE PROCEDURE set_updated_at();

COMMENT ON COLUMN joke.categories IS 'List of categories.';
COMMENT ON COLUMN joke.created_at IS 'Timestamp when the joke was inserted.';
COMMENT ON COLUMN joke.joke_id    IS 'URL-safe Base64-encoded UUID for a joke.';
COMMENT ON COLUMN joke.updated_at IS 'Timestamp when the joke was updated.';
COMMENT ON COLUMN joke.value      IS 'An incredible funny joke.';

COMMIT TRANSACTION;