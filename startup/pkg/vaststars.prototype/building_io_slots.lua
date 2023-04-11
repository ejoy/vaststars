local building_io_slots = {
    --['xy']中x为进料数量、y为出货数量。例如['12']表示1个进料2个出货
    --in_slots为进料端的槽位
    --out_slots为出货端的槽位
    ['01'] = {
        in_slots = {},
        out_slots = {'5'},
    },
    ['11'] = {
        in_slots = {'2'},
        out_slots = {'5'},
    },
    ['12'] = {
        in_slots = {'2'},
        out_slots = {'4', '6'},
    },
    ['13'] = {
        in_slots =  {'2'},
        out_slots  = {'4', '5', '6'},
    },
    ['21'] = {
        in_slots = {'1','3'},
        out_slots = {'5'},
    },
    ['22'] = {
        in_slots = {'1','3'},
        out_slots = {'4','6'},
    },
    ['23'] = {
        in_slots = {'1','3'},
        out_slots = {'4','5','6'},
    },
    ['24'] = {
        in_slots = {'1','4'},
        out_slots = {'2','3','5','6'},
    },
    ['31'] = {
        in_slots = {'1','2','3'},
        out_slots = {'5'},
    },
    ['32'] = {
        in_slots = {'1','2','3'},
        out_slots = {'4','6'},
    },
    ['33'] = {
        in_slots = {'1','2','3'},
        out_slots = {'4','5','6'},
    },
    ['41'] = {
        in_slots = {'1','3','4','6'},
        out_slots = {'5'},
    },
    ['42'] = {
        in_slots = {'1','3','4','6'},
        out_slots = {'2','5'},
    },
    ['51'] = {
        in_slots = {'1','2','3','4','6'},
        out_slots = {'5'},
    },
}
return building_io_slots