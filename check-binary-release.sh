#/bin/bash

# runs some checks on an asterixdb binary release artifact

SCRIPTNAME=$(basename $0)
. $(dirname $0)/check-release-lib.sh
LOGFILE=$(pwd)/$SCRIPTNAME.log

BASENAME=asterix-yarn-0.8.8-incubating
ARCHIVENAME=$BASENAME-binary-assembly
MD5=b85f142959e2ae1c72bbc9863938383f
SHA1=ce3def891acff3d5766c62d95b68fe45b4a8a7b6

REPO_URL=https://dist.apache.org/repos/dist/dev/incubator/asterixdb

checkArchives $ARCHIVENAME $MD5 $SHA1
