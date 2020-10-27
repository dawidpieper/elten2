# ELTEN 2 client for Desktop.
Elten is a social Networking for the blind.

[Elten Website](https://elten-net.eu)

This repository contains code of Desktop Elten Client.

The server implementation can be found [here](https://github.com/dawidpieper/elten2-server).

## Our goal
The aim of the Elten project is to create a network place that will allow blind people and all those interested in this environment to meet. This client defines the interfaces to create an environment for the development of social functions and external programs accessible for blind.

In the future, it is planned to break down Elten into a social layer and a set of controls, but nowadays these functionalities are closely linked.
### Note for those wishing to develop software for the blind
It should be clearly stated here that the accessible software does not need to prepare its own user interface. The vast majority of existing GUI solutions are available using a suitable screen reader, for example open-source [NVDA](https://github.com/nvaccess/nvda).

*The only* purpose of using this application's own interface is to make the interface available to a degree that is not possible with a classic user interface, and to create an API for developing applications for blind people, especially games.

Without a clear and specific goal, I appeal and urge you to develop your own projects for blind people based on standard solutions such as libraries [WinForms](https://github.com/dotnet/winforms), [QT](https://github.com/qt/qt5) or [wxWidgets](https://github.com/wxWidgets/wxWidgets), all of those being accessible.

# Program structure
Elten is currently split into two separate processes, one functioning as a daemon and one presenting GUI. This is forced by the engine used, RGSS.

One of the goals of Release 3.0 is to develop a new engine that will completely replace the RGSS and combine these two tasks in one process. Until then, however, these codes will be separate.

# Building
It is probably possible to run Elten using one of the open source implementations of the RGSS engine. However, this solution has never been tested by me.

If someone manages to prepare one of these engines to work with Elten, I would be very grateful for contact, perhaps it will remove the proprietary solution required to start the project.

Currently, the recommended procedure for building your code is to generate script files and replace them with the scripts loaded by RGSS Player. For an existing Elten installation, this means replacing the Data/elten.edb file whose build script is in this repository.

# Issues
All issues, bug reports and suggestions should be placed on Elten forum.

# A call for pull requests
For all pull requests I will be very obliged.

# License
GNU General Public License V3 

__Copyright (C) Dawid Pieper__

_All rights reserved_