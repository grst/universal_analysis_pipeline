#!/usr/bin/env bash

if [ ! -f ".access_token" ]; then
  cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1 > .access_token
fi
ACCESS_TOKEN=$(cat .access_token)

# create github-pages branch if it doesn't exist
if [ ! -d "deploy/.git" ]; then
  mkdir -p deploy
  git init deploy
  REMOTE=$(git config --get remote.origin.url)
  cd deploy
  git remote add origin $REMOTE
  git checkout --orphan gh-pages
  git commit --allow-empty -m "init gh-pages"
  cd ..
fi

# copy over reports
rsync -PvaL --delete --include "*/" --include="*.html" --exclude="*"\
  results/ deploy/$ACCESS_TOKEN/

# deploy on gh-pages
cd deploy && git co gh-pages && git add -A . \
  && git commit --allow-empty -m "deploy reports" \
  && git push -u origin gh-pages

