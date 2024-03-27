
return function (window, recipe)
    local model = window.createModel(window.callMessage("science_detail|query", recipe))
    function model.close()
        window.close()
    end
end
