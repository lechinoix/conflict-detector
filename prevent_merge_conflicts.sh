#!/bin/bash

IS_BRANCH_DIRTY=$(git status -s | grep -v "^?? ")
CURRENT_BRANCH=$(git rev-parse --symbolic-full-name --abbrev-ref HEAD)

function restore_branch {
  git checkout -f $CURRENT_BRANCH &> /dev/null;

  if [ $IS_BRANCH_DIRTY ];
  then
    git stash pop &> /dev/null;
  fi
}

trap restore_branch EXIT;

echo "Starting test branches for merge conflicts..."
git fetch &> /dev/null;
git remote update origin --prune &> /dev/null;

if [ $IS_BRANCH_DIRTY ];
then
  git stash &> /dev/null;
fi

for branch in $(git --no-pager branch -a | sed -e 's/^\*/ /')
do

  if [ $branch = $CURRENT_BRANCH ];
  then
    continue
  fi

  AUTHOR=$(git log $branch -1 --pretty=format:'%an');
  LAST_DATE_COMMIT=$(git log $branch -1 --format=%cd --date=relative);

  echo ""
  echo "Branch name: $branch"
  echo "Author: $AUTHOR ($LAST_DATE_COMMIT)";
  git merge $branch --no-ff --no-commit &> /dev/null;
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
  git merge --abort &> /dev/null;
done
