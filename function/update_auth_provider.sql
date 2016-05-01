CREATE OR REPLACE FUNCTION update_auth_provider(
    auth_provider_id INTEGER,
    name             VARCHAR,
    meta             JSONB,
    slug             VARCHAR
) RETURNS json AS $$

    UPDATE auth_provider SET
        name = update_auth_provider.name,
        meta = update_auth_provider.meta,
        slug = update_auth_provider.slug
    WHERE
        auth_provider_id = update_auth_provider.auth_provider_id
    RETURNING
        get_auth_provider(update_auth_provider.auth_provider_id);

$$ LANGUAGE sql;

COMMENT ON FUNCTION update_auth_provider(INTEGER, VARCHAR, JSONB, VARCHAR) IS 'Update an auth provider.';