-- Prints this resource's version to the server console on startup.
-- Reads the `version` field from fxmanifest.lua. Shared boilerplate across
-- all Kryptogawdzz resources; safe to leave as-is.
local resource = GetCurrentResourceName()
local version = GetResourceMetadata(resource, 'version', 0) or 'unknown'
print(('^2[%s]^7 version ^5%s^7 loaded'):format(resource, version))
