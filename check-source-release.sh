#/bin/bash

# runs some checks on an asterixdb source release artifact

SCRIPTNAME=$(basename $0)
. $(dirname $0)/check-release-lib.sh
LOGFILE=$(pwd)/$SCRIPTNAME.log

BASENAME=apache-asterixdb-0.9.0
ARCHIVENAME=$BASENAME-source-release
SHA1=49f8df822c6273a310027d3257a79afb45c8d446
COMMIT=4383bdde78c02d597be65ecf467c5a7df85a2055
REPO=asterixdb
REPO_DIR=asterixdb
TAG=apache-asterixdb-0.9.0-rc2

REPO_URL=https://dist.apache.org/repos/dist/dev/asterixdb

#MVN_ARGS=-DskipTests

function rat() {
    DIRNAME=$1
    RATREPORT=$(pwd)/rat.report
    RATEXCLUDES=$(pwd)/rat.excludes
    cat > $RATEXCLUDES << EOF
.*\.adm
.*\.csv
.*\.csv.cr
.*\.csv.crlf
.*\.csv.lf
.*\.json
.*\.tbl
.*\.tbl\.big
.*\.tsv
.*\.ast
.*\.plan
EOF
#target
#DEPENDENCIES
#.*\.aql
#.*\.cleaned
#.*\.ddl
#.*\.dot
#.*\.hcli
#.*\.iml
#.*\.out
#.*\.plan
#.*\.ps
#.*\.scm
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
mvn package $MVN_ARGS &> $LOGFILE
popd
tail $LOGFILE

