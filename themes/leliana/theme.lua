--[[

     Powerarrow Dark Awesome WM theme
     github.com/lcpz

--]]

local gears = require("gears")
local lain  = require("lain")
local awful = require("awful")
local wibox = require("wibox")

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

theme.border_width = 1
theme.border_normal = "#4F4F4F"
theme.border_focus = "#E85B92"
theme.border_marked = "#f22c40"

theme.menu_height = 20
theme.menu_width = 140
theme.menu_submenu_icon = theme.dir .. "/icons/submenu.png"

theme.taglist_squares_sel = theme.dir .. "/icons/square_sel.png"
theme.taglist_squares_unsel = theme.dir .. "/icons/square_unsel.png"

theme.layout_tile = theme.dir .. "/icons/tile.png"
theme.layout_tileleft = theme.dir .. "/icons/tileleft.png"
theme.layout_tilebottom = theme.dir .. "/icons/tilebottom.png"
theme.layout_tiletop = theme.dir .. "/icons/tiletop.png"
theme.layout_fairv = theme.dir .. "/icons/fairv.png"
theme.layout_fairh = theme.dir .. "/icons/fairh.png"
theme.layout_spiral = theme.dir .. "/icons/spiral.png"
theme.layout_dwindle = theme.dir .. "/icons/dwindle.png"
theme.layout_max = theme.dir .. "/icons/max.png"
theme.layout_fullscreen = theme.dir .. "/icons/fullscreen.png"
theme.layout_magnifier = theme.dir .. "/icons/magnifier.png"
theme.layout_floating = theme.dir .. "/icons/floating.png"
theme.useless_gap = 0

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

local markup = lain.util.markup
local separators = lain.util.separators

-- Date
local date = awful.widget.watch(
    "date +'%a %d %b'", 1,
    function(widget, stdout)
        widget:set_markup(markup.font(theme.font, stdout))
    end
)

-- Textclock
local clock = awful.widget.watch(
    "date +'%R'", 1,
    function(widget, stdout)
        widget:set_markup(markup.font(theme.font, stdout))
    end
)

-- Calendar
theme.cal = lain.widget.calendar({
    attach_to = { clock },
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

-- Net
local net = lain.widget.net({
    notify = "off",
    settings = function()
        widget:set_markup(markup.font(theme.font,
            markup("#7AC82E", "▼ " .. net_now.received) .. " " .. markup("#46A8C3", net_now.sent .. " ▲")))
    end
})

-- Separators
local spr = wibox.widget.textbox("   ∕   ")
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
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(my_table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, awful.util.taglist_buttons)

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s, height = 25, bg = theme.bg_normal, fg = theme.fg_normal })
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
            net,
            spr,
            date,
            spr,
            clock,
            spr,
            wibox.container.background(s.mylayoutbox, theme.bg_focus),
        },
    }
end

return theme
