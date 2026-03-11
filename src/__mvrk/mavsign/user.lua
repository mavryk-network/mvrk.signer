local user = am.app.get("user", "root")
ami_assert(type(user) == "string", "user not specified...", EXIT_INVALID_CONFIGURATION)
local mavsign_user = user .. "_mavsign" -- mavsign user related to the app user

local function create_mavsign_user()
    local system_os = am.app.get_model("SYSTEM_OS", "unknown")
    ami_assert(system_os == "unix", "only unix-like platforms are supported right now", EXIT_UNSUPPORTED_PLATFORM)

    local user_plugin, err = am.plugin.get("user")
    ami_assert(user_plugin, "failed to load user plugin - " .. tostring(err), EXIT_PLUGIN_LOAD_ERROR)

    local ok = user_plugin.add(mavsign_user, { disable_login = true, disable_password = true, fullname = user .. " mavsign operator" })
    ami_assert(ok, "failed to create user - " .. mavsign_user)

    local ok = user_plugin.add_group(mavsign_user)
    ami_assert(ok, "failed to create group - " .. mavsign_user)

    return mavsign_user
end

return {
    create = create_mavsign_user,
    username = mavsign_user
}