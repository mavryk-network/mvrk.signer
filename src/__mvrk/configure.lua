local ok, err = fs.mkdirp("data")
ami_assert(ok, "failed to create data directory - " .. tostring(err))

local service_manager = require "__mvrk.service-manager"
local services = require "__mvrk.services"
service_manager.remove_services(services.cleanup_names) -- cleanup past install
service_manager.install_services(services.active)

-- adjust data directory permissions
require "__mvrk.base_utils".setup_file_permissions()
