#!/bin/bash
# Program:
#   copy the template to make a new post
#   and open it with vim
# Usage:
#   newpost.sh FILENAME
# History:
#   2018/1/24   Redleaf23477   First Release

if [ "$#" -ne 1 ]; then
    echo "Parameters Error!"
    echo "Parameter Num = $#"
    exit 0
fi

FILENAME=${1}

test -e ${FILENAME} && echo "file exsists!" && exit 0

cp ./post_template.md ./${FILENAME}
vim ./${FILENAME}

exit 0

