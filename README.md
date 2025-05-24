<img src="package/contents/icons/io.github.vmkspv.darkstore.svg" width="120" align="left"/>

# Darkstore

_Darkstore_ is a KDE Plasma applet to prevent OLED burn-in during downloads.

<br>
<img src="preview.gif" width="742" title="Popup widget">

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
