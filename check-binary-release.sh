#/bin/bash

# runs some checks on an asterixdb binary release artifact

SCRIPTNAME=$(basename $0)
. $(dirname $0)/check-release-lib.sh
LOGFILE=$(pwd)/$SCRIPTNAME.log

BASENAME=apache-asterixdb-0.9.4
ARCHIVENAME=$BASENAME
SHA256=0b939231635f0c2328018f7064df9a4fa4b05b36835127a12eae4543141aecd9

REPO_URL=https://dist.apache.org/repos/dist/dev/asterixdb

function unwrapZip() {
  local ARCHIVEZIP=$1
  local ARCHIVEDIR=$(echo $ARCHIVEZIP | sed -e's/.zip$//').exploded
  echo "=== exploding $ARCHIVEZIP in $(pwd) into $ARCHIVEDIR"
  mkdir $ARCHIVEDIR
  pushd $ARCHIVEDIR >/dev/null
  unzip -q ../$ARCHIVEZIP
  popd >/dev/null
}

checkArchives $ARCHIVENAME $SHA256

echo "--- Content ---"
unwrapZip $ARCHIVENAME

echo "=== check NOTICE file"
echo "=== check LICENSE file against repo"
echo "  > awk '/- repo/ { print $2 }' LICENSE | sort > lic.txt"
echo "  > ls -1 repo/* | sort > repo.txt"
echo "  > diff repo.txt lic.txt"
