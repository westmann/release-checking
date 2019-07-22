#/bin/bash

# runs some checks on an asterixdb binary release artifact

SCRIPTNAME=$(basename $0)
. $(dirname $0)/check-release-lib.sh
LOGFILE=$(pwd)/$SCRIPTNAME.log

BASENAME=asterix-server-0.9.5
RELEASENAME=apache-asterixdb-0.9.5
ARCHIVENAME=$BASENAME-binary-assembly
SHA256=d80ff63ea5796022f6ce58676d3954438ce703a1da06c5f382b8ace3d4719445

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
ls -1 repo/* | sort > repo.txt
diff repo.txt lic.txt

echo "=== check NOTICE in $(PWD)/NOTICE"

popd
