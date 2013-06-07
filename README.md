VaLauncher
==========

Simple application launcher written in Vala
-------------------------------------------

Supports some kind of dmenu-like autocompletion and also command history.

![valauncher's screenshot](http://i.imgur.com/WQk0rAu.png "Screenshot")

Use `Tab` to move forward through the completion list and `Shift+Tab` to move backward.

### Getting the latest release

* Archlinux:

	yaourt -S [valauncher-git](https://aur.archlinux.org/packages/valauncher-git/)

Help us to add valauncher to more linux distributions!

### Dependencies:

* GTK+3
* Vala
* Libgee 0.10.x (for earlier versions simply revert 4ef8528abd6d5d9c971120b67abc9f37eef413cd)
* CMake

### Building:

#### For Maintainer

	cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr .
	make
	make install

#### For Developers

	cmake .
	make
	./src/valauncher

### Contributors

* [Anton Lobashev](https://github.com/soulthreads) - original author
* [Jörg Thalheim](https://github.com/Mic92)
