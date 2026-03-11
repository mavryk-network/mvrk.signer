local function load_mavsign_configuration()
    local mavsign_configuration_raw, _ = fs.read_file("./mavsign.config.hjson")
    if not mavsign_configuration_raw then
        return false
    end

    local mavsign_configuration = hjson.parse(mavsign_configuration_raw)
    ami_assert(mavsign_configuration,
        "failed to parse mavsign configuration file './mavsign.config.hjson'")

    -- normalize configuration
    local default_endpoint = "127.0.0.1:20091"
    if am.app.get_configuration("BACKEND", "mavkit") == "mavsign" then
        default_endpoint = am.app.get_configuration("SIGNER_ENDPOINT", "127.0.0.1:20090")
    end

    local listen = mavsign_configuration.listen
    if listen == nil then
        listen = default_endpoint
    end
    if type(listen) ~= "string" then
        log_warn("invalid mavsign configuration: listen must be a string")
        listen = default_endpoint
    end

    local secret, _ = fs.read_file("./mavsign.secret")
    if secret then
        mavsign_configuration.unlock_password = secret:match("^%s*(.-)%s*$")     -- trim whitespace
    else
        mavsign_configuration.unlock_password = nil
    end

    return util.merge_tables(mavsign_configuration, {
        listen = listen,
    })
end

return {
    load = load_mavsign_configuration,
}