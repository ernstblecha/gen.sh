#!/bin/bash

SELF=`realpath "$0"`
DIR=`dirname "$SELF"`
ME=`basename "$SELF"`
SESSION_NAME=`echo $ME | sed 's/\./_/g'`
MESSAGES=1
VERSION=1

if [ "$GET_VERSION" = "1" ]; then
  echo $VERSION
  exit 0
fi

function info {
  if [ $MESSAGES = 1 ]; then
    echo $1
  fi
}

function help {
  cat <<HELPFILE
$ME V$VERSION - interface to handle the recurring update commands needed with gentoo

Usecase 1: only outside a tmux session!
           call up a tmux-session showing a bash window and a "cheatsheet"
           set up with vertical divided layout and set the focus to the bash
           if the session already exists it will just attach
           #> $ME

Usecase 2: make typing the cheatsheet commands faster
           just call it with the line number of the cheatsheet
           multiple commands can be called with one line
           a will call all commands from current cheatsheet
           #> $ME 1
           #> $ME 1 2 3
           #> $ME {1..3} #(bash syntax ftw!)

Usecase 3: only within a tmux session
           detach/exit the tmux session
           #> $ME d
           #> $ME x

Usecase 4: show the content of the cheatsheet with less
           #> $ME l

Usecase 5: show current resumelist (cheatsheet if resumelist is empty)
           #> $ME r

Usecase 6: show this help
           #> $ME h
           #> $ME -h
           #> $ME --help
           #> $ME "?"

Usecase 7: show the version
           #> $ME v

Additional Command: produce no command info
           #> $ME q r

Additional Command: show the systeminfo
           #> $ME s

Additional Command: read if the user wants to continue
           #> $ME w

Additional Command: get an estimate on how long building a package will take
           #> $ME e media-gfx/gimp

Additional Command: change the cheatsheet-symlink
           #> $ME c main

Additional Command: info message
           #> $ME i "text1" "text2"
HELPFILE
}

function systeminfo {
  python3 <<SYSTEMINFO.PY
import psutil
import time

mem=psutil.phymem_usage()
print("% 5.1f MB (% 5.1f%%)\t [%s]\t%s" % ((mem.used/1024/1024), mem.percent, ",".join("% 5.1f" % v for v in psutil.cpu_percent(interval=0.1, percpu=True)), (time.strftime("%d/%m/%Y %H:%M:%S"))))
SYSTEMINFO.PY
}

function eta {
#you ask why? because genlop is way too slow...
# this only needs 1/10 of the time of genlop (on my 3.6 MB logfile)
#hacky: we only use the last 3 builds for our estimate
#  why: if you CTRL+C an emerge the logfile is "broken" - starts and stops do not match. This is terrible to handle with grep (at least not using regex)...
  ((grep -e ">>> emerge (" -e "::: completed emerge (" /var/log/emerge.log | grep "$1-" | tail -n 6 | tee >(echo "start=`grep ">>>" | grep -Eo "^[0-9]+" | paste -s -d '+' - - | bc`-0;") >(echo "stop=`grep ":::" | grep -Eo "^[0-9]+" | paste -s -d "+" - - | bc`-0;") >(grep ">>>" | echo "startcount=$(wc -l)-0;";) >(grep ":::" | echo "stopcount=$(wc -l)-0";) > /dev/null;) | cat -; echo "count=startcount+stopcount"; echo "if(stopcount < startcount) -30 else { if(count == 0) -29 else 2*(stop-start)/count }") | bc 
}

function printEta {
  local r;
  local t;
  local name;
  name=`echo "$1" | sed -e 's/^\(.*\)-[0-9]\{1,\}.*$/\1/'`
  r=$((`eta $name`+29))
  t=$(($r/60))
  if (( $r < 0 )); then
    echo "currently merging";
  elif (( $r == 0 )); then
    echo "unknown";
  elif (( $t <= 1 )); then
    echo "<= 1 minute";
  elif (( $t < 2 )); then
    echo "1 minute";
  elif (( $t < 60)); then
    echo "$((t)) minutes";
  elif (( $t < 120 )); then
    if (( $((($t)%60)) == 1 )); then
      echo "1 hour, 1 minute";
    else
      echo "1 hour, $(($t%60)) minutes";
    fi;
  else
    if (( $(($t%60)) == 1 )); then
      echo "$(($t/60)) hours, 1 minute";
    else
      echo "$(($t/60)) hours, $(($t%60)) minutes";
    fi;
  fi;
}

function resumelist {
  python3 <<RESUMELIST.PY
import portage
import subprocess
import shutil

data=portage.mtimedb.get("resume", {}).get("mergelist")

counter=1
if data is not None:
  print(subprocess.getoutput("genlop -unc"))
  print('\nItems in resume list:')
  for item in data:
#    eta = subprocess.getoutput("echo [e] %s | genlop --pretend -n | grep --color=never \"Estimated update time:\" | sed \"s/Estimated update time: //g\"" % item[2])[:-1]; #hacky but does the job for now :(
    eta = subprocess.getoutput("${SELF} q e %s" % item[2]);
    buf = item[2]
    size = shutil.get_terminal_size((80,20))
    if len(buf) > size.columns-25-8:
      buf = buf[:size.columns-25-8-3] + "..."
    print('% 5d.) %s %s%s' % (counter, buf, ' '*(size.columns-25-8-len(buf)), eta))
    counter += 1
    if counter > size.lines:
      break
else:
  print('No items in resume list, showing cheatsheet')
  size = shutil.get_terminal_size((80,20))
  with open('${SELF}_cheatsheet') as f:
    for line in f:
      buf = '% 5d> %s' % (counter, line.rstrip())
      if len(buf) > size.columns:
        print('%s...' % buf[:size.columns-3])
      else:
        print(buf)
      counter += 1
RESUMELIST.PY
}

