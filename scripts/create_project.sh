#!/bin/bash

# =============================================================
# This script creates a new sketch projects for Processing
# 
# Author:      Héctor Fabio Espitia Navarro
# Date:        04/25/2017
# Version:     0
# Institution: Georgia Intitute of Technology
#              
# =============================================================

# Input arguments to variables
filename=$1;
# =======================================================
# Functions
# -------------------------------------------------------
# Usage message
usage() 
{
    scriptNameSize=${#0};
    line="";
    for i in $(seq 1 $scriptNameSize); do 
        line="${line}="; 
    done;

cat << EOF
$0
$line

This script creates a new sketch projects for Processing

Usage: 
    $0 [options] <filename>

Arguments:
    filename    File name for the Processing sketch to be created.
    
Options:
    -h --help   Show this message.
EOF
}
# =======================================================
# Arguments checking
if [[ $filename == "" || $filename == "-h" || $filename == "--help" ]]; then
    usage;
    exit 1;
fi
# =======================================================
# Begin of code 
fname=$(basename "$filename");
ext="${fname##*.}";
name="${fname%.*}";
dname=$(dirname $filename)
fulldpath=${dname}/${name};

mkdir -p "$fulldpath";
touch "$fulldpath/$fname";

# End of code 
# =======================================================