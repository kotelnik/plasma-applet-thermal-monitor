# Thermal Monitor

Plasma 5 applet for monitoring CPU, GPU and other available temperature sensors.

### INSTALLATION

```sh
$ git clone --depth=1 https://github.com/kotelnik/plasma-applet-thermal-monitor
$ cd plasma-applet-thermal-monitor/
$ cmake -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -DLIB_INSTALL_DIR=lib -DKDE_INSTALL_USE_QT_SYS_PATHS=ON
$ sudo make install
```

### UNINSTALATION

```sh
$ sudo rm -r /usr/share/plasma/plasmoids/org.kde.thermalMonitor
$ sudo rm /usr/share/kservices5/plasma-applet-org.kde.thermalMonitor.desktop
```
