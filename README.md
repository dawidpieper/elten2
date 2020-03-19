# ELTEN 2 client and server code for Desktop.
Elten is a social Networking for the blind.
[Elten Website](https://elten-net.eu)
This repository contains code of Desktop Elten Client and its Server API Implementation.

# Code structure
## Client
### src
Elten Core (basic application) is based on RGSS Engine. Elten3 is going to use its own engine (conspect in client/core/engine).
Although Elten uses official RGSS implementation from Enterbrain, it is possible to run Elten using one of open implementations, for instance [one created by bluepixelmike](https://github.com/bluepixelmike/rpg-maker-rgss).
For testing purposes, it is recommended to override scripts file (Data/elten.edb) of existing installation with the newly generated. Build scripts are included in client/core directory and can be modified as needed.
### agent
Elten agent written in Ruby, responsible for background operations, including server requests and notifications processing. Agent communicates with Elten using stdin/stdout pipes.
Ruby 2.6 x86 is required to run it.
### screenreaders/nvda
The NVDA ScreenReader Addon enabling Elten to use braille monitors and speech indexing, as these functions are not included in NVDAControllerClient.
This addon is written in Python.
## Server
Server code, in php.

# Issues
All issues, bug reports and suggestions should be placed on Elten forum.

# A call for pull requests
For all pull requests I will be very obliged.

__Copyright (C) Dawid Pieper__
_All rights reserved_