# gen.sh
interface to handle the recurring update commands needed with gentoo

# Usecase 1: startup
           only outside a tmux session!

           call up a tmux-session showing a bash window and a "cheatsheet"
           set up with vertical divided layout and set the focus to the bash

           if the session already exists it will just attach
```
           #> gen.sh
```

# Usecase 2: make typing the cheatsheet commands faster
           just call it with the line number of the cheatsheet.

           multiple commands can be called with one line, `a` will call all commands from current cheatsheet
```
           #> gen.sh 1
           #> gen.sh 1 2 3
           #> gen.sh {1..3} #(bash syntax ftw!)
```

# Usecase 3: detach/exit the tmux session
           only within a tmux session
```
           #> gen.sh d
           #> gen.sh x
```

# Usecase 4: show the content of the cheatsheet with less
```
           #> gen.sh l
```

# Usecase 5: show current resumelist (cheatsheet if resumelist is empty)
```
           #> gen.sh r
```

# Usecase 6: show this help
```
           #> gen.sh h
           #> gen.sh -h
           #> gen.sh --help
           #> gen.sh "?"
```
# Usecase 7: show version
```
           #> gen.sh v
```

# Additional Command: produce no command info
```
           #> gen.sh q r
```

# Additional Command: show the systeminfo
```
           #> gen.sh s
```

# Additional Command: read if the user wants to continue
```
           #> gen.sh w
```

# Additional Command: get an estimate on how long building a package will take
```
           #> gen.sh e media-gfx/gimp
```

# Additional Command: change the cheatsheet-symlink
```
           #> gen.sh c main
```

# Additional Command: info message
```
           #> gen.sh i "text1" "text2"
```
