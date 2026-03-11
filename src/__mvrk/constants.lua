local function load_constants()
    local mavsign_configuration = require "__mvrk.mavsign.configuration".load()

    -- binaries
    local wanted_binaries = {}

    if am.app.get_configuration("BACKEND", "mavkit") == "mavkit" then
        table.insert(wanted_binaries, "signer")
        table.insert(wanted_binaries, "client")
        table.insert(wanted_binaries, "check-ledger")
    end

    if am.app.get_configuration("PRISM") then
        table.insert(wanted_binaries, "prism")
    end

    if mavsign_configuration then
        table.insert(wanted_binaries, "mavsign")
    end
    -- end of binaries

    return {
        protected_files = {
            "mavsign.config.hjson",
        },
        wanted_binaries = wanted_binaries,
    }
end

return {
    load = load_constants,
}