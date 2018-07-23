A postcommit hook to warn you about merge conflicts introduced with other branches of the repo.

## Installation

```
npm i conflict-detector husky --save-dev
```

Add a line in your package.json:

```
  "scripts": {
    ...
    "postcommit": "conflict-detector",
    ...
  },
```

## Known issues with the script

If you realize a partial commit, the script will use the stash, therefore add an item on top of it.

## Features needed

Create a config file containing branches to protect instead of running on all of the branches.
