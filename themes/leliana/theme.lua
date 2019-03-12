local gears = require("gears")
local lain = require("lain")
local awful = require("awful")
local wibox = require("wibox")
local markup = require("lain.util.markup")
local os = { getenv = os.getenv }
local xresources = require("beautiful.xresources")
local xrdb = xresources.get_current_theme()
local dpi = xresources.apply_dpi

local theme = {}
theme.color = {
    foreground = xrdb.foreground,
    background = xrdb.background,
    black = xrdb.colour0,
    white = xrdb.color7,
    gray = xrdb.color8,
    red = xrdb.color1,
    green = xrdb.color2,
    yellow = xrdb.color3,
    blue = xrdb.color4,
    magenta = xrdb.color5,
    cyan = xrdb.color6,
    light_gray = xrdb.color15,
    light_red = xrdb.color9,
    light_green = xrdb.color10,
    light_yellow = xrdb.color11,
    light_blue = xrdb.color12,
    light_magenta = xrdb.color13,
    light_cyan = xrdb.color14
}

theme.dir = os.getenv("HOME") .. "/.config/awesome/themes/leliana"
theme.wallpaper = theme.dir .. "/wall.png"
theme.font = "xos4 Terminus 11"

theme.fg_normal = theme.color.foreground
theme.fg_focus = theme.color.magenta
theme.fg_urgent = theme.color.red
theme.bg_normal = theme.color.background
theme.bg_focus = theme.color.background
theme.bg_urgent = theme.color.background

theme.wibar_height = dpi(20)

theme.border_width = dpi(1)
theme.border_normal = theme.color.gray
theme.border_focus = theme.color.magenta
theme.border_marked = theme.color.red

theme.menu_height = dpi(20)
theme.menu_width = dpi(140)
theme.menu_submenu_icon = theme.dir .. "/icons/submenu.png"

theme.widget_music_icon = ""
theme.widget_music_icon_on = theme.color.magenta

theme.notification_font = theme.font
theme.notification_fg = theme.fg_normal
theme.notification_bg = theme.bg_normal
theme.notification_border_color = theme.border_focus
theme.notification_border_width = dpi(5)

theme.hotkeys_bg = theme.bg_normal
theme.hotkeys_fg = theme.fg_normal
theme.hotkeys_border_width = theme.border_width
theme.hotkeys_border_color = theme.border_focus
theme.hotkeys_font = theme.font
theme.hotkeys_description_font = theme.font
theme.hotkeys_modifiers_fg = theme.color.magenta
theme.hotkeys_group_margin = dpi(15)

-- Clock
local date = wibox.widget.textclock(markup(theme.fg_normal, markup.font(theme.font, "%a %d %b - %R")))

-- Calendar
theme.cal = lain.widget.cal({
    attach_to = { date },
    notification_preset = {
        font = theme.font,
        fg = theme.fg_normal,
        bg = theme.bg_normal
    }
})

-- MPD
function format_time(s)
    return string.format("%d:%.2d", math.floor(s / 60), s % 60)
end

local mpdicon = wibox.widget.textbox(markup(theme.fg_normal, theme.widget_music_icon))
theme.mpd = lain.widget.mpd({
    timeout = 1,
    notify = "off",
    settings = function()
        local artist = ""
        local title = ""
        local time = ""
        if mpd_now.state == "play" then
            artist = " " .. mpd_now.artist .. " "
            title = mpd_now.title
            if mpd_now.time ~= "N/A" and mpd_now.elapsed ~= "N/A" then
                time = string.format(" (%s/%s)", format_time(mpd_now.elapsed), format_time(mpd_now.time))
                time = markup(theme.color.light_gray, time)
            end
            mpdicon:set_markup(markup(theme.widget_music_icon_on, theme.widget_music_icon))
        elseif mpd_now.state == "pause" then
            artist = " mpd "
            title = "paused"
            mpdicon:set_markup(markup(theme.widget_music_icon_on, theme.widget_music_icon))
        else
            mpdicon:set_markup(markup(theme.fg_normal, theme.widget_music_icon))
        end

        widget:set_markup(markup.font(theme.font, markup(theme.widget_music_icon_on, artist) .. title .. time))
    end
})

-- VPN status
theme.vpn = awful.widget.watch("ip addr show wg0", 5,
    function(widget, stdout, stderr, exitreason, exitcode)
        local status_color
        if exitcode ~= 0 then
            status_color = theme.color.red
        else
            status_color = theme.color.green
        end
        widget:set_markup(markup(status_color, markup.font(theme.font, "VPN")))
    end)

-- Separators
local spr = wibox.widget.textbox(markup(theme.color.gray, "  |  "))
local space = wibox.widget.textbox(" ")

function theme.at_screen_connect(s)
    -- If wallpaper is a function, call it with the screen
    local wallpaper = theme.wallpaper
    if type(wallpaper) == "function" then
        wallpaper = wallpaper(s)
    end
    gears.wallpaper.maximized(wallpaper, s, true)

    -- Tags
    awful.tag(awful.util.tagnames, s, awful.layout.layouts[1])

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, awful.util.taglist_buttons)

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s, height = theme.wibar_height, bg = theme.bg_normal, fg = theme.fg_normal })
    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        {
            -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            --spr,
            s.mytaglist,
            s.mypromptbox,
        },
        space,
        {
            -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            wibox.widget.systray(),
            spr,
            wibox.container.background(mpdicon, theme.bg_focus),
            wibox.container.background(theme.mpd.widget, theme.bg_focus),
            spr,
            theme.vpn,
            spr,
            date,
            space,
        },
    }
end

return theme
