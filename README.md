VaLauncher
==========

Simple application launcher written in Vala
-------------------------------------------

Supports some kind of dmenu-like autocompletion and also command history.

![valauncher's screenshot](http://i.imgur.com/SQdQQ.png "Screenshot")

Use `Tab` to move forward through the completion list and `Shift+Tab` to move backward.

### Dependecies:

* GTK+3
* Vala
* CMake

### Building:

	mkdir build
	cd build
	cmake ..
	make
	make install       # if you wish, or just ./src/valauncher
