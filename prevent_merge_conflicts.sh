#!/bin/bash

set -e
git stash &> /dev/null;
CURRENT_BRANCH=$(git rev-parse --symbolic-full-name --abbrev-ref HEAD)

for branch in $(git branch -a)
do
  git checkout $branch &> /dev/null;
  git merge $CURRENT_BRANCH &> /dev/null;
  FILE_CONFLICTS=$(git ls-files -u) &> /dev/null;
  echo "Merge conflicts for $branch"
  echo $FILE_CONFLICTS;
  if [[ $FILE_CONFLICTS ]];
  then
    echo "Conflicts detected with $branch : $(wc -l $FILE_CONFLICTS) files affected";
  fi
  git reset --hard $branch;
done

git checkout -f $CURRENT_BRANCH &> /dev/null;
git stash pop &> /dev/null;

set +e
