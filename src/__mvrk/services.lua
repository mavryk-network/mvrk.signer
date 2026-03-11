local appId = am.app.get("id")
local signerServiceId = appId .. "-mvrk-signer"

local possibleResidue = {}

local signerServices = {
	[signerServiceId] = am.app.get_model("SIGNER_SERVICE_FILE", "__mvrk/assets/signer")
}
local tunnelServices = {
	[appId .. "-mvrk-signer-tunnel"] = "__mvrk/assets/signer-tunnel",
	[appId .. "-mvrk-node-tunnel"] = "__mvrk/assets/node-tunnel"
}

local signerServiceNames = {}
for k, _ in pairs(signerServices) do
	signerServiceNames[k:sub((#(appId .. "-mvrk-") + 1))] = k
end

local tunnelServiceNames = {}
for k, _ in pairs(tunnelServices) do
	tunnelServiceNames[k:sub((#(appId .. "-mvrk-") + 1))] = k
end

local activeServices = util.clone(signerServices)
local activeNames = util.clone(signerServiceNames)

local nodeAddr = am.app.get_model("REMOTE_NODE")
if type(nodeAddr) == "string" then
	for k, v in pairs(tunnelServiceNames) do
		activeNames[k] = v
	end
	for k, v in pairs(tunnelServices) do
		activeServices[k] = v
	end
end

---@type string[]
local cleanupNames = {}
cleanupNames = util.merge_arrays(cleanupNames, table.values(signerServiceNames))
cleanupNames = util.merge_arrays(cleanupNames, table.values(tunnelServiceNames))
cleanupNames = util.merge_arrays(cleanupNames, possibleResidue)

return {
	signerServiceId = signerServiceId,
	signerServiceNames = signerServiceNames,
	active = activeServices,
	active_names = activeNames,
	cleanup_names = cleanupNames,
}
