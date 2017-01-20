#/bin/bash

# runs some checks on an asterixdb binary release artifact

SCRIPTNAME=$(basename $0)
. $(dirname $0)/check-release-lib.sh
LOGFILE=$(pwd)/$SCRIPTNAME.log

BASENAME=asterix-yarn-0.9.0
ARCHIVENAME=$BASENAME-binary-assembly
SHA1=3ade0d2957e7f3e465e357aced6712ef72598613

REPO_URL=https://dist.apache.org/repos/dist/dev/incubator/asterixdb

function nestedZips() {
  local ZIPFILE=$1
  zipinfo -1 $ZIPFILE | grep \.zip
}

function unwrapZip() {
  local ARCHIVEZIP=$1
  echo -n "=== unwrapping $ARCHIVEZIP in "
  pwd
  local ARCHIVENAME=$(echo $ARCHIVEZIP | sed -e's/.zip$//')
  mkdir $ARCHIVENAME
  pushd $ARCHIVENAME >/dev/null
  unzip ../$ARCHIVEZIP LICENSE NOTICE
  for ZIP in $(nestedZips ../$ARCHIVEZIP)
  do
    unzip ../$ARCHIVEZIP $ZIP
    pushd $(dirname $ZIP) >/dev/null
    unwrapZip $(basename $ZIP)
    popd >/dev/null
  done
  popd >/dev/null
}

checkArchives $ARCHIVENAME $SHA1

echo "--- Content ---"
unwrapZip $ARCHIVENAME
