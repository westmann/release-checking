#/bin/bash

# runs some checks on an asterixdb source release artifact

SCRIPTNAME=$(basename $0)
. $(dirname $0)/check-release-lib.sh
LOGFILE=$(pwd)/$SCRIPTNAME.log

BASENAME=apache-hyracks-0.3.0
ARCHIVENAME=$BASENAME-source-release
SHA1=4d042cab164347f0cc5cc1cfb3da8d4f02eea1de
COMMIT=def643d586b62b2616b8ab8e6fc3ba598cf5ad67
REPO=asterixdb
REPO_DIR=hyracks-fullstack
TAG=apache-hyracks-0.3.0-rc2

REPO_URL=https://dist.apache.org/repos/dist/dev/asterixdb

MVN_ARGS=-DskipTests

function rat() {
    DIRNAME=$1
    RATREPORT=$(pwd)/rat.report
    RATEXCLUDES=$(pwd)/rat.excludes
    cat > $RATEXCLUDES << EOF
EOF
#target
#DEPENDENCIES
#.*\.adm
#.*\.aql
#.*\.cleaned
#.*\.csv
#.*\.csv.cr
#.*\.csv.crlf
#.*\.csv.lf
#.*\.ddl
#.*\.dot
#.*\.hcli
#.*\.iml
#.*\.json
#.*\.out
#.*\.plan
#.*\.ps
#.*\.scm
#.*\.tbl
#.*\.tbl\.big
#.*\.tsv
#.*\.txt
#.*large_text
#.*part-00000
#.*part-00001
#
#.*\.goutputstream-YQMB2V
#.*02-fuzzy-select
#.*LockRequestFile
#.*hosts
#.*id_rsa
#.*known_hosts
#
#.*bottle.py
#.*geostats.js
#.*jquery.autosize-min.js
#.*jquery.min.js
#.*rainbowvis.js
#.*smoothie.js
    echo "running RAT with excludes in $RATEXCLUDES"
    java -jar ~/soft/apache-rat/apache-rat-0.12.jar -E $RATEXCLUDES -d $DIRNAME > $RATREPORT
    echo "RAT report in $RATREPORT"
    echo -n "  "
    grep "Unknown Licenses" $RATREPORT
}

rm $LOGFILE

checkArchives $ARCHIVENAME $SHA1

echo "--- RAT ---"
[ -d $BASENAME ] || {
    unzip $ARCHIVENAME.zip >> $LOGFILE
}
rat $BASENAME

echo "--- diff --- "
if [ -d $REPO ]
then
    echo "found $REPO"
else
    echo "getting $REPO"
    echo git clone https://git-wip-us.apache.org/repos/asf/$REPO.git
    git clone https://git-wip-us.apache.org/repos/asf/$REPO.git >> $LOGFILE
fi

pushd $REPO
git checkout $COMMIT
popd

diff -r $REPO/$REPO_DIR $BASENAME

echo "--- files ---"
check $BASENAME NOTICE
check $BASENAME LICENSE

echo "--- build ---"
pushd $BASENAME
mvn -o package $MVN_ARGS &> $LOGFILE
popd
tail $LOGFILE

