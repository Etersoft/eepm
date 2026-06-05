#!/usr/bin/env python3
#
# Copyright (C) 2026  Etersoft
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#

import os
import shutil
import subprocess
import sys
import tempfile

try:
    from PySide6.QtCore import QDateTime, QProcess, QTimer
    from PySide6.QtGui import QAction, QIcon
    from PySide6.QtWidgets import QApplication, QMenu, QSystemTrayIcon
except ImportError:
    try:
        from PyQt6.QtCore import QDateTime, QProcess, QTimer
        from PyQt6.QtGui import QAction, QIcon
        from PyQt6.QtWidgets import QApplication, QMenu, QSystemTrayIcon
    except ImportError:
        print("Error: PySide6 or PyQt6 is required to run the tray applet.", file=sys.stderr)
        sys.exit(1)


CHECK_INTERVAL_MS = 60 * 60 * 1000
AUTOSTART_FILE = os.path.expanduser("~/.config/autostart/epm-play-update-tray.desktop")
UPDATE_ICON = "software-update-available"


def icon_from_theme(*names):
    fallback = QIcon()
    for name in reversed(names):
        fallback = QIcon.fromTheme(name, fallback)
    return fallback


def message_icon():
    return QSystemTrayIcon.MessageIcon.Information


class EpmUpdateTray(QSystemTrayIcon):
    def __init__(self, app):
        super().__init__()
        self.app = app
        self.epm_path = os.environ.get("EPM_BIN", "epm")
        self.process = None
        self.last_check = None
        self.next_check = None
        self.play_updates = []
        self.was_empty = True

        self.setup_menu()
        self.set_clean_state()

        self.timer = QTimer()
        self.timer.timeout.connect(self.check_updates_auto)
        self.timer.start(CHECK_INTERVAL_MS)

        self.check_updates(manual=False)

    def setup_menu(self):
        self.menu = QMenu()

        self.status_action = QAction("Checking updates...", self)
        self.status_action.setEnabled(False)
        self.menu.addAction(self.status_action)

        self.play_menu = QMenu("EPM Play (0)")
        self.menu.addMenu(self.play_menu)
        self.menu.addSeparator()

        self.last_check_action = QAction("Last check: never", self)
        self.last_check_action.setEnabled(False)
        self.menu.addAction(self.last_check_action)

        self.next_check_action = QAction("Next check: unknown", self)
        self.next_check_action.setEnabled(False)
        self.menu.addAction(self.next_check_action)
        self.menu.addSeparator()

        self.update_action = QAction("Run EPM Play Update", self)
        self.update_action.triggered.connect(self.apply_updates)
        self.menu.addAction(self.update_action)

        self.check_action = QAction("Check for updates", self)
        self.check_action.triggered.connect(self.check_updates_manual)
        self.menu.addAction(self.check_action)

        self.autostart_action = QAction("", self)
        self.autostart_action.triggered.connect(self.toggle_autostart)
        self.menu.addAction(self.autostart_action)
        self.update_autostart_text()

        self.quit_action = QAction("Exit", self)
        self.quit_action.triggered.connect(self.app.quit)
        self.menu.addAction(self.quit_action)

        self.setContextMenu(self.menu)
        self.activated.connect(self.on_activated)

    def is_autostart_configured(self):
        return os.path.exists(AUTOSTART_FILE)

    def update_autostart_text(self):
        if self.is_autostart_configured():
            self.autostart_action.setText("Remove from autostart")
        else:
            self.autostart_action.setText("Add to autostart")

    def toggle_autostart(self):
        if self.is_autostart_configured():
            try:
                os.remove(AUTOSTART_FILE)
            except OSError as err:
                print(f"Error removing autostart: {err}", file=sys.stderr)
        else:
            try:
                os.makedirs(os.path.dirname(AUTOSTART_FILE), exist_ok=True)
                with open(AUTOSTART_FILE, "w", encoding="utf-8") as desktop:
                    desktop.write("""[Desktop Entry]
Type=Application
Name=EPM Update Tray
Comment=System tray applet for epm play updates
Exec=epm play-update-tray
Icon=system-software-update
Terminal=false
Categories=System;Monitor;
""")
            except OSError as err:
                print(f"Error configuring autostart: {err}", file=sys.stderr)
        self.update_autostart_text()

    def set_clean_state(self):
        self.setIcon(icon_from_theme(
            "system-software-update-installed",
            "update-none",
            "preferences-system-software-updates",
        ))
        self.setToolTip("EPM updates: system is up to date")

    def set_update_state(self, count):
        self.setIcon(icon_from_theme(
            UPDATE_ICON,
            "system-software-update",
            "preferences-system-software-updates",
        ))
        self.setToolTip(f"EPM updates: {count} updates available")

    def check_updates_auto(self):
        self.check_updates(manual=False)

    def check_updates_manual(self):
        self.check_updates(manual=True)

    def check_updates(self, manual=False):
        if self.process and self.process.state() != QProcess.ProcessState.NotRunning:
            return
        self.manual_check = manual
        self.status_action.setText("Checking updates...")
        self.check_action.setEnabled(False)
        self.update_action.setEnabled(False)
        self.process = QProcess()
        self.process.finished.connect(self.on_check_finished)
        self.process.start(self.epm_path, ["play", "--list-updates", "--quiet"])

    def on_check_finished(self, exit_code, *args):
        output = bytes(self.process.readAllStandardOutput()).decode(errors="replace")
        stderr = bytes(self.process.readAllStandardError()).decode(errors="replace").strip()
        self.play_updates = self.parse_updates(output)

        self.last_check = QDateTime.currentDateTime()
        self.next_check = self.last_check.addMSecs(CHECK_INTERVAL_MS)
        self.check_action.setEnabled(True)

        count = self.update_count()
        if exit_code != 0 and count == 0:
            self.status_action.setText("Update check failed")
            self.update_action.setEnabled(False)
            self.setIcon(icon_from_theme("dialog-warning", "software-update-urgent"))
            self.setToolTip("EPM updates: check failed")
            if self.manual_check:
                self.notify("EPM Updates", stderr or "Update check failed")
            self.update_menu()
            return

        if count:
            self.status_action.setText(f"{count} updates available")
            self.update_action.setEnabled(True)
            self.set_update_state(count)
            if self.manual_check or self.was_empty:
                self.notify("EPM Updates", self.summary_text())
            self.was_empty = False
        else:
            self.status_action.setText("System is up to date")
            self.update_action.setEnabled(False)
            self.set_clean_state()
            if self.manual_check:
                self.notify("EPM Updates", "System is up to date")
            self.was_empty = True

        self.update_menu()

    def parse_updates(self, output):
        play = []

        for raw_line in output.splitlines():
            line = raw_line.strip()
            if not line:
                continue
            parts = line.split()
            if len(parts) >= 3 and self.is_app_name(parts[0]):
                play.append(f"{parts[0]}: {parts[1]} -> {parts[2]}")

        return play

    def update_count(self):
        return len(self.play_updates)

    def update_menu(self):
        self.play_menu.setTitle(f"EPM Play ({len(self.play_updates)})")

        self.fill_menu(self.play_menu, self.play_updates)

        if self.last_check:
            self.last_check_action.setText(
                "Last check: " + self.last_check.toString("dd MMM HH:mm:ss")
            )
        if self.next_check:
            seconds = max(0, QDateTime.currentDateTime().secsTo(self.next_check))
            self.next_check_action.setText("Next check in " + self.format_interval(seconds))

    def fill_menu(self, menu, rows):
        menu.clear()
        if not rows:
            empty_action = QAction("No updates", self)
            empty_action.setEnabled(False)
            menu.addAction(empty_action)
            return

        for row in rows[:30]:
            action = QAction(row, self)
            app_name = self.app_name_from_row(row)
            action.triggered.connect(lambda checked=False, app_name=app_name: self.apply_updates(app_name))
            menu.addAction(action)

        hidden_count = len(rows) - 30
        if hidden_count > 0:
            more_action = QAction(f"... and {hidden_count} more", self)
            more_action.setEnabled(False)
            menu.addAction(more_action)

    def format_interval(self, seconds):
        minutes = seconds // 60
        if minutes >= 60:
            hours = minutes // 60
            minutes = minutes % 60
            return f"{hours}h {minutes}m"
        return f"{minutes}m {seconds % 60}s"

    def summary_text(self):
        parts = []
        if self.play_updates:
            parts.append(f"EPM Play: {len(self.play_updates)}")
        rows = self.play_updates
        return ", ".join(parts) + "\n" + "\n".join(rows[:6])

    def app_name_from_row(self, row):
        return row.split(":", 1)[0].strip()

    def is_app_name(self, name):
        allowed_chars = set("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_.+@-")
        return bool(name) and all(char in allowed_chars for char in name)

    def notify(self, title, text):
        if shutil.which("notify-send"):
            try:
                subprocess.Popen(["notify-send", f"--icon={UPDATE_ICON}", title, text])
                return
            except OSError:
                pass
        self.showMessage(title, text, message_icon(), 10000)

    def on_activated(self, reason):
        if reason in (
            QSystemTrayIcon.ActivationReason.Trigger,
            QSystemTrayIcon.ActivationReason.DoubleClick,
        ):
            self.notify("EPM Updates", self.summary_text() if self.update_count() else "System is up to date")

    def apply_updates(self, app_name=None):
        if not shutil.which("gio"):
            print("Could not find gio to launch EPM Play Update.", file=sys.stderr)
            return

        update_args = "--update all"
        update_name = "EPM Play Update"
        if app_name:
            update_args = f"--update {app_name}"
            update_name = f"EPM Play Update: {app_name}"

        desktop_file = None
        try:
            fd, desktop_file = tempfile.mkstemp(prefix="epm-play-update-", suffix=".desktop")
            with os.fdopen(fd, "w", encoding="utf-8") as desktop:
                desktop.write(f"""[Desktop Entry]
Type=Application
Name={update_name}
Comment=Update applications installed via epm play
Exec={self.epm_path} play {update_args}
Icon=system-software-update
Terminal=true
Categories=System;
""")
            os.chmod(desktop_file, 0o755)
            subprocess.run(["gio", "launch", desktop_file], check=False)
        except OSError as err:
            print(f"Could not launch EPM Play Update: {err}", file=sys.stderr)
        finally:
            if desktop_file:
                try:
                    os.unlink(desktop_file)
                except OSError:
                    pass


def main():
    app = QApplication(sys.argv)
    app.setQuitOnLastWindowClosed(False)

    if not QSystemTrayIcon.isSystemTrayAvailable():
        print("System tray is not available on this system.", file=sys.stderr)
        sys.exit(1)

    tray = EpmUpdateTray(app)
    tray.show()

    if hasattr(app, "exec"):
        sys.exit(app.exec())
    sys.exit(app.exec_())


if __name__ == "__main__":
    main()
