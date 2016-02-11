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

checkArchives $ARCHIVENAME $MD5 $SHA1
