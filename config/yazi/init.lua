function Linemode:owner_size_mtime()
    local file = self._file

    --- DATA ---
    local time = math.floor(file.cha.mtime or 0)
    if time == 0 then
        time = ""
    elseif os.date("%Y", time) == os.date("%Y") then
        time = os.date("%b %d %I:%M%p", time)
    else
        time = os.date("%b %d, %Y", time)
    end

    local owner = ya.user_name(file.cha.uid) or self._file.cha.uid

    local size  = file:size()
    size        = size and ya.readable_size(size) or "-"

    --- STYLING ---
    local style_owner = ui.Style():fg("yellow")
    local style_size  = ui.Style():fg("green")
    local style_time  = ui.Style():fg("white")

    local is_hovered = false
    local ok, result = pcall(function()
        if cx and cx.active and cx.active.current and cx.active.current.hovered then
            return tostring(cx.active.current.hovered.url) == tostring(file.url)
        end
        return false
    end)
    if ok then is_hovered = result end

    if is_hovered then
        style_owner = ui.Style():fg("black")
        style_size  = ui.Style():fg("black")
        style_time  = ui.Style():fg("black")
    end

    --- FORMATTING ---
    local icon_owner  = ""
    --local icon_size   = ""
    --local icon_time   = "󰃰"

    local owner_span  = ui.Span(string.format("%s %-12s", icon_owner, owner)):style(style_owner)
    --local size_span   = ui.Span(string.format("%s %6s", icon_size, size)):style(style_size)
    local size_span   = ui.Span(string.format("%7s", size)):style(style_size)
    local time_span   = ui.Span(string.format("%16s", time)):style(style_time)

    return ui.Line { owner_span, ui.Span(" "), size_span, time_span }
end
