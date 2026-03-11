local empty_configuration = [[
{
    // NO need to set anything here if you use just one mavsign device
    // the ami/mavbake will pick the first connected device automatically
    // device_id: <serial number>

    // if you want to unlock keys automatically on startup
    // you can set the keys and password here
    // if left empty and password is set all keys will be unlocked
    // unlock_keys: alias1,alias2

    // you can set the unlock password by creating a file named 'mavsign.secret'
    // usually you do not want to do this
    // if not set the ami/mavbake handles it for you automatically
    // but if you need to run multiple mavbake instances on the same machine
    // you may have to override the port to avoid conflicts
    // listen: 127.0.0.1:20090
}]]

local function init(options)
    if not options["init"] then
        log_debug("Skipping mavsign initialization...")
        return
    end

    log_info("Initializing mavsign configuration...")
    local mavsign_configuration_raw, _ = fs.read_file("./mavsign.config.hjson")
    if not mavsign_configuration_raw then
        local ok = fs.write_file("./mavsign.config.hjson", empty_configuration)
        ami_assert(ok, "Failed to create mavsign configuration file!")
        log_success("Created default mavsign configuration file at './mavsign.config.hjson'")
    else
        log_info("mavsign configuration already exists.")
    end

    am.app.load_model() -- reload models to get updated configuration
    am.execute("setup", { "--app", "--configure", "--no-validate" })
end

return init
