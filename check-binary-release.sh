#/bin/bash

# runs some checks on an asterixdb binary release artifact

SCRIPTNAME=$(basename $0)
. $(dirname $0)/check-release-lib.sh
LOGFILE=$(pwd)/$SCRIPTNAME.log

BASENAME=asterix-installer-0.8.8-incubating
ARCHIVENAME=$BASENAME-binary-assembly
MD5=ebfb074c432f73b6407d0d35e0045d1f
SHA1=fdc55e325427b23ca5b6120d92556c2aedb3eff7

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
  unzip ../$ARCHIVEZIP LICENSE NOTICE DISCLAIMER
  for ZIP in $(nestedZips ../$ARCHIVEZIP)
  do
    unzip ../$ARCHIVEZIP $ZIP
    pushd $(dirname $ZIP) >/dev/null
    unwrapZip $(basename $ZIP)
    popd >/dev/null
  done
  popd >/dev/null
}

checkArchives $ARCHIVENAME $MD5 $SHA1

echo "--- Content ---"
unwrapZip $ARCHIVENAME
