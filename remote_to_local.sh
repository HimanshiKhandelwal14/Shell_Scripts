#!/bin/bash
PROGVERS="1.6"
function usagemsg {
    echo "usage (v$PROGVERS):"
    echo " $PROG basedir -h remote_host -u remote_user"
    echo "  [-g GetDocTyp ...] [-p PutDocTyp ...] [-f doctyp_file] [-s] [-P port] [-B banner_lines] [-d debug_level]"
    exit 1
}
function msg {
    if [ $1 -le ${DBGLVL} ]; then
        DATTIMSTP=$(date +%H:%M:%S)
        if [ $STDOUTFLAG -ne 0 ]; then
            echo "$DATTIMSTP$2 [$1]"
        else
            echo "$DATTIMSTP$2 [$1]" >> $LOGFIL
        fi
    fi
}
function dispfile {
    if [ $1 -le ${DBGLVL} ]; then
        msg $1 "  --- $2: ($(basename $3)) ---"
        while read TXTLIN; do
            if [ $STDOUTFLAG -ne 0 ]; then
                echo "          $TXTLIN"
            else
                echo "          $TXTLIN" >> $LOGFIL
            fi
        done < $3
    fi
}
function runsftpcmd {
    dispfile $1 "$3 commands" $4
    sftp $PORTARGS -Cb $4 $RMTUSER@$RMTHOST > $5 2>&1
    SFTPRETVAL=$?

    if [ $NUMBANLNS -gt 0 ]; then
        sed "1,${NUMBANLNS}d" $5 > $SFTPBANFIL
        cp $SFTPBANFIL $5
    fi

    dispfile $2 "$3 results" $5
}
function cleanup {
    rm -f $SFTPCMDFIL $SFTPRSTFIL $SFTPBANFIL $FILNMSFIL $NEWFILNMSFIL $MOVFLSFIL $WINFMTFIL $GD_TMPNMSFIL $ERRLOG
}

function runstrrfccmd {
    eval $1 2>&1
    STRRFCRETVAL=$?
    if [ $STRRFCRETVAL -ne $2 ]; then
        MSG="$(echo $1 | awk "$RMPWDAWKPRG") returned $STRRFCRETVAL"
        msg 0 "E $MSG"; sendemail error "$MSG"
    fi
}
function extdoctypfldval {
    FLDVAL=$(awk -F ':' "/$1/ {sub(\"[  ].*\", \"\", \$$2); print \$$2}" $DOCTYPSFIL)
}

PROG=$(basename $0)
DBGLVL=3
FINDFILES=/usr/local/bin/findfiles
STDOUTFLAG=0
LOGDIR=/var/tmp/$PROG
LOGFIL=$LOGDIR/$(date +%Y%m%d)
ERRLOG=/tmp/$PROG_$$_errlog

### Check command line args.
if [ $# -lt 5 ]; then
    usagemsg
    exit 1
fi
