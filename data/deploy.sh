#!/bin/bash

# This is the deploy script (to Github pages) that can deploy
# a set of input files to Github pages given that the GITHUB_TOKEN is found
# in the environment. The script requires the token, and first generates
# the images, and deploys them to GitHub pages

cd ${GITHUB_WORKSPACE}
ls

# Copy data files to data
cp task-cpu/vanessa-thinkpad-t460s_vanessa.jso data/task-cpu.json
cp task-system/vanessa-thinkpad-t460s_vanessa.json data/task-system.json
cp task-sensors/vanessa-thinkpad-t460s_vanessa.jso data/task-sensors.json
cp task-network/vanessa-thinkpad-t460s_vanessa.jso data/task-network.json
cp task-memory/vanessa-thinkpad-t460s_vanessa.jso data/task-memory.json

cd data/
echo "Generating images..."
python3 generate.py

DEPLOY_FILES=$(ls img)
GHPAGES=$(mktemp -d -t ghpages.XXX)

for DEPLOY_FILE in ${DEPLOY_FILES}; do
    if [ ! -f "${DEPLOY_FILE}" ]; then
        echo "Cannot find ${DEPLOY_FILE}";
        exit 1;
    else
        mv "${DEPLOY_FILE}" "${GHPAGES}/"
    fi
done

# Only deploy on change to master (or used specified branch)
GITHUB_BRANCH="${GITHUB_BRANCH:-refs/heads/master}"

# Is the branch the user specified the one we are on?
if [ "${GITHUB_BRANCH}" != "${GITHUB_REF}" ]; then
    echo "${GITHUB_BRANCH} != ${GITHUB_REF}, skipping deploy"
    exit 0;
fi

# Set up variables for remote repository and branch
REMOTE_REPO="https://${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"
REMOTE_BRANCH="gh-pages"

# Initialize Github Pages and push
git init && \
    git config user.name "${GITHUB_ACTOR}" && \
    git config user.email "${GITHUB_ACTOR}@users.noreply.github.com" && \

    # Checkout orphan branch, we remove all because can't add main.workflow
    git checkout gh-pages || git checkout --orphan gh-pages
    git pull origin gh-pages
    git rm -rf .

    # Add the deploy files to the PWD, an empty github pages
    for DEPLOY_FILE in ${DEPLOY_FILES}
        do
        if [ ! -f "${DEPLOY_FILE}" ]; then
            filename=$(basename "${DEPLOY_FILE}")
            cp "${GHPAGES}/${filename}" .
        fi
        git add $(basename "${DEPLOY_FILE}");
    done

    # Push to Github pages
    git commit -m 'Automated deployment to Github Pages: Action deploy' --allow-empty && \
    git push origin gh-pages && \
    echo "Successful deploy."
