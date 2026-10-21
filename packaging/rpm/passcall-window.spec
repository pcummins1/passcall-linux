# Fedora / openSUSE package. Build with rpmbuild, Fedora COPR or the openSUSE Build
# Service from the release tarball:
#   https://github.com/pcummins1/passcall-linux/archive/refs/tags/v%{version}.tar.gz
Name:           passcall-window
Version:        1.0.0
Release:        1%{?dist}
Summary:        PassCall window launcher: a window between homes
License:        MIT
URL:            https://passcall.io/linux/
Source0:        https://github.com/pcummins1/passcall-linux/archive/refs/tags/v%{version}.tar.gz#/passcall-linux-%{version}.tar.gz
BuildArch:      noarch
BuildRequires:  systemd-rpm-macros
Recommends:     (chromium or google-chrome-stable or brave-browser or firefox)

%description
PassCall turns a display with a camera into a window between two homes: when you
and a friend both walk past your screens at the same time, the window opens and
you see each other. No calls to make, no feed, no ads, no recording.

This package opens the PassCall web app in a browser window of its own, keeps
the machine awake while the window is open, and offers a kiosk mode that starts
full screen at login (systemctl --user enable --now passcall-window.service).

%prep
%autosetup -n passcall-linux-%{version}

%build
# nothing to compile

%install
install -Dm755 bin/passcall-window %{buildroot}%{_bindir}/passcall-window
install -Dm644 share/io.passcall.Window.desktop %{buildroot}%{_datadir}/applications/io.passcall.Window.desktop
install -Dm644 share/io.passcall.Window.png %{buildroot}%{_datadir}/icons/hicolor/512x512/apps/io.passcall.Window.png
install -Dm644 share/io.passcall.Window.metainfo.xml %{buildroot}%{_metainfodir}/io.passcall.Window.metainfo.xml
sed 's#%h/.local/bin/passcall-window#%{_bindir}/passcall-window#' share/passcall-window.service > passcall-window.service
install -Dm644 passcall-window.service %{buildroot}%{_userunitdir}/passcall-window.service

%files
%license LICENSE
%doc README.md
%{_bindir}/passcall-window
%{_datadir}/applications/io.passcall.Window.desktop
%{_datadir}/icons/hicolor/512x512/apps/io.passcall.Window.png
%{_metainfodir}/io.passcall.Window.metainfo.xml
%{_userunitdir}/passcall-window.service

%changelog
* Tue Oct 21 2026 PassCall LLC <help@passcall.io> - 1.0.0-1
- First packaged release
