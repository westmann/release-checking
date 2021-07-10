#/bin/bash

# runs some checks on an asterixdb binary release artifact

SCRIPTNAME=$(basename $0)
. $(dirname $0)/check-release-lib.sh
LOGFILE=$(pwd)/$SCRIPTNAME.log

ASTERIX_VERSION=0.9.7
HYRACKS_VERSION=0.3.7

BASENAME=asterix-server-$ASTERIX_VERSION
RELEASENAME=apache-asterixdb-$ASTERIX_VERSION
ARCHIVENAME=$BASENAME-binary-assembly
SHA256=fb38aed1daaca7faa2aeb8b45ff7ab227e11ca1e92ab4995fb973fefcc794611

REPO_URL=https://dist.apache.org/repos/dist/dev/asterixdb

function unwrapZip() {
  local ARCHIVEZIP=$1
  local ARCHIVEDIR=$(echo $ARCHIVEZIP | sed -e's/.zip$//').exploded
  mkdir $ARCHIVEDIR
  pushd $ARCHIVEDIR >/dev/null
  unzip -q ../$ARCHIVEZIP
  popd >/dev/null
  echo $ARCHIVEDIR
}

checkArchives $ARCHIVENAME $SHA256

echo "--- Content ---"

ARCHIVEDIR=`unwrapZip $ARCHIVENAME`

pushd $ARCHIVEDIR/$RELEASENAME

echo "=== checking LICENSE against repo"
awk '/- repo/ { print $2 }' LICENSE | sort > lic.txt
ls -1 repo/* | \
    grep -v algebricks-.*-$HYRACKS_VERSION.jar | \
    grep -v hyracks-.*-$HYRACKS_VERSION.jar | \
    grep -v asterix-.*-$ASTERIX_VERSION.jar | \
    sort > repo.txt
diff repo.txt lic.txt

echo "=== check NOTICE in $(PWD)/NOTICE"

popd
