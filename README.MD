# cNotes

Simple bash script to compile markdown notes from a folder hierarchy into pdfs, utilizing pandoc and ghostscript. 

## Getting Started

Pandoc requires LaTeX for pdf output, so if you do not yet have LaTeX installed, get one of the many free distributions such as MiKTeX or TeX Live. Next install pandoc, which is a commandline tool to convert files between various formats. Install ghostscript which is used to merge pdfs. Finally, execute the script inside a bash shell.

### Prerequisites

1) LaTeX 
2) Pandoc 
3) Ghostscript 
4) A bash shell

### Installation

Install a Tex/LaTeX distribution such as <https://miktex.org/download> and follow the installation instructions. Install Pandoc from <https://pandoc.org/installing.html> while following the installation instructions. Finally install ghostscript from <https://www.ghostscript.com/download/gsdnld.html> (In case of MAC instead have a look at <http://pages.uoregon.edu/koch/>). Make sure that both pandoc and ghostscript are part of your PATH environment variable. This can be achieved by doing the following:

+ on windows
```
setx PATH=%PATH%;Your/Path/To/The/Application/Directory/
```
+ on mac
open up the /etc/paths file with your favourite text editor (in this case Vi) and add the necessary folder at the end
```
sudo vi /etc/paths
```
+ on linux
open up the /etc/environment file with your favourite text editor and add the necessary folder ata the end
```
sudo vi /etc/environment
```
Now place the script inside a directory that is part of your PATH variable, or add another directory following the previous instructions. Make the script executable by executing the following command:
```
chmod +x Your/Path/To/notes.sh
```

Both macOS and linux will have native bash shell environments. Windows 10 now also supports native bash shells through the Windows Subsystem for Linux (WSL). On earlier windows systems there are various options to get a Bash environment, I think one of the easiest ways is to install Git for Windows (<https://git-scm.com/download/win>).

### Running the script

#### Commands

Now you should be able to run the script by typing the following command in a bash shell (for example Git Bash):

```
notes man
```
This will print the help page.
```
notes [-i DIRECTORY] [-r] [-x] all
```
Compiles all notes from the $NOTES_DIR directory.
```
notes [-i DIRECTORY] [-r] [-x] (SUB)DIRECTORY [[,...n] | [...n] [int [[,...n] | [-int]]]]
```
Compiles all notes from the (SUB)DIRECTORY contained in $NOTES_DIR. Multiple directories can be included by separating them with a comma, or the compilation can be excluded to an other subdirectory level by providing additional subdirectories in a space separated list. An optional integer, integer list, or integer range can also be supplied in this latter case to limit the compilation to those folders ending in an integer that's included in the supplied collection.

#### Syntax:

	-i DIRECTORY
		Sets the $NOTES_DIR environment variable.
	-r
		Root only, only generate master pdf.
	-x
		Ignore any instructions inside all Customize folders in the hierarchy.
	[]
		Optional argument.
	[,...n]
		Optional comma separated values.
	[...]
		Optional space separated values.
	|
		OR, used to specify mutually exclusive items.

#### Environment and Examples

This script operates on a folder hierarchy with a single root folder in which you organize all your notes taken during for example class or work. I have a single "Notes" directory in which I have 3 subfolders called "Work", "Study" and "Personal". I further subdivided these folders to my liking.

```
Notes
├─Customize
├─Personal
│  ├─Diary
│  │  └─2018
│  │      └─July
│  └─Projects
│      ├─BWSort
│      └─cNotes
├─Study
│  ├─Biomedical Science
│  ├─Computer Science
│  │  ├─Areas
│  │  │  ├─Algorithms
│  │  │  ├─Cryptography
│  │  │  ├─Data Structures
│  │  │  ├─Design patterns
│  │  │  └─Networking
│  │  ├─Technologies
│  │  └─Tools
│  └─Mathematics
└─Work
    └─Projects
        ├─Project1
        ├─Project2
        ├─Project3
        ├─Project4
        ├─Project5
        └─Project6
```

If we want to compile all notes in our Notes folder, we can execute the following command:
```
notes all
```
This will generate a master pf inside the Notes folder.

If we instead only want to compile the notes from our personal projects, we can execute the following command:
```
notes Personal Projects
```
This would give us Projects.pdf inside the Personal folder. (Bug: currently it also generates a master pdf inside the notes folder)

If we have a folder like Work/Projects that contains a ton of folders ending in an integer, we can easily compile them by specifying a comma separated list or a range like so:
```
notes Work Projects 1,2,3,4
```
or
```
notes Work Projects 1-4
```
This will then generate a Projects.pdf file inside the Work folder.

You can now add a Customize folder at any level of the hierarchy. This folder can contain a header.tex file with additional commands to be added to the latex preamble. For now I have only tested changing the font. Most likely support for templates will have to be added for it to work properly. You can now change the font to for example merriweather by including the following lines in the header.tex file:
```
\usepackage[sfdefault]{merriweather}
\fontfamily{merriweather}
```
The instructions in the Customize folder closest to the to-be-compiled directory will be used, this means that it will also search the parent directory all the way to the root $NOTES_DIR. If no Customize folder is found, default values will be used.

## Known Bugs

+ ~~Currently an extra master pdf will be generated in case you do not supply an integer list with a specific path.~~ (Not a bug, you can provide -r flag to prevent the creation of the master pdf)
+ Paths are formed with both '\\' and '/' which looks ugly but somehow seems to work.
+ ~~Currently only works on windows since the gs64winc command is a windows specific command~~ (Should work now!)

In case you find any bugs, feel free to let me know.

## Towards the future

+ Support for suffixes of the folders currently ending in integers. This will be useful in case you want your folders to have names like "Project 1 - ProjectTitle" instead of just "Project1".
+ Support for piping of output from commands such as grep to notes, so you can more easily determine which notes you want to compile to a pdf format.
+ Support for other output formats such as .docx, and html.
+ Support for output customization (~~see fonts,~~ latex engines,...)
+ More appropriate naming of "master.pdf"
+ Support for an absolute path besides a space separated list of directories.
+ Improvement of script logic, performance, less dependencies,... (whatever is possible!)

## License

This project is licensed under the GNU GPLv3 license.

## Acknowledgments

* Thanks to connermcd for the inspiration and basis of the script. You can find the repository in question here <https://github.com/connermcd/notes>.
