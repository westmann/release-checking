#/bin/bash

# runs some checks on an asterixdb binary release artifact

SCRIPTNAME=$(basename $0)
. $(dirname $0)/check-release-lib.sh
LOGFILE=$(pwd)/$SCRIPTNAME.log

ASTERIX_VERSION=0.9.8.1
HYRACKS_VERSION=0.3.8.1

BASENAME=asterix-server-$ASTERIX_VERSION
RELEASENAME=apache-asterixdb-$ASTERIX_VERSION
ARCHIVENAME=$BASENAME-binary-assembly
SHA512=4c0b73127d8c33287a3768538094a15aceb905e353ed3e9c7dfb3b1ec553f57ccdcfda9411fa2a2bfb0bc9fa7abe50e9f517bf797326740a65b4605874e9601f

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
