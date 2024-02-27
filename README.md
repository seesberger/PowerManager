
![Logo](https://zersafter-inc.de/banner.png)


# Powerman - A powerful toolset for OpenComputers

This is a project combining a super cool git-download-tool for use on the in-game computer running OpenOS and an application with a rudimentary windowed GUI.

You can expect more features in future releases.


## Installation:
For the initial install you have to have an internet card in your computer. Also for the GUI you need at least a tier 2 GPU and screen.

Run the following command in the OpenOS shell:
`pastebin run <Placeholder> <argument>`

The git-tool will then walk you through manual installation of dependencies, the tool itself and the application module(s).

## Git tool:
<To be filled out>

### Usage

### Installation path

### Uninstalling via manifest

### Setting up Preferences

## GUI API
The GUI API installs to /lib by default. It is a fork of Kevink525's OC-GUI-API tailored to our needs and expanded by a Windowing system.
It is an object oriented Interface system to let the user decide what the application does by just pushing a few buttons or inputing a string. There are simple objects like rectangles or containerized-objects like Windows or ProgressBars.

The GUI is typically contained in (creatable, moveable and deletable) Windows, but there is also the ability to hard-code objects to certain screens or whatever.
For example: Display Windowed application on screen one and have a status display on screen 2

## Shortcut
Of course this project will be installed with a shell shortcut. To run the application with GUI just type `powerman`.
If you want to know what arguments can be used put an `-h` behind it.
For example:
`powerman -h` displays the help text for the application it starts.
`powerman update -h` displays the help text for the git-tool. (May change in the future)
The shortcut is installed in /usr/bin. If this folder does not exist yet it will be created.

## Application
This is where the fun begins. On startup you will be greeted with a desktop.
These features are yet to be implemented, but you can expect things like Powermanagement (Hey, the original idea behind this Project), AE2 interfaces (including Autocrafting and stuff), redstone control, chat application for communicating with friends on a server and many more! Just wait till we are done (which will be never because there are many ideas)
