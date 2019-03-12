local gears = require("gears")
local lain  = require("lain")
local awful = require("awful")
local wibox = require("wibox")
local markup = require("lain.util.markup")
local naughty = require("naughty")
local os = { getenv = os.getenv }

local theme = {}
theme.color = {
    foreground = "#bbbbbb",
    background = "#0b0b0b",
    black = "#1b1918",
    white = "#cccccc",
    gray = "#4f4f4f",
    red = "#f22c40",
    green = "#5ab738",
    yellow = "#d5911a",
    blue = "#3971ed",
    magenta = "#e85b92",
    cyan = "#00ad9c",
    light_gray = "#848282",
    light_red = "#f85262",
    light_green = "#7bd15b",
    light_yellow = "#e9ad44",
    light_blue = "#5e8af1",
    light_magenta = "#f181ac",
    light_cyan = "#26b3a4"
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

theme.wibar_height = 20

theme.border_width = 1
theme.border_normal = theme.color.gray
theme.border_focus = theme.color.magenta
theme.border_marked = theme.color.red

theme.menu_height = 20
theme.menu_width = 140
theme.menu_submenu_icon = theme.dir .. "/icons/submenu.png"

theme.taglist_squares_sel = theme.dir .. "/icons/square_sel.png"
theme.taglist_squares_unsel = theme.dir .. "/icons/square_unsel.png"

theme.widget_music_icon = ""
theme.widget_music_icon_on = theme.magenta

theme.notification_font = theme.font
theme.notification_fg = theme.fg_normal
theme.notification_bg = theme.bg_normal
theme.notification_border_color = theme.border_focus
theme.notification_border_width = 5

theme.hotkeys_bg = theme.bg_normal
theme.hotkeys_fg = theme.fg_normal
theme.hotkeys_border_width = theme.border_width
theme.hotkeys_border_color = theme.border_focus
theme.hotkeys_font = theme.font
theme.hotkeys_description_font = theme.font
theme.hotkeys_modifiers_fg = theme.fg_urgent
theme.hotkeys_group_margin = 15

-- Clock
local date = wibox.widget.textclock("%a %d %b - %R ")
date.font = theme.font

-- Calendar
theme.cal = lain.widget.cal({
    attach_to = { date },
    notification_preset = {
        font = theme.font,
        fg   = theme.fg_normal,
        bg   = theme.bg_normal
    }
})

-- MPD
function format_time(s)
   return string.format("%d:%.2d", math.floor(s/60), s%60)
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
            title  = mpd_now.title
            if mpd_now.time ~= "N/A" and mpd_now.elapsed ~= "N/A" then
                time = string.format(" (%s/%s)", format_time(mpd_now.elapsed), format_time(mpd_now.time))
		        time = markup(theme.color.light_gray, time)
            end
            mpdicon:set_markup(markup(theme.widget_music_icon_on, theme.widget_music_icon))
        elseif mpd_now.state == "pause" then
            artist = " mpd "
            title  = "paused"
            mpdicon:set_markup(markup(theme.widget_music_icon_on, theme.widget_music_icon))
        else
            mpdicon:set_markup(markup(theme.fg_normal, theme.widget_music_icon))
        end

        widget:set_markup(markup.font(theme.font, markup(theme.widget_music_icon_on, artist) .. title .. time))
    end
})

-- VPN status
theme.vpn = wibox.widget.textbox()
theme.vpn.font = theme.font
awful.widget.watch("ip addr show wg0", 1,
    function(widget, stdout, stderr, exitreason, exitcode)
        local status_color = nil
        if(exitcode ~= 0) then
            status_color = theme.color.red
        else
            status_color = theme.color.green
        end
        widget.markup = markup(status_color, "VPN")
    end,
    theme.vpn
)


-- Separators
local spr = wibox.widget.textbox("   /   ")
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
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            --spr,
            s.mytaglist,
            s.mypromptbox,
        },
        space,
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            wibox.widget.systray(),
            spr,
            wibox.container.background(mpdicon, theme.bg_focus),
            wibox.container.background(theme.mpd.widget, theme.bg_focus),
            spr,
            theme.vpn,
            spr,
            date,
        },
    }
end

return theme
