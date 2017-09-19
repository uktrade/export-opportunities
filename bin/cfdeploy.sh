#!/bin/bash
# deploy to a custom branch in CF Gov PaaS

NAME=$(echo $CIRCLE_BRANCH | sed 's,/,-,g')
cf push $NAME-$CIRCLE_PROJECT_REPONAME
