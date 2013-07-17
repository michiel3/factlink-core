#!/bin/bash

# go to the root of the git repo
cd `dirname $0`
cd ..

./script/set-status.sh "$GIT_COMMIT" pending "$BUILD_URL" "$BUILD_TAG" > github_pending_response.json


export RUBY_HEAP_MIN_SLOTS=1000000
export RUBY_HEAP_SLOTS_INCREMENT=1000000
export RUBY_HEAP_SLOTS_GROWTH_FACTOR=1
export RUBY_GC_MALLOC_LIMIT=100000000
export RUBY_HEAP_FREE_MIN=500000

rm -f TEST_FAILURE
rm -f tmp/*.junit.xml

for action in bin/ci/*.sh; do
  banner $action;
  time /bin/bash "$action"
  if [ "$?" -gt "0" ] ; then
    ./script/set-status.sh "$GIT_COMMIT" error "$BUILD_URL" "$BUILD_TAG"
    exit 1
  fi
  if [ -f TEST_FAILURE ] ; then
    ./script/set-status.sh "$GIT_COMMIT" failure "$BUILD_URL" "$BUILD_TAG"
    exit
  fi
done
./script/set-status.sh "$GIT_COMMIT" success "$BUILD_URL" "$BUILD_TAG"  > github_success_response.json
