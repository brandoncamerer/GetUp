# GetUp App

A simple macOS menu bar application that reminds you to get up.

## Features
- **Menu Bar Timer:** Shows the time remaining until the next alert right in the menu bar.
- **Status Popover:** Click the icon to see a visual progress bar and controls.
- **Reminders:** "GET UP!" notification.
- **Snooze:** Snooze for a configurable time.
- **Settings:** 
    - Change intervals (Default: 30 mins reminder, 15 mins snooze).
    - **Start at Login:** Toggle to automatically start the app when you log in.

## How to Run
1. Open the `GetUp.app` file in this folder.
2. Allow Notifications when prompted.
3. You will see the timer counting down in your menu bar.

## How to Quit
1. Click the menu bar icon.
2. Click "Quit".

## Building from Source
1. Edit files in `Sources/GetUp/`.
2. Run `./Scripts/bundle_app.sh` to rebuild.
