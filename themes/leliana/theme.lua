--[[

     Powerarrow Dark Awesome WM theme
     github.com/lcpz

--]]

local gears = require("gears")
local lain  = require("lain")
local awful = require("awful")
local wibox = require("wibox")
local markup = require("lain.util.markup")

local os = { getenv = os.getenv }
local my_table = awful.util.table or gears.table -- 4.{0,1} compatibility

local theme = {}

theme.dir = os.getenv("HOME") .. "/.config/awesome/themes/leliana"
theme.wallpaper = theme.dir .. "/wall.png"
theme.font = "xos4 Terminus 10"

theme.fg_normal = "#BBBBBB"
theme.fg_focus = "#E85B92"
theme.fg_urgent = "#f22c40"
theme.bg_normal = "#0B0B0B"
theme.bg_focus = "#0B0B0B"
theme.bg_urgent = "#4F4F4F"

theme.wibar_height = 20

theme.border_width = 1
theme.border_normal = "#4F4F4F"
theme.border_focus = "#E85B92"
theme.border_marked = "#f22c40"

theme.menu_height = 20
theme.menu_width = 140
theme.menu_submenu_icon = theme.dir .. "/icons/submenu.png"

theme.taglist_squares_sel = theme.dir .. "/icons/square_sel.png"
theme.taglist_squares_unsel = theme.dir .. "/icons/square_unsel.png"

theme.widget_music_icon = ""
theme.widget_music_icon_on = "#E85B92"

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
		        time = markup("#848282", time)
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

-- Separators
local spr = wibox.widget.textbox("  /  ")
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
            date,
        },
    }
end

return theme
