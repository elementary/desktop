/*
* Copyright 2019 elementary, Inc. (https://elementary.io)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 3 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
*/

public class Desktop.MainWindow : Gtk.ApplicationWindow {
    private const string CSS = """
        window {
            background: transparent;
        }
    """;

    public MainWindow (Gtk.Application application) {
        Object (
            // accept_focus: false,
            application: application,
            icon_name: "preferences-desktop-wallpaper",
            resizable: false,
            skip_taskbar_hint: true,
            title: _("Desktop"),
            type_hint: Gdk.WindowTypeHint.DESKTOP
        );
    }

    construct {
        hide_titlebar_when_maximized = true;
        maximize ();

        var wallpaper_item = new Gtk.MenuItem.with_label (_("Change Wallpaper…"));
        var displays_item = new Gtk.MenuItem.with_label (_("Display Settings…"));
        var separator = new Gtk.SeparatorMenuItem ();
        var settings_item = new Gtk.MenuItem.with_label (_("System Settings…"));

        var menu = new Gtk.Menu ();
        menu.attach_to_widget (this, null);
        menu.append (wallpaper_item);
        menu.append (displays_item);
        menu.append (separator);
        menu.append (settings_item);
        menu.show_all ();

        var provider = new Gtk.CssProvider ();
        try {
            provider.load_from_data (CSS, CSS.length);

            Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
        } catch (GLib.Error e) {
            return;
        }

        button_press_event.connect ((event) => {
            if (event.type == Gdk.EventType.BUTTON_PRESS && event.button == Gdk.BUTTON_SECONDARY) {
                menu.popup_at_pointer (event);
            }

            return false;
        });

        wallpaper_item.activate.connect (() => {
            try {
                // FIXME: Update to settings://desktop/appearance/wallpaper once
                // this is released: https://github.com/elementary/switchboard-plug-pantheon-shell
                AppInfo.launch_default_for_uri ("settings://desktop/wallpaper", null);
            } catch (Error e) {
                critical ("Failed to open wallpaper settings: %s", e.message);
            }
        });

        displays_item.activate.connect (() => {
            try {
                AppInfo.launch_default_for_uri ("settings://display", null);
            } catch (Error e) {
                critical ("Failed to open display settings: %s", e.message);
            }
        });

        settings_item.activate.connect (() => {
            try {
                AppInfo.launch_default_for_uri ("settings://", null);
            } catch (Error e) {
                critical ("Failed to open system settings: %s", e.message);
            }
        });
    }
}

