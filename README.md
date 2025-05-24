<img src="package/contents/icons/io.github.vmkspv.darkstore.svg" width="120" align="left"/>

# Darkstore

_Darkstore_ is a KDE Plasma applet to prevent OLED burn-in during downloads.

<br>
<img src="preview.gif" width="742" title="Popup widget">

## Installation

<a href="https://store.kde.org/p/2290747">
  <img src="https://kde.org/stuff/clipart/logo/kde-logo-grey-w-slug-vectorized.svg" width="64" align="left"/>
</a>

The recommended installation method is via the [KDE Store](https://store.kde.org/p/2290747).  
Plasmoid can be easily added from Plasma Widget Explorer or Discover (KDE Software Center).

The package for manual installation is available in the [releases](https://github.com/vmkspv/darkstore/releases) section.

## Building from source

The recommended method is to use KPackage Manager:

1. Install the package that provides the `kpackagetool6` command in your distribution.
2. Clone `https://github.com/vmkspv/darkstore.git` repository and `cd darkstore`.
3. Run `kpackagetool6 -t Plasma/Applet --install package` command.

After installation, the applet should appear in the standard panel as part of the System Tray widget.

To update an existing installation, use `--upgrade` instead of `--install`.

## Contributing

Contributions are welcome!

If you have an idea, bug report or something else, don’t hesitate to [open an issue](https://github.com/vmkspv/darkstore/issues).

> This project follows the [KDE Community Code of Conduct](https://kde.org/code-of-conduct).

## License

Darkstore is released under the [GPL-3.0 license](COPYING).
