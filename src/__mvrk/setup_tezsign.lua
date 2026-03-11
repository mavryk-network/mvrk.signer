local options = ...

local init = options.init
local import_key = options["import-key"]

if init and import_key then
    ami_error("The '--init' option cannot be used together with '--import-key' option.",
        EXIT_CLI_ARG_VALIDATION_ERROR)
end

local init = require("__mvrk.mavsign.init")
init(options)

local setup_mavsign_platform = require("__mvrk.mavsign.platform")
setup_mavsign_platform(options)

local setup_mavsign_password = require("__mvrk.mavsign.password")
setup_mavsign_password(options)

local setup_mavsign_key = require("__mvrk.mavsign.key")
setup_mavsign_key(options)

-- reset permissions, because of platform setups we might run as root
require"__mvrk.base_utils".setup_file_ownership()