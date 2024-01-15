local fs = require "filesystem"

return function (window, ...)
    local start = window.createModel(...)
    function start.onClickContinue()
        window.close()
    end
    function start.onClickReLogin()
        window.callMessage("reboot", "new_game", "template.tutorial-end")
        window.close()
    end
end
