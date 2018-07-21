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

  git checkout $branch &> /dev/null;

  AUTHOR=$(git log -1 --pretty=format:'%an');
  LAST_DATE_COMMIT=$(git log -1 --format=%cd | xargs date "+%Y-%m-%d %H:%M:%S") -d;

  echo ""
  echo "Branch name: $branch"
  echo "Author: $AUTHOR ($LAST_DATE_COMMIT)";
  git merge $CURRENT_BRANCH &> /dev/null;
  if [[ $? -eq 0 ]];
  then
    echo "Status: ✅  No conflicts detected!"
  else
    NUMBER_OF_FILES=$(git --no-pager diff --name-status --diff-filter=U | wc -l | sed -e 's/^[ \t]*//');
    PLURAL=""
    if [ $NUMBER_OF_FILES -gt 1 ];
    then
      PLURAL="s"
    fi
    echo "Status: 🚨  Conflicts, $NUMBER_OF_FILES file$PLURAL affected";
  fi
  git reset --hard $branch &> /dev/null;
done

git checkout -f $CURRENT_BRANCH &> /dev/null;
git stash pop &> /dev/null;
