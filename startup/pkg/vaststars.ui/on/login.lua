local archiving = import_package "vaststars.gamerender" "archiving"

return function (window)
    local archivinglst = archiving.list()
    local lastname = archivinglst[#archivinglst]
    local model = window.createModel {
        show_continue_game = (#archivinglst > 0),
    }
    function model.open(filename)
        window.open(filename)
    end
    function model.newgame(filename)
        window.callMessage("reboot", "new_game", filename)
        window.close()
    end
    function model.continue()
        window.callMessage("reboot", "restore", lastname)
        window.close()
    end
end
