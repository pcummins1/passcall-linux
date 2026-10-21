# PassCall for Linux

Turn a Linux laptop, tablet or small PC into a PassCall window: https://passcall.io/

PassCall runs in the browser, so this is not another app to trust. It is a launcher that opens https://my.passcall.io/ in a window of its own, with its own browser profile, and keeps the machine awake while the window is open. Nothing here needs root.

## Install

```
git clone https://github.com/pcummins1/passcall-linux.git
cd passcall-linux
./install.sh            # app mode: PassCall in your application menu
./install.sh --kiosk    # kiosk mode: full screen at every login, for a dedicated screen
./install.sh --remove   # take it out again
```

Needs Chromium, Google Chrome, Brave or Firefox (Chromium-based browsers are preferred: the camera and video stack is better). Works on Debian, Ubuntu, Raspberry Pi OS, Fedora and friends, on X11 or Wayland.

## What it does

- **App mode** adds "PassCall" to your menu. It opens as its own window with the PassCall icon, next to whatever else you use the laptop for.
- **Kiosk mode** starts the window full screen when you log in and restarts it if the browser ever exits (systemd user service, with an autostart entry as the fallback). Made for an old laptop or tablet that lives on a shelf.
- While the window runs, the screen does not blank and the machine does not sleep, including when a laptop lid is closed (logind inhibit; `xset` on X11; GNOME's session inhibit where present).
- The first run asks once for the camera and microphone. The browser profile at `~/.config/passcall-window` remembers your sign-in and that choice; your everyday browser is untouched.

## Tips

- Lid closed on a laptop: the webcam is in the lid, so a laptop on a shelf wants the lid open. Use an external webcam if it must stay closed.
- Auto-login: for a dedicated device, set your desktop to log in automatically so a power cut brings the window back on its own.
- Raspberry Pi: this works on Pi OS with Chromium; the `passcall-pi` kit adds Home Assistant and a full kiosk image.

## Privacy

Everything about what PassCall does with the camera is at https://passcall.io/privacy/. In short: the camera is checked about once a second, on the device, to notice that someone is there; a window opens only between people who have added each other; nothing is recorded.
