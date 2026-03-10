local util = {}

function util.reset_datadir_permissions()
	local user = am.app.get("user", "root")
	ami_assert(type(user) == "string", "User not specified...", EXIT_INVALID_CONFIGURATION)

	local uid, err = fs.getuid(user)
	ami_assert(uid, "Failed to get " .. user .. "uid - " .. tostring(err))

	log_info("Granting access to " .. user .. "(" .. tostring(uid) .. ")...")
	local ok, error = fs.chown(os.cwd(), uid, uid, { recurse = true })
	ami_assert(ok, "Failed to chown data - " .. (error or ""))
end

return util
