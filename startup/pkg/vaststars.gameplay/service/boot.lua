local config = ...

local webserver = import_package "vaststars.webcgi"
local mode
if __ANT_RUNTIME__ then
	mode = "redirect"
else
	mode = "direct"
end

webserver.start(mode, config.web_address, config.web_port)
