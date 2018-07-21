#!/bin/bash

echo "Starting test branches for merge conflicts..."

git stash &> /dev/null;
CURRENT_BRANCH=$(git rev-parse --symbolic-full-name --abbrev-ref HEAD)

for branch in $(git for-each-ref --format='%(refname:short)' refs/heads/)
do

  if [ $branch = $CURRENT_BRANCH ];
  then
    continue
  fi

  echo ""
  echo "Running merge test for $branch"
  git checkout $branch &> /dev/null;
  git merge $CURRENT_BRANCH &> /dev/null;
  if [[ $? -eq 0 ]];
  then
    echo "No conflicts detected!"
  else
    AUTHOR=$(git log -1 --pretty=format:'%an');
    NUMBER_OF_FILES=$(git ls-files -u | wc -l);
    echo "Conflicts detected with $branch : $NUMBER_OF_FILES files affected";
    echo "Contact $AUTHOR to discuss whether you should continue your branch or not";
  fi
  git reset --hard $branch &> /dev/null;
done

git checkout -f $CURRENT_BRANCH &> /dev/null;
git stash pop &> /dev/null;
