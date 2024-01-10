local fs = require "filesystem"

return function (window, ...)
    local start = window.createModel(...)
    function start.onClickContinue()
        window.close()
    end
    function start.onClickReLogin()
        local audio = import_package "ant.audio"
        audio.play "event:/ui/button1"
        window.callMessage("relogin")
        window.close()
    end
end
