-- name = "Dice widget"
-- description = "Roll the Dice"
-- author = "Evgeny Zobnin (zobnin@gmail.com)"
-- foldable = "false"

local dices = {
    "fa:dice-one",
    "fa:dice-two",
    "fa:dice-three",
    "fa:dice-four",
    "fa:dice-five",
    "fa:dice-six",
}

function on_resume()
    ui:show_buttons{
        "Roll the dice",
        "fa:dice-six",
        "fa:dice-six",
    }
end

function on_click(idx)
    if idx == 1 then
        roll_dice(2)
        roll_dice(3)
    else
        roll_dice(idx)
    end
end

function roll_dice(idx)
    local tab = {}

    for i=1,10 do
        table.insert(tab, dices[math.random(1, 6)])
    end

    morph:change_text_seq(idx, tab, 150)
end

