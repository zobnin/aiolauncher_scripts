#!/bin/sh

IFS='
'
DIR="$HOME/Dropbox/Apps/AIO Launcher"
#TASKS_DIR="$DIR/tasks"
#NOTES_DIR="$DIR/notes"
# Changed in AIO 4.4.2
TASKS_DIR="$DIR/w.tasks"
NOTES_DIR="$DIR/w.notes"

list() {
    i=0
    for file in $DIR/w.$1/*; do
        i=$((i+1))
        echo -n "[$i] "

        show_time $1 $file
        show_contents $file

        echo
        echo
    done
}

show_time() {
    dir=$1
    file=$2

    case $dir in
        "w.tasks")
            date=`cat $file | grep '^dueDate' | cut -d ' ' -f 2,3,4`

            if [ ! -z $date ]; then
                echo $date
            else
                echo "No time"
            fi
            ;;
        "w.notes")
            basename $file .txt | cut -d '_' -f 1 | sed 's/-/./g'
            ;;
    esac
}

show_contents() {
    file=$1

    if [ ! -z `grep "^----$" $file` ]; then
        cat $file | sed '1,/^----$/d'
    else
        cat $file
    fi
}

edit() {
    dir=$1
    id=$2

    case $dir in
        "task")
            LIST_DIR=$TASKS_DIR
            ;;
        "note")
            LIST_DIR=$NOTES_DIR
            ;;
        *)
            return
            ;;
    esac

    i=0
    for file in $LIST_DIR/*; do
        i=$((i+1))

        if [ $i == $id ]; then
            $EDITOR $file
        fi
    done
}

remove() {
    dir=$1
    id=$2

    case $dir in
        "task")
            LIST_DIR=$TASKS_DIR
            ;;
        "note")
            LIST_DIR=$NOTES_DIR
            ;;
        *)
            return
            ;;
    esac

    i=0
    for file in $LIST_DIR/*; do
        i=$((i+1))

        if [ $i == $id ]; then
            mkdir $LIST_DIR/.removed 2>/dev/null
            mv $file $LIST_DIR/.removed
        fi
    done
}

add() {
    case $1 in
        "task")
            LIST_DIR=$TASKS_DIR
            ;;
        "note")
            LIST_DIR=$NOTES_DIR
            ;;
        *)
            return
            ;;
    esac

    $EDITOR $LIST_DIR/new.txt
}

case $1 in
    "tasks")
        list tasks
        ;;
    "notes")
        list notes
        ;;
    "edit")
        edit $2 $3
        ;;
    "add")
        add $2
        ;;
    "rm")
        remove $2 $3
        ;;
    *)
        echo "Usage:
    aio tasks - list all tasks
    aio notes - list all notes
    aio edit task <ID> - edit note
    aio edit note <ID> - edit task
    aio add task - add new task
    aio add note - add new note
    aio rm task <ID> - remove task
    aio rm note <ID> - remove note"
        ;;
esac

