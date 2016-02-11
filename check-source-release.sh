#/bin/bash

# runs some checks on an asterixdb source release artifact

SCRIPTNAME=$(basename $0)
. $(dirname $0)/check-release-lib.sh
LOGFILE=$(pwd)/$SCRIPTNAME.log

BASENAME=apache-asterixdb-0.8.8-incubating
ARCHIVENAME=$BASENAME-source-release
MD5=895dc8151d71fc489b42886b207eaa33
SHA1=a98f783acb1b6dee93a574d7d7ea6dcb27480578
COMMIT=a2389dd79543cea4b06474310065ea3018072c54
REPO=incubator-asterixdb
TAG=apache-asterixdb-0.8.8-incubating-rc1

REPO_URL=https://dist.apache.org/repos/dist/dev/incubator/asterixdb

function rat() {
    DIRNAME=$1
    RATREPORT=$(pwd)/rat.report
    RATEXCLUDES=$(pwd)/rat.excludes
    cat > $RATEXCLUDES << EOF
target
DEPENDENCIES
.*\.adm
.*\.aql
.*\.cleaned
.*\.csv
.*\.csv.cr
.*\.csv.crlf
.*\.csv.lf
.*\.ddl
.*\.dot
.*\.hcli
.*\.iml
.*\.json
.*\.out
.*\.plan
.*\.ps
.*\.scm
.*\.tbl
.*\.tbl\.big
.*\.tsv
.*\.txt
.*large_text
.*part-00000
.*part-00001

.*\.goutputstream-YQMB2V
.*02-fuzzy-select
.*LockRequestFile
.*hosts
.*id_rsa
.*known_hosts

.*bottle.py
.*geostats.js
.*jquery.autosize-min.js
.*jquery.min.js
.*rainbowvis.js
.*smoothie.js
EOF
    echo "running RAT with excludes in $RATEXCLUDES"
    java -jar ~/soft/apache-rat/apache-rat-0.11.jar -E $RATEXCLUDES -d $DIRNAME > $RATREPORT
    echo "RAT report in $RATREPORT"
    echo -n "  "
    grep "Unknown Licenses" $RATREPORT
}

rm $LOGFILE

checkArchives $ARCHIVENAME $MD5 $SHA1

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
    git clone https://git-wip-us.apache.org/repos/asf/$REPO.git >> $LOGFILE
fi

pushd $REPO
git checkout $COMMIT
popd

diff -r $REPO $BASENAME

echo "--- files ---"
check $BASENAME NOTICE
check $BASENAME LICENSE
check $BASENAME DISCLAIMER

echo "--- build ---"
pushd $BASENAME
mvn -o package &> $LOGFILE
popd
tail $LOGFILE

