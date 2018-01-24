#!/bin/bash
# Program:
#   upload new posts to github
# History:
#   2018/1/24   Redleaf23477   First Release

cd .. # go to ./Redleaf23477.github.io
git add _posts
git commit -m "New posts"
git push