function savetodo {
  if (( $# > 0 )); then
    if [ "$MESSAGES" = "0" ]; then
      todo="g q"
    else
      todo="g"
    fi
    while (( $# > 0 )); do
      todo="$todo $1"
    shift
    done
    if [ -e /proc/self/fd/3 ]; then
      echo $todo >&3
    fi;
  fi;
}

function quit {
  sudo -k
  exit $1
}

if [[ ! -f ${SELF}_cheatsheet ]]; then
  info "Cheatsheet file missing (directory ${DIR}, named ${ME}_cheatsheet, one command per line)"; exit 1
fi
if ! hash python3 2>/dev/null; then
  info "python3.x not available!"; exit 1
fi
if ! hash tmux 2>/dev/null; then
  info "tmux not available!"; exit 1
fi
if ! hash genlop 2>/dev/null; then
  info "genlop not available!"; exit 1
fi
if ! hash grep 2>/dev/null; then
  info "grep not available!"; exit 1
fi
if ! hash sed 2>/dev/null; then
  info "sed not available!"; exit 1
fi

IS_ACTIVE_SESSION=0
if [ ! -z "$TMUX" ]; then
  if [[ `tmux display-message -p '#S'` == "$SESSION_NAME" ]]; then
    IS_ACTIVE_SESSION=1;
  fi
fi

if (( "$#" )); then
  while (( "$#" )); do
    if [ "$1" = "q" ]; then
      MESSAGES=0
    elif [ "$1" = "v" ]; then
      if [ "$2" != "" ]; then
        info "executing command $1: show version of $2"
        echo `export GET_VERSION=1;$2`
      else
        info "executing command $1: show version of $SELF"
        echo $VERSION
      fi;
      shift
    elif [ "$1" = "x" ]; then
      if [ $IS_ACTIVE_SESSION = 1 ]; then
        info "executing command $1: kill session"
        tmux kill-session
      else
        info "command $1: kill session only available inside a session"
      fi
    elif [ "$1" = "d" ]; then
      if [ $IS_ACTIVE_SESSION = 1 ]; then
        info "executing command $1: detatch client"
        tmux detach-client
      else
        info "command $1: detatch client only available inside a session"
      fi
    elif [ "$1" = "l" ]; then
      info "executing command $1: show cheatsheet"
      less -N ${SELF}_cheatsheet
    elif [ "$1" = "r" ]; then
      info "executing command $1: show resumelist"
      systeminfo
      resumelist
    elif [ "$1" = "h" -o "$1" = "-h" -o "$1" = "--help" -o "$1" = "?" ]; then
      info "executing command $1: show help"
      help
    elif [ "$1" = "s" ]; then
      info "executing command $1: show systeminfo"
      systeminfo
    elif [ "$1" = "w" ]; then
      info "execution command $1: wait for continue"
      read -n 1 -p "[c]ontinue/[b]reak? " tmp;
      echo;
      if [ "$tmp" != "c" ]; then
        info "stopped by user!"
        savetodo $@
        quit 1
      fi;
    elif (( "$1" > 0 && "$1" <= "$(wc -l <${SELF}_cheatsheet)" )); then
      COMM=$(sed -n ${1}p ${SELF}_cheatsheet)
      info "executing command #$1: $COMM"
      /bin/bash -c "$COMM"
      tmp=$?
      if [ $tmp != 0 ]; then
        info "returncode was $tmp; aborting"
        savetodo $@
        quit $tmp
      fi
    elif [ "$1" == "e" ]; then
      info "executing command $1: estimate build time for $2"
      printEta $2
      shift
    elif [ "$1" == "c" ]; then
      info "executing command $1: change cheatsheet to $2"
      if [ "$2" != "" -a -e "$DIR/gen.sh_cheatsheet_$2" ]; then
        ln -s -f "./gen.sh_cheatsheet_$2" "$DIR/gen.sh_cheatsheet"
      else
        info "given cheatsheet does not exist"
      fi
      shift
    elif [ "$1" == "i" ]; then
      info "executing command $1: show message"
      echo $2 $3
      notify-send "$2" "$3"
      shift 2
    else
      info "unknown command $1"
      quit 1
    fi
    shift
  done
  quit 0
else
  if [ -z "$TMUX" ]; then
    tmux has-session -t ${SESSION_NAME}
    if [ $? != 0 ]; then
      tmux new-session -d -s ${SESSION_NAME} "/bin/bash --init-file <(echo \"source ~/.bashrc; function exit { gen.sh x; }; function x { gen.sh x; }; function d() { gen.sh q d; }; function g() { tmpfile=\\\`mktemp\\\`; exec 3>\\\$tmpfile; ${SELF} \\\${@}; tmp=\\\$?; history -s \\\"g \\\${@}\\\";  history -s \\\`cat \\\$tmpfile\\\`; rm \\\$tmpfile; exec 3>&-; return \\\$tmp; };\")";
      tmux split-window -v -p 70 -t "${SESSION_NAME}" "watch -t $SELF q r"
      tmux select-pane -t 0
    fi
    tmux attach -t ${SESSION_NAME}
  else
    if [ $IS_ACTIVE_SESSION ]; then
      info "already in a tmux session started from $ME"
    else
      info "already in a tmux session (manually started)"
    fi
  fi
fi
