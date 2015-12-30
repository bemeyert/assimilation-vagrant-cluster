#!/usr/bin/env bash
###############################################################################
# 
# Filename   : 
# Description: 
# Author     : Markus Uckelmann <>
#
# Notation:
# - Variables with upper case at the beginning are global variables
# - Variables in capitals have a constant value
#
# TODO
# - nothing yet ;)
###############################################################################

###############################################################################
### define/initialize script wide variables

DEBUG=1
PROGNAME="${0##*/}"
#VERSION="0.0.1"


################################################################################
### functions

# those two are faster then the shell-builtins
function _dirname () { echo ${1%/*} ; }
function _basename () {
    local B
    B=${1##*/}
    echo ${B%$2}
}
# echo to STDERR
function _err_echo () {
    local msg
    msg="$*"
    local d=$(date '+%b %d %H:%m:%S')
    echo "$d $msg" >&2
}
# echo to STDERR and exit
function _bail () {
    local message
    message="$@"
    _err_echo $message
    exit 2
}
# secure cd
function _cd () {
    local dir="$1"
    if [ ! -d $dir ] ; then
        _bail "Directory $dir does not exist!"
    fi
    cd $dir || _bail "Could not change to directory $dir!"
}
# ask me
function _ask () {
    local ans
    echo -n "May I proceed?(y|N) "
    read ans
    [[ -z $ans ]] && { echo "exiting..." ; exit 1 ; }
    case $ans in
        n|N) { echo "exiting..." ; exit 1 ; } ;;
        y|Y) return 0 ;;
        *)   { echo "exiting..." ; exit 1 ; } ;;
    esac
}
# print help
function _help () {
cat <<-EOF

    scriptname Version $VERSION

    Grundsaetzliche Beschreibung des Skriptes

    Hier findet man noch mehr Dokumentation

    Optionen(oder gebraeuchlichste Optionen, wenn zu viele)

        --option1=<wert>        Beschreibung
        --option2=<wert>        Beschreibung
        --option3=<wert>        Beschreibung
        ...
EOF
exit 1
}

### main script

set -ex
yum clean all
yum -y update

# vim: ts=4 sw=4 expandtab ft=sh
