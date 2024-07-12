function on_alarm()
    ai:complete("Who are you?")
end

function on_ai_answer(answer)
    ui:show_text(answer)
end
