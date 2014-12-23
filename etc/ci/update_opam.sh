#!/usr/bin/env bash

PS4='$ '
set -x

# in case we're run from out of git repo
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
pushd "$DIR" 1>/dev/null

# now change to the git root
ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR" 1>/dev/null

if [ -z "$UPDATE_OPAM" ]; then
    echo 'Not updating OPAM becuase $UPDATE_OPAM variable not set.'
    exit 0
fi

echo 'Configuring git for pushing...'
git config --global user.name "Travis-CI Bot"
git config --global user.email "Travis-CI-Bot@travis.fake"

export MESSAGE="Bump HoTT Coq for $COMMITISH"

export COQ_COMMITISH="$(cd coq-HoTT/ && git rev-list HEAD -1)"

git clone https://github.com/coq/repo-coqs.git || exit $?
echo "http: \"https://github.com/coq/coq/archive/$COQ_COMMITISH.tar.gz\"" > repo-coqs/packages/coq.hott/url

cd repo-coqs || exit $?
git add -f packages/coq.hott/url || exit $?
echo '$ git commit -am "'"$MESSAGE"'"'
git commit -m "$MESSAGE" || exit $?
"$DIR"/pre_push_remote.sh || exit 0
git push origin master:master || exit $?

popd 1>/dev/null
