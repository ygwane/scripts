#!/bin/bash
#
# Name: md5.sh
# Description: encode passwords with md5 hash.
# Usage: ./md5.sh password
#
# Autor: GG
#
#################################################
##
# USAGE

set -x

usage(){
  echo "Usage: ${0} [PASSWORD]"
  echo "Enter a password To hash with MD5"
  echo "================================="
}

# CHECKING ARG
if [[ $# -lt 1 ]]

then
  echo "Missing password !"
  usage
  exit 1

elif [[ $# -gt 1 ]]

then
  echo "Too many args !"
  usage
  exit 1
fi

# MD5 HASH
MD5=$(echo -n ${1} | md5sum)
echo "Your password: ${1}"
echo "MD5 hash for it: ${MD5}"

# EOS
