#!/bin/sh

echo "Packaging deploy into RPM Package"

set -e

function get_iteration() {
  prefix="hs"
  if [ "$GIT_BRANCH" != "master" ]
  then
    prefix="${prefix}~${GIT_BRANCH//[^[:alnum:]]/_}"
  fi
  echo "${prefix}.${BUILD_NUMBER}"
}

function prepare_sources() {
  JAR_DIR=$1/usr/share/hubspot/hbck2

  mkdir -p $JAR_DIR

  echo "Looking for artifacts to include in RPM"

  jar_path=$(ls ./target/hbase-hbck2-*.jar)
  jar_name=$(basename $jar_path)
  echo "Copying jar $jar_name to sources dir"
  cp $jar_path $JAR_DIR/$jar_name
  echo "Creating symlink to hbase-hbck2.jar in sources dir"
  pushd $JAR_DIR
  ln -sf $jar_name ./hbase-hbck2.jar
  popd
}

NAME="hbase-hbck2"
VERSION="1.0"
ITERATION=$(get_iteration)
FULL_VERSION="$VERSION-$ITERATION"

echo "Creating RPM: $NAME-$FULL_VERSION"
SOURCES_DIR="sources"
prepare_sources $SOURCES_DIR
pushd $SOURCES_DIR

fpm \
  --name $NAME \
  --version ${VERSION} \
  --iteration "${ITERATION}" \
  -s "dir" \
  -t "rpm" \
  --package $RPMS_OUTPUT_DIR \
  .

popd
