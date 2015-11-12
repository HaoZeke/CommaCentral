#!/bin/bash

set -o errexit -o nounset

rev=$(git rev-parse --short HEAD)

cd ../_site
#rm -rf .git

git init


#git remote add upstream "git@github.com:HaoZeke/CommaCentral.git"
git fetch upstream
git reset upstream/gh-pages

touch .

git add -A .
git commit -m "rebuild pages at ${rev}"
git push -q upstream HEAD:gh-pages