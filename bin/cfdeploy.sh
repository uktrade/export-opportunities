#!/bin/bash
# deploy to a custom branch in CF Gov PaaS


NAME=$(echo $CIRCLE_BRANCH | sed 's,/,-,g')
# python ./config/scripts/import_heroku_variables_cloudfoundry.py --source staging-new-design-eig --destination $NAME-$CIRCLE_PROJECT_REPONAME


