#!/bin/bash

set -o errexit -o nounset

rev=$(git rev-parse --short HEAD)

cd ../_site

git init
git config user.name "Rohit Goswami"
git config user.email "rohit@physics.org"

git remote add upstream "https://aa57fbcd1d7acfa556636b397296ab8c87d757c1@github.com/HaoZeke/CommaCentral.git"
git fetch upstream
git reset upstream/gh-pages

touch .

git add -A .
git commit -m "rebuild pages at ${rev}"
git push -q upstream HEAD:gh-pages