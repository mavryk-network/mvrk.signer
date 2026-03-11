local mavsign_configuration = require("__mvrk.mavsign.configuration").load()
assert(mavsign_configuration,
	"Mavsign configuration could not be loaded. Please ensure mavsign.config.hjson exists and is valid.",
	EXIT_APP_INTERNAL_ERROR)
local homedir = path.combine(os.cwd(), "data")

local mavsign_service_id = require("__mvrk.services").mavsign_service_id
local function is_mavsign_running()
	local service_manager = require "__mvrk.service-manager"
	local status, all_running = service_manager.get_services_status({ mavsign_service_id })
	-- status has to contain the mavsign service and it has to be running
	-- we could get status without it if it is not installed
	-- but all running would still be true in that case
	return status[mavsign_service_id] and all_running == true
end

local function resolve_mavsign_key(alias)
	local args = {"list"}

	local device_id = mavsign_configuration.device_id
	if type(device_id) == "string" then
		table.insert(args, 1, device_id)
		table.insert(args, 1, "--device")
	end

	local process = proc.spawn("bin/mavsign", args, {
		stdio = { stderr = "pipe" },
		wait = true,
		env = { HOME = homedir },
		username = am.app.get("user"),
	})

	ami_assert(process.exit_code == 0,
		"Failed to get connected devices: " .. (process.stderr_stream:read("a") or "unknown"))
	local output = process.stdout_stream:read("a") or ""
	-- json: {"baker":"mv4PLVFDLuEmzEP658FbXoDdggNRWe25ZgaZ","consensus":"mv4U2MAESy9qsbyBzfYWp4QWGxcBcftQqP5T"}
	local keys = hjson.parse(output)
	ami_assert(type(keys) == "table" and keys[alias], "Failed to resolve key for alias: " .. tostring(alias),
		EXIT_APP_INTERNAL_ERROR)
	return keys[alias]
end

---@param options table<string, any>
local function setup(options)
	if not options["import-key"] then
		log_debug("No key import specified. Skipping mavsign/key setup...")
		return
	end

	if am.app.get_configuration("BACKEND", "mavkit") ~= "mavkit" then
		log_warn("Key import is only supported for mavkit backend. Skipping...")
		return
	end

	local key_id = options["import-key"]
	if type(key_id) ~= "string" then
		key_id = "baker"
		log_info("No key alias specified. Using default alias: 'baker'")
	end

	log_info("Importing mavsign key...")
	local mv4 = resolve_mavsign_key(key_id)
	assert(type(mv4) == "string" and mv4:match("^mv4"), "Failed to resolve mavsign key " .. tostring(key_id) .. "!",
		EXIT_APP_INTERNAL_ERROR)

	local listen = mavsign_configuration.listen
	-- we need close to stop the mavsign server after import
	assert(is_mavsign_running() == true,
		"mavsign service is not running. Please start it to import keys!",
		EXIT_APP_INTERNAL_ERROR)

	local alias = "baker"
	if options["key-alias"] then
		alias = options["key-alias"]
		ami_assert(type(alias) == "string", "Invalid alias detected!", EXIT_CLI_ARG_VALIDATION_ERROR)
	end

	-- listen with the mavsign in the background
	local process = proc.spawn("bin/signer",
		{ "import", "secret", "key", alias or "baker", "http://" .. listen .. "/" .. mv4,
			options.force and "--force" or nil }, {
			stdio = "inherit",
			wait = true,
			env = { HOME = homedir },
			username = am.app.get("user"),
		})
	ami_assert(process.exit_code == 0, "Failed to import key to signer!")

	local protocol = "ProtoALphaALphaALphaALphaALphaALphaALphaALphaDdp3zK"
	if type(options.protocol) == "string" then
		protocol = options.protocol
	end

	log_info("Please confirm key import for client...")
	local process = proc.spawn("bin/client",
		{ "-p", protocol, "import", "secret", "key", alias or "baker", "http://" .. listen .. "/" .. mv4,
			options.force and "--force" or nil }, {
			stdio = "inherit",
			wait = true,
			env = { HOME = homedir },
			username = am.app.get("user"),
		})
	ami_assert(process.exit_code == 0, "Failed to import key to client!")

	log_success("mavsign key successfully imported.")
end

return setup
