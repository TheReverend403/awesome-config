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

-- {{{ Error handling
if awesome.startup_errors then
    naughty.notify({
        preset = naughty.config.presets.critical,
        title = "Oops, there were errors during startup!",
        text = awesome.startup_errors
    })
end

do
    local in_error = false
    awesome.connect_signal("debug::error", function(err)
        if in_error then return end
        in_error = true

        naughty.notify({
            preset = naughty.config.presets.critical,
            title = "Oops, an error happened!",
            text = tostring(err)
        })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
local chosen_theme = "lelianux"
local modkey = "Mod4"
local altkey = "Mod1"
local terminal = "alacritty"
local browser = os.getenv("BROWSER") or "firefox"
local irc = string.format("%s --title=weechat -e weechat", terminal)
-- }}}

awful.util.terminal = terminal
awful.util.tagnames = { "1", "2", "3", "4", "5" , "6", "7", "8", "9"}

awful.util.taglist_buttons = gears.table.join(awful.button({}, 1, function(t) t:view_only() end),
    awful.button({ modkey }, 1, function(t)
        if client.focus then
            client.focus:move_to_tag(t)
        end
    end),
    awful.button({}, 3, awful.tag.viewtoggle),
    awful.button({ modkey }, 3, function(t)
        if client.focus then
            client.focus:toggle_tag(t)
        end
    end),
    awful.button({}, 4, function(t) awful.tag.viewnext(t.screen) end),
    awful.button({}, 5, function(t) awful.tag.viewprev(t.screen) end))

local theme_path = string.format("%s/themes/%s/theme.lua", gears.filesystem.get_configuration_dir(), chosen_theme)
beautiful.init(theme_path)

-- https://www.reddit.com/r/awesomewm/comments/9lvkvg/increase_margin_to_the_text_inside_notifications/e7bgz44/
naughty.config.defaults.border_width = beautiful.notification_border_width
naughty.config.defaults.notification_icon_size = beautiful.notification_icon_size

-- {{{
local function file_exists(name)
   local f = io.open(name, "r")
   if f ~= nil then
       io.close(f)
       return true
    else
        return false
    end
end

local function run_once(cmd_arr)
    for _, cmd in ipairs(cmd_arr) do
        awful.spawn.with_shell(string.format("pgrep -u $USER -fx '%s' > /dev/null || (%s)", cmd, cmd))
    end
end

if not file_exists(string.format("%s/.noautostart", os.getenv("HOME"))) then
    run_once({browser, "telegram-desktop"})
end

-- }}}

-- {{{ Menu
awful.util.mymainmenu = awful.menu({
    items = {
        { "reload", awesome.restart },
        { "logout", function () awesome.quit() end },
        { "lock", "awesomeexit lock" },
        { "reboot", "awesomeexit reboot" },
        { "shutdown", "awesomeexit shutdown" }
    }
})
-- }}}

-- {{{ Screen
-- awful.screen.set_auto_dpi_enabled(true)
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

-- No borders when rearranging only 1 non-floating or maximized client
screen.connect_signal("arrange", function (s)
    local only_one = #s.tiled_clients == 1
    for _, c in pairs(s.clients) do
        if only_one and not c.floating or c.maximized then
            c.border_width = 0
        else
            c.border_width = beautiful.border_width
        end
    end
end)

-- Create a wibox for each screen and add it
awful.screen.connect_for_each_screen(function(s) beautiful.at_screen_connect(s) end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(awful.button({}, 3, function() awful.util.mymainmenu:toggle() end)))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(-- Take a screenshot
    awful.key({}, "Print", function() awful.spawn("pstepw") end,
        { description = "take a screenshot", group = "hotkeys" }),

    awful.key({ modkey }, "s", function() awful.spawn("pstepw -s") end,
        { description = "take a screenshot (selection)", group = "hotkeys" }),

    -- Upload contents of clipboard
    awful.key({ modkey, "Shift" }, "s", function() awful.spawn("pstepw -p") end,
        { description = "upload text from clipboard", group = "hotkeys" }),

    -- rofimoji
    awful.key({ modkey, "Shift" }, "e", function() awful.spawn("emoji") end,
        { description = "emoji picker", group = "hotkeys" }),

    -- X screen locker
    awful.key({ modkey }, "l", function() awful.spawn("awesomeexit lock") end,
        { description = "lock screen", group = "hotkeys" }),

    -- Hotkeys
    awful.key({ modkey }, "h", hotkeys_popup.show_help,
        { description = "show help", group = "awesome" }),

    -- By direction client focus
    awful.key({ modkey }, "Down",
        function()
            awful.client.focus.global_bydirection("down")
            if client.focus then client.focus:raise() end
        end,
        { description = "focus by direction", group = "client" }),

    awful.key({ modkey }, "Up",
        function()
            awful.client.focus.global_bydirection("up")
            if client.focus then client.focus:raise() end
        end,
        { description = "focus by direction", group = "client" }),

    awful.key({ modkey }, "Left",
        function()
            awful.client.focus.global_bydirection("left")
            if client.focus then client.focus:raise() end
        end,
        { description = "focus by direction", group = "client" }),

    awful.key({ modkey }, "Right",
        function()
            awful.client.focus.global_bydirection("right")
            if client.focus then client.focus:raise() end
        end,
        { description = "focus by direction", group = "client" }),

    -- Layout manipulation
    awful.key({ modkey, "Shift" }, "Right", function() awful.client.swap.global_bydirection("right") end,
        { description = "swap client by direction", group = "client" }),

    awful.key({ modkey, "Shift" }, "Left", function() awful.client.swap.global_bydirection("left") end,
        { description = "swap client by direction", group = "client" }),

    awful.key({ modkey, "Shift" }, "Up", function() awful.client.swap.global_bydirection("up") end,
        { description = "swap client by direction", group = "client" }),

    awful.key({ modkey, "Shift" }, "Down", function() awful.client.swap.global_bydirection("down") end,
        { description = "swap client by direction", group = "client" }),

    awful.key({ altkey, "Shift" }, "Right", function () awful.tag.incmwfact(0.02) end,
        { description = "resize client by direction", group = "client"}),

    awful.key({ altkey, "Shift" }, "Left", function () awful.tag.incmwfact(-0.02) end,
        { description = "resize client by direction", group = "client"}),

    awful.key({ altkey, "Shift" }, "Down", function () awful.client.incwfact(0.02) end,
        { description = "resize client by direction", group = "client"}),

    awful.key({ modkey }, "u", awful.client.urgent.jumpto,
        { description = "jump to urgent client", group = "client" }),

    awful.key({ modkey }, "Tab",
        function()
            awful.client.focus.byidx(-1)
            if client.focus then
                client.focus:raise()
            end
        end,
        { description = "cycle open clients", group = "client" }),

    awful.key({ modkey, "Shift" }, "r", awesome.restart,
        { description = "reload awesome", group = "awesome" }),

    -- MPD control
    awful.key({ "Control", altkey }, "Up",
        function()
            awful.spawn("mpc toggle")
            beautiful.mpd.update()
        end,
        { description = "toggle", group = "mpd" }),

    awful.key({ "Control", altkey }, "Down",
        function()
            awful.spawn("mpc stop")
            beautiful.mpd.update()
        end,
        { description = "stop", group = "mpd" }),

    awful.key({ "Control", altkey }, "Left",
        function()
            awful.spawn("mpc prev")
            beautiful.mpd.update()
        end,
        { description = "prev", group = "mpd" }),

    awful.key({ "Control", altkey }, "Right",
        function()
            awful.spawn("mpc next")
            beautiful.mpd.update()
        end,
        { description = "next", group = "mpd" }),

    awful.key({ altkey }, "Left",
        function()
            awful.util.spawn("mpc seek -00:00:05")
            beautiful.mpd.update()
        end,
        { description = "seek 5s", group = "mpd" }),

    awful.key({ altkey }, "Right",
        function()
            awful.util.spawn("mpc seek +00:00:05")
            beautiful.mpd.update()
        end,
        { description = "seek 5s", group = "mpd" }),

    -- User programs
    awful.key({ modkey }, "Return", function() awful.spawn(terminal) end,
        { description = "terminal", group = "launcher" }),

    awful.key({ modkey }, "b", function() awful.spawn(browser) end,
        { description = "browser", group = "launcher" }),

    awful.key({ modkey }, "e", function() awful.spawn("thunderbird") end,
        { description = "email", group = "launcher" }),

    awful.key({ modkey }, "f", function() awful.spawn("thunar") end,
        { description = "files", group = "launcher" }),

    awful.key({ modkey }, "i", function() awful.spawn(irc) end,
        { description = "irc", group = "launcher" }),

    awful.key({ modkey }, "t", function() awful.spawn("telegram-desktop") end,
        { description = "telegram", group = "launcher" }),

    awful.key({ modkey }, "m", function() awful.spawn(string.format("%s --dimensions %s %s --title=ncmpcpp -e ncmpcpp", terminal, 115, 30)) end,
        { description = "music", group = "launcher" }),

    awful.key({ modkey }, "d", function () awful.spawn("rofi -show run") end,
        {description = "run prompt", group = "launcher"}),

    awful.key({}, "XF86Calculator", function() awful.spawn("galculator") end,
        { description = "calculator", group = "launcher" }),

    awful.key({ modkey }, "x",
        function()
            awful.prompt.run {
                prompt = "Run Lua code: ",
                textbox = awful.screen.focused().mypromptbox.widget,
                exe_callback = awful.util.eval,
                history_path = string.format("%s/history_eval", gears.filesystem.get_cache_dir())
            }
        end,
        { description = "lua prompt", group = "awesome" }))

clientkeys = gears.table.join(awful.key({ modkey, "Shift" }, "f",
    function(c)
        c.fullscreen = not c.fullscreen
        c:raise()
    end,
    { description = "toggle fullscreen", group = "client" }),

    awful.key({ modkey, "Shift" }, "q", function(c) c:kill() end,
        { description = "close", group = "client" }),

    awful.key({ modkey, "Control" }, "space", awful.client.floating.toggle,
        { description = "toggle floating", group = "client" }),

    awful.key({ modkey, "Shift" }, "o", function(c) c:move_to_screen() end,
        { description = "move to screen", group = "client" }),

    awful.key({ modkey, "Control" }, "t", function(c) c.ontop = not c.ontop end,
        { description = "toggle keep on top", group = "client" }),

    awful.key({ modkey, "Control" }, "s", function(c) c.sticky = not c.sticky end,
        { description = "toggle sticky client", group = "client" }),

    awful.key({ modkey, "Shift" }, "m",
        function(c)
            c.maximized = not c.maximized
            c:raise()
        end,
        { description = "maximize", group = "client" }))

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    -- Hack to only show tags 1 and 9 in the shortcut window (mod+s)
    local descr_view, descr_toggle, descr_move, descr_toggle_focus
    if i == 1 or i == 9 then
        descr_view = { description = "view tag #", group = "tag" }
        descr_toggle = { description = "toggle tag #", group = "tag" }
        descr_move = { description = "move focused client to tag #", group = "tag" }
    end

    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, string.format("#%s", i + 9),
            function()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                    tag:view_only()
                end
            end,
            descr_view),

        -- Move client to tag.
        awful.key({ modkey, "Shift" }, string.format("#%s", i + 9),
            function()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then
                        client.focus:move_to_tag(tag)
                    end
                end
            end,
            descr_move))
end

clientbuttons = gears.table.join(awful.button({}, 1, function(c) client.focus = c; c:raise() end),
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
        rule = {},
        properties = {
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            raise = false,
            keys = clientkeys,
            buttons = clientbuttons,
            screen = awful.screen.preferred,
            placement = awful.placement.no_overlap + awful.placement.no_offscreen + awful.placement.centered,
            size_hints_honor = false
        }
    },

    {
        rule_any = { class = { "Firefox", "Chromium-browser-chromium" }, },
        properties = { screen = 1, tag = awful.util.tagnames[1] }
    },

    {
        rule = { class = "TelegramDesktop" },
        properties = { screen = 1, tag = awful.util.tagnames[2] }
    },

    {
        rule = { name = "weechat" },
        properties = { screen = 1, tag = awful.util.tagnames[3] }
    },

    {
        rule = { class = "Gimp", role = "gimp-image-window" },
        properties = { maximized = true }
    },

    {
        rule = { class = "Dwarf_Fortress" },
        properties = { maximised = true }
    },

    {
        rule = { class = "hl2_linux" },
        properties = { fullscreen = true }
    },

    -- {{{ Floating clients
    {
        rule = { class = "Firefox", name = "Library" },
        properties = { floating = true }
    },

    {
        rule_any = {
            class = {
                "Gucharmap", "Galculator", "mpv", "vim", "ncmpcpp", "Deluge",
                "Xarchiver", "Pinentry-gtk-2", "Sxiv", "Pavucontrol", "mgba-sdl", "mgba-qt",
                "mGBA", "Thunar", "File-roller", "float-term", "Lxappearance", "Pavucontrol",
                "dwarftherapist", "Dwarf_Fortress", "SoundCenSeGTK", "Nvidia-settings", "Code",
                "minecraft-launcher", "jetbrains-pycharm", "Virt-manager", "net-technicpack-launcher-LauncherMain"
            },
            name = { "Friends List", "float-term", "Minecraft*", "ncmpcpp", "PyLNP", "Address Book", "Thunderbird Preferences" },
            role = { "task_dialog", "pop-up", "GtkFileChooserDialog" },
            type = { "dialog" },
            instance = { "plugin-container", "Msgcompose" }
        },
        properties = { floating = true }
    },
    -- }}}
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
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

-- {{{ No DPMS for fullscreen clients
local fullscreened_clients = {}

local function remove_client(tabl, c)
    local index = awful.util.table.hasitem(tabl, c)
    if index then
        table.remove(tabl, index)
        if #tabl == 0 then
            awful.spawn("xset s on")
            awful.spawn("xset +dpms")
        end
    end
end

local function dpms_disable(c)
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

local function dpms_enable(c)
    if c.fullscreen then
        remove_client(fullscreened_clients, c)
    end
end

-- }}}

-- {{{ Disable notifications when fullscreen
-- https://github.com/awesomeWM/awesome/issues/2047#issuecomment-333201981
function naughty.config.notify_callback(args)
    local c = client.focus
    if c then
        if c.fullscreen and args.timeout ~= 0 then
            naughty.suspend()
            return
        else
            naughty.resume()
            return args
        end
    end
end

-- }}}

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

client.connect_signal("unmanage", dpms_enable)
client.connect_signal("property::fullscreen", dpms_disable)

-- }}}
