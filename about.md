# cNotes 

## Bugs && undesired behavior

+ When supplying a single subdirectory of $NOTES_DIR it will create a master pdf that's exactly the same as the pdf in the supplied subdirectory below it. 
	=> actually this is good, user should be able to alter this behavior by supplying the '-r' argument.
+ Only a single pdf per subdirectory in $NOTES_DIR is created? Perhaps a user would like to have the pdf be generated more closely to the supplied subdirectory (test when supplying a path of multiple directory levels deep!)
+ Right now you supply a path by giving a space separated list of directories, you should also (or only??) allow an actual path maybe... of the form "C:\Users\Eigenaar\Desktop\test\Notes\Personal\Projects\BWSort" ?? 
+ I'm using '/' as a path separator (and it seems to work), but it looks ugly when '\' and '/' are mixed in a path...
+ Why can't I use a wildchar in my CD statement, forcing me to use 2 statements instead??


## Towards the future

+ Allow the folders that are named ending in integers to have a title as well separated by a specific character like a dash '-'. This way you can have folders named like this "Project1 - AllPhi CERP", "Project2 - ProjectTitle" !!
+ Allow piping of [vim]grep output (for '\*.md' '\*.markdown' '\*.mkd' files)
