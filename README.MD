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

+) on windows
```
setx PATH=%PATH%;Your/Path/To/The/Application/Directory/
```
+) on mac
```
```
+) on linux
```
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
notes [-i DIRECTORY] [-r] all
```
Compiles all notes from the $NOTES_DIR directory.
```
notes [-i DIRECTORY] [-r] (SUB)DIRECTORY [[,...n] | [...n] [int [[,...n] | [-int]]]]
```
Compiles all notes from the (SUB)DIRECTORY contained in $NOTES_DIR. Multiple directories can be included by separating them with a comma, or the compilation can be excluded to an other subdirectory level by providing additional subdirectories in a space separated list. An optional integer, integer list, or integer range can also be supplied in this latter case to limit the compilation to those folders ending in an integer that's included in the supplied collection.

#### Syntax:

	-i DIRECTORY
		Sets the $NOTES_DIR environment variable.
	-r
		Root only, only generate master pdf.
	[]
		Optional argument
	[,...n]
		Optional comma separated values
	[...]
		Optional space separated values
	|
		OR, used to specify mutually exclusive items.
```

#### Environment and Examples



## License

This project is licensed under the GNU GPLv3 license.

## Acknowledgments

* Thanks to connermcd for the inspiration and basis of the script. You can find the repository in question here <https://github.com/connermcd/notes>.
