local archiving = import_package "vaststars.gamerender" "archiving"

return function (window)
    local archivinglst = archiving.list()
    local lastname = archivinglst[#archivinglst]
    local model = window.createModel {
        show_continue_game = (#archivinglst > 0),
    }
    local audio = import_package "ant.audio"
    function model.open(filename)
        audio.play "event:/ui/button1"
        window.open(filename)
    end
    function model.newgame(filename)
        audio.play "event:/ui/button1"
        window.callMessage("reboot", "new_game", filename)
        window.close()
    end
    function model.continue()
        audio.play "event:/ui/button1"
        window.callMessage("reboot", "restore", lastname)
        window.close()
    end
end
