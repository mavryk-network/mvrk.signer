local options = ...

local setupLedgerPlatform = require("__mvrk.ledger.platform")
local setupLedgerKey = require("__mvrk.ledger.key")
local setupLedgerAuthorize = require("__mvrk.ledger.authorize")

setupLedgerPlatform(options)
setupLedgerKey(options)
setupLedgerAuthorize(options)

-- reset permissions, because of platform setups we might run as root
require"__mvrk.util".reset_datadir_permissions()