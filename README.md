# Thermal Monitor

Plasma 5 applet for monitoring CPU, GPU and other available temperature sensors.

### INSTALLATION

```sh
$ git clone --depth=1 https://github.com/kotelnik/plasma-applet-thermal-monitor
$ cd plasma-applet-thermal-monitor/
$ mkdir build
$ cd build
$ cmake .. -DCMAKE_INSTALL_PREFIX=/usr
$ sudo make install
```

### UNINSTALATION

```sh
$ cd plasma-applet-thermal-monitor/build/
$ sudo make uninstall
```
or
```sh
$ sudo rm -r /usr/share/plasma/plasmoids/org.kde.thermalMonitor
$ sudo rm /usr/share/kservices5/plasma-applet-org.kde.thermalMonitor.desktop
```
