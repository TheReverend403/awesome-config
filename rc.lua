--[[

     Awesome WM configuration
     Based on github.com/lcpz/awesome-copycats

--]]

-- {{{ Required libraries
local awesome, client, mouse, screen, tag = awesome, client, mouse, screen, tag
local ipairs, string, os, table, tostring, tonumber, type = ipairs, string, os, table, tostring, tonumber, type

local gears = require("gears")
local awful = require("awful")
              require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local lain = require("lain")
local hotkeys_popup = require("awful.hotkeys_popup").widget
require("eminent")

local my_table = awful.util.table or gears.table -- 4.{0,1} compatibility
-- }}}

-- {{{ Error handling
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

 -- disable startup-notification globally
local oldspawn = awful.spawn
awful.spawn = function (s)
    oldspawn(s, false)
end

-- {{{ Variable definitions

local chosen_theme = "leliana"
local modkey = "Mod4"
local altkey = "Mod1"
local terminal = "urxvt"
local editor = os.getenv("EDITOR") or "nano"
local browser = "firefox"
local guieditor = "code"
local irc = terminal .. " -name weechat +sb -e weechat"

awful.util.terminal = terminal
awful.util.tagnames = { "1", "2", "3", "4", "5", "6", "7", "8", "9" }
awful.layout.layouts = {
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    --awful.layout.suit.spiral.dwindle,
    --awful.layout.suit.magnifier,
    --awful.layout.suit.max.fullscreen,
    --awful.layout.suit.corner.nw,
    --awful.layout.suit.corner.ne,
    --awful.layout.suit.corner.sw,
    --awful.layout.suit.corner.se,
}
awful.util.taglist_buttons = my_table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                )

lain.layout.termfair.nmaster = 3
lain.layout.termfair.ncol = 1
lain.layout.termfair.center.nmaster = 3
lain.layout.termfair.center.ncol = 1
lain.layout.cascade.tile.offset_x = 2
lain.layout.cascade.tile.offset_y = 32
lain.layout.cascade.tile.extra_padding = 5
lain.layout.cascade.tile.nmaster = 5
lain.layout.cascade.tile.ncol = 2


local theme_path = string.format("%s/.config/awesome/themes/%s/theme.lua", os.getenv("HOME"), chosen_theme)
beautiful.init(theme_path)
-- }}}

-- {{{ Menu
generalmenu = {
    { "browser", browser },
    { "telegram", "telegram-desktop" },
    { "irc", irc },
    { "email", "thunderbird" },
    { "gimp", "gimp"},
    { "files", "thunar" },
    { "editor", guieditor },
}

devmenu = {
    { "idea", "idea" },
    { "pycharm", "pycharm-community" },
    { "android studio", "android-studio" },
}

gamesmenu = {
    { "steam", "steam" },
    { "kotor 2", "lutris lutris:rungame/star-wars-knights-of-the-old-republic-ii" },
    { "minecraft", string.format("java -jar %s/.minecraft/Minecraft.jar", home) },
    { "mgba", "mgba-qt" },
}

awesomemenu = {
    { "config", guieditor .. " " .. gears.filesystem.get_configuration_dir() .. "/" },
    { "restart", awesome.restart },
    { "quit", function () awesome.quit() end },
}

systemmenu = {
    { "awesome", awesomemenu },
    { "lock", "awesomeexit lock" },
    { "reboot", "awesomeexit reboot" },
    { "shutdown", "awesomeexit shutdown" }
}

awful.util.mymainmenu = awful.menu({
    items = {
        { "terminal", terminal },
        { "general", generalmenu },
        { "dev", devmenu },
        { "games", gamesmenu },
        { "system", systemmenu },
    }
})
-- }}}

-- {{{ Screen
-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", function(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end)

-- Create a wibox for each screen and add it
awful.screen.connect_for_each_screen(function(s) beautiful.at_screen_connect(s) end)
-- }}}

-- {{{ Mouse bindings
root.buttons(my_table.join(
    awful.button({ }, 3, function () awful.util.mymainmenu:toggle() end)
))
-- }}}

-- {{{ Key bindings
globalkeys = my_table.join(
    -- Take a screenshot
    awful.key({ modkey }, "s", function() awful.spawn("pstepw -s") end,
              {description = "take a screenshot", group = "hotkeys"}),

    -- X screen locker
    awful.key({ modkey }, "l", function () awful.spawn("awesomeexit lock") end,
              {description = "lock screen", group = "hotkeys"}),

    -- Hotkeys
    awful.key({ modkey }, "h",      hotkeys_popup.show_help,
              {description = "show help", group="awesome"}),

    -- By direction client focus
    awful.key({ modkey }, "Down",
        function()
            awful.client.focus.global_bydirection("down")
            if client.focus then client.focus:raise() end
        end,
        {description = "focus by direction", group = "client"}),
    awful.key({ modkey }, "Up",
        function()
            awful.client.focus.global_bydirection("up")
            if client.focus then client.focus:raise() end
        end,
        {description = "focus by direction", group = "client"}),
    awful.key({ modkey }, "Left",
        function()
            awful.client.focus.global_bydirection("left")
            if client.focus then client.focus:raise() end
        end,
        {description = "focus by direction", group = "client"}),
    awful.key({ modkey }, "Right",
        function()
            awful.client.focus.global_bydirection("right")
            if client.focus then client.focus:raise() end
        end,
        {description = "focus by direction", group = "client"}),
    awful.key({ modkey }, "w", function () awful.util.mymainmenu:show() end,
              {description = "show main menu", group = "awesome"}),

    -- Layout manipulation
    awful.key({ modkey, "Shift" }, "Right", function () awful.client.swap.global_bydirection("right") end,
              {description = "swap client by direction", group = "client"}),

    awful.key({ modkey, "Shift" }, "Left", function () awful.client.swap.global_bydirection("left") end,
              {description = "swap client by direction", group = "client"}),

    awful.key({ modkey, "Shift" }, "Up", function () awful.client.swap.global_bydirection("up") end,
              {description = "swap client by direction", group = "client"}),

    awful.key({ modkey, "Shift" }, "Down", function () awful.client.swap.global_bydirection("down") end,
              {description = "swap client by direction", group = "client"}),

    awful.key({ modkey }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),

    awful.key({ modkey }, "Tab",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "cycle open clients", group = "client"}),

    -- Standard program
    awful.key({ modkey, "Shift" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),

    awful.key({ modkey }, "space", function () awful.layout.inc( 1) end,
              {description = "select next", group = "layout"}),

    awful.key({ modkey, "Shift" }, "space", function () awful.layout.inc(-1) end,
              {description = "select previous", group = "layout"}),

    -- MPD control
    awful.key({ "Control", altkey }, "Up",
        function ()
            awful.spawn("mpc toggle")
            beautiful.mpd.update()
        end,
        {description = "toggle", group = "mpd"}),

    awful.key({ "Control", altkey }, "Down",
        function ()
            awful.spawn("mpc stop")
            beautiful.mpd.update()
        end,
        {description = "stop", group = "mpd"}),

    awful.key({ "Control", altkey }, "Left",
        function ()
            awful.spawn("mpc prev")
            beautiful.mpd.update()
        end,
        {description = "prev", group = "mpd"}),

    awful.key({ "Control", altkey }, "Right",
        function ()
            awful.spawn("mpc next")
            beautiful.mpd.update()
        end,
        {description = "next", group = "mpd"}),

    awful.key({ altkey }, "Left",
        function()
            awful.util.spawn("mpc seek -00:00:05")
            beautiful.mpd.update()
        end,
	{ description = "seek 5s", group = "mpd"}),

    awful.key({ altkey }, "Right",
        function()
            awful.util.spawn("mpc seek +00:00:05")
            beautiful.mpd.update()
        end,
	{ description = "seek 5s", group = "mpd"}),

    -- User programs
    awful.key({ modkey }, "Return", function () awful.spawn(terminal) end,
              {description = "terminal", group = "launcher"}),

    awful.key({ modkey }, "b", function () awful.spawn(browser) end,
              {description = "browser", group = "launcher"}),

    awful.key({ modkey }, "e", function () awful.spawn("thunderbird") end,
              {description = "email", group = "launcher"}),

    awful.key({ modkey }, "f", function () awful.spawn("thunar") end,
              {description = "files", group = "launcher"}),

    awful.key({ modkey }, "c", function () awful.spawn("code") end,
              {description = "editor", group = "launcher"}),

    awful.key({ modkey }, "i", function() awful.spawn(irc) end,
              {description = "irc", group = "launcher"}),

    awful.key({ modkey }, "p", function() awful.spawn("passmenu -i -p 'passmenu:' ", false) end,
              {description = "passmenu", group = "launcher"}),

    awful.key({ modkey }, "t", function() awful.spawn("telegram-desktop", false) end,
              {description = "telegram", group = "launcher"}),

    awful.key({ modkey }, "m", function() awful.spawn(terminal .. " -geometry 130x40 -name vimpc +sb -e vimpc", false) end,
              {description = "music", group = "launcher"}),

    awful.key({ modkey }, "d", function () awful.spawn("rofi -show run") end,
              {description = "rofi", group = "launcher"}),

    awful.key({}, "XF86Calculator", function () awful.spawn("galculator") end,
              {description = "calculator", group = "launcher"}),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run {
                    prompt = "Run Lua code: ",
                    textbox = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                  }
              end,
              {description = "lua prompt", group = "awesome"})
)

clientkeys = my_table.join(
    awful.key({ modkey, "Shift" }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),

    awful.key({ modkey, "Shift"  }, "q", function (c) c:kill() end,
              {description = "close", group = "client"}),

    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle,
              {description = "toggle floating", group = "client"}),

    awful.key({ modkey, "Shift" }, "o", function (c) c:move_to_screen() end,
              {description = "move to screen", group = "client"}),

    awful.key({ modkey, "Shift" }, "t", function (c) c.ontop = not c.ontop end,
              {description = "toggle keep on top", group = "client"}),

    awful.key({ modkey, "Shift" }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end,
        {description = "maximize", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    -- Hack to only show tags 1 and 9 in the shortcut window (mod+s)
    local descr_view, descr_toggle, descr_move, descr_toggle_focus
    if i == 1 or i == 9 then
        descr_view = {description = "view tag #", group = "tag"}
        descr_toggle = {description = "toggle tag #", group = "tag"}
        descr_move = {description = "move focused client to tag #", group = "tag"}
    end

    globalkeys = my_table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  descr_view),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  descr_move)
    )
end

clientbuttons = my_table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { 
        rule = { },
        properties = {
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            raise = false,
            keys = clientkeys,
            buttons = clientbuttons,
            screen = awful.screen.preferred,
            placement = awful.placement.no_overlap+awful.placement.no_offscreen+awful.placement.centered,
            size_hints_honor = false
        }
    },

    { 
        rule = { class = "Firefox" },
        properties = { screen = 1, tag = awful.util.tagnames[1] } 
    },

    {
        rule = { class = "Telegram*" },
        properties = { screen = 1, tag = awful.util.tagnames[2] }
    },

    { 
        rule = { class = "Gimp", role = "gimp-image-window" },
        properties = { maximized = true }
    },
    
    {
        rule = { class = "Minecraft*" },
        properties = { fullscreen = true }
    },

    {
        rule = { name = "weechat" },
        properties = { maximised = true, screen = 2, tag = awful.util.tagnames[1] }
    },

    {
        rule = { class = "Thunderbird" },
        properties = { screen = 1, tag = awful.util.tagnames[3] }
    },

    -- Floating clients
    {
        rule_any = {
            class = {
                "Gucharmap", "Galculator", "mpv", "Qbittorrent",
                "Transmission", "vim", "Pcmanfm", "vimpc",
                "ranger", "feh", "Xarchiver", "Pinentry-gtk-2",
                "Sxiv", "Pavucontrol", "mgba-sdl", "mgba-qt", "mGBA",
                "Thunar", "float-term", "Lutris"
                },
            name = { "float-term", "mutt", "vimpc", "ranger" },
            role = { "task_dialog", "pop-up" },
            type = { "dialog" },
            instance = { "plugin-container" }
        },
        properties = { floating = true }
    },


}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup and
      not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        and awful.client.focus.filter(c) then
        client.focus = c
    end
end)

-- No border for maximized clients
function border_adjust(c)
    if c.maximized then -- no borders if only 1 client visible
        c.border_width = 0
    elseif #awful.screen.focused({ client = true }).clients > 1 then
        c.border_width = beautiful.border_width
        c.border_color = beautiful.border_focus
    else
        c.border_width = 0
    end
end


-- {{{ No DPMS for fullscreen clients
local fullscreened_clients = {}

function dpms_disable(c)
    if c.fullscreen then
        table.insert(fullscreened_clients, c)
        if #fullscreened_clients == 1 then
            awful.spawn("xset s off")
            awful.spawn("xset -dpms")
        end
    else
        remove_client(fullscreened_clients, c)
    end
end

function remove_client(tabl, c)
    local index = awful.util.table.hasitem(tabl, c)
    if index then
        table.remove(tabl, index)
        if #tabl == 0 then
            awful.spawn("xset s on")
            awful.spawn("xset +dpms")
        end
    end
end


function dpms_enable(c)
    if c.fullscreen then
        remove_client(fullscreened_clients, c)
    end
end

-- }}}

client.connect_signal("unmanage", dpms_enable)
client.connect_signal("property::fullscreen", dpms_disable)
client.connect_signal("focus", border_adjust)
client.connect_signal("unfocus", border_adjust)
client.connect_signal("property::maximized", border_adjust)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
