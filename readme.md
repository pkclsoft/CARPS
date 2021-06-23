# CARPS - Computer Aided Role Playing System

This is a legacy project I started back in 1989 with a friend (who sadly, I've lost contact with).
The plan at the time was to write an RPG (ala the Ultima series) that was extensible, had multiple worlds, used procedural generation to generate those worlds from a seed, and supported (using a very object oriented methodology) the embellishment of those worlds with civilisations, etc.
Needless to say, we didn't get very far with it.
We had grand plans.  This repository is my way of preserving what we did write, which wasn't much.
All I've found thus far, is the beginnings of a basic sprite editor.  I had lost some of the code, and had to recreate it by disassembling a working binary using Apple's DumpObj tool
The repo comes with the code for a basic sprite mechanism, and a desktop application for creating and editing those sprites.  The application isn't quite feature complete.  I've had to tweak some of the code (on an GSPlus emulator) because the ORCA/Pascal compiler I have seems to do some strange things.
So it's probably not a lot of use, but it's a start of preserving some of my old code.
## Line Endings
The text and source files in this repository originally used CR line endings, as usual for Apple II text files, but they have been converted to use LF line endings because that is the format expected by Git. If you wish to move them to a real or emulated Apple II and build them there, you will need to convert them back to CR line endings.

If you wish, you can configure Git to perform line ending conversions as files are checked in and out of the Git repository. With this configuration, the files in your local working copy will contain CR line endings suitable for use on an Apple II. To set this up, perform the following steps in your local copy of the Git repository (these should be done when your working copy has no uncommitted changes):

1. Add the following lines at the end of the `.git/config` file:
```
[filter "crtext"]
	clean = LC_CTYPE=C tr \\\\r \\\\n
	smudge = LC_CTYPE=C tr \\\\n \\\\r
```

2. Add the following line to the `.git/info/attributes` file, creating it if necessary:
```
* filter=crtext
```

3. Run the following commands to convert the existing files in your working copy:
```
rm .git/index
git checkout HEAD -- .
```

Alternatively, you can keep the LF line endings in your working copy of the Git repository, but convert them when you copy the files to an Apple II. There are various tools to do this.  One option is `udl`, which is [available][udl] both as a IIGS shell utility and as C code that can be built and used on modern systems.

Another option, if you are using the [GSPlus emulator](https://apple2.gs/plus/) is to host your local repository in a directory that is visible on both your host computer, and the emulator via the excellent [Host FST](https://github.com/ksherlock/host-fst).

[udl]: http://ftp.gno.org/pub/apple2/gs.specific/gno/file.convert/udl.114.shk

## File Types
In addition to converting the line endings, you will also have to set the files to the appropriate file types before building on a IIGS.

So, once you have the files from the repository on your IIGS (or emulator), within the ORCA/M shell, execute the following command on each `build` scripts:

    filetype lib/build src 6
    filetype spred/build src 6

## Building
To build the sprite editor, make sure you have both folders (LIB and SPRED) present in the same folder on your GS.
You will need the ORCA/M environment present.
 * First, build the carplib by executing the build script within lib.  This places a copy of carplib and the pascal interface file inside SPRED.
	 * cd LIB
	 * build
 * Next, build the Sprite editor application.  You may need to change the file types
	 * cd ../SPRED
	 * build
## Executing
Just run the generated "spred" file.  I've provided a couple of old sprites I had that can be loaded.
 
![Sprite Editor Screenshot](https://github.com/pkclsoft/CARPS/blob/594af1d8fd86ec7fa52a69fabbd17dabbc1c55b4/spred.png)
