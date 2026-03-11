local service_manager = require "__mvrk.service-manager"
local services = require "__mvrk.services"
log_info("Stopping signer services... this may take few minutes.")
service_manager.stop_services(services.active_names)
log_success("Signer services succesfully stopped.")
