<img src="package/contents/icons/io.github.vmkspv.darkstore.svg" width="120" align="left"/>

# Darkstore

_Darkstore_ is a KDE Plasma applet to prevent OLED burn-in during downloads.

<p align="center">
  <a href="https://github.com/vmkspv/darkstore/actions/workflows/plasmoid.yml">
    <img src="https://img.shields.io/github/actions/workflow/status/vmkspv/darkstore/plasmoid.yml?logo=kdeplasma&logoColor=fff&labelColor=3a3e42&color=c7422b"/>
  </a>
  <a href="https://github.com/vmkspv/darkstore/releases/latest">
    <img src="https://img.shields.io/github/v/release/vmkspv/darkstore?logo=github&logoColor=fff&labelColor=3a3e42&color=c7422b"/>
  </a>
  <a href="https://github.com/vmkspv/darkstore/releases">
    <img src="https://img.shields.io/github/downloads/vmkspv/darkstore/total?logo=git&logoColor=fff&labelColor=3a3e42&color=c7422b"/>
  </a>
</p>

<br>
<img src="preview.gif" width="742" title="Popup widget">

## Building from source

The recommended method is to use KPackage Manager:

1. Install the package that provides the `kpackagetool6` command in your distribution.
2. Clone `https://github.com/vmkspv/darkstore.git` repository and `cd darkstore`.
3. Run `kpackagetool6 -t Plasma/Applet --install package` command.

After installation, the applet should appear in the standard panel as part of the System Tray widget.

## Contributing

**This project is archived and no longer accepting contributions**.

If you'd like to continue development, feel free to fork this repository.

> This project follows the [KDE Community Code of Conduct](https://kde.org/code-of-conduct).

## License

Darkstore is released under the [GPL-3.0 license](COPYING).
