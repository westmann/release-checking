#/bin/bash

# runs some checks on an asterixdb source release artifact

SCRIPTNAME=$(basename $0)
LOGFILE=$(pwd)/$SCRIPTNAME.log

BASENAME=asterix-0.8.7-incubating
ARCHIVENAME=$BASENAME-source-release
MD5=7330e6d6c2dd691ae3ab6a641e4d5344
SHA1=bf0b4a2ceaa26bcf1fcda33fee1ba227e31a88ba
COMMIT=d2e1e89cfdf39e2b772dff2600913bb79644a380
REPO=incubator-asterixdb
TAG=asterix-0.8.7-incubating

REPO_URL=https://dist.apache.org/repos/dist/release/incubator/asterixdb

function get() {
    FILENAME=$1
    if [ -f "$FILENAME" ] 
    then
        echo "found $FILENAME"
    else
        echo "getting $FILENAME"
        curl $REPO_URL/$FILENAME > $FILENAME
    fi
}

function check() {
    BASENAME=$1
    FILENAME=$BASENAME/$2
    if [ -f "$FILENAME" ] 
    then
        echo "check $FILENAME"
    else
        echo "$FILENAME missing"
    fi
}

function rat() {
    DIRNAME=$1
    RATREPORT=$(pwd)/rat.report
    RATEXCLUDES=$(pwd)/rat.excludes
    cat > $RATEXCLUDES << EOF
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

for SUFFIX in zip zip.asc zip.md5 zip.sha1
do
    get $ARCHIVENAME.$SUFFIX
done

echo "--- MD5 ---"
echo $MD5
cat $ARCHIVENAME.zip.md5
echo
cat $ARCHIVENAME.zip | md5

echo "--- SHA1 ---"
echo $SHA1
cat $ARCHIVENAME.zip.sha1
echo
cat $ARCHIVENAME.zip | shasum

echo "--- signature ---"
gpg --verify $ARCHIVENAME.zip.asc $ARCHIVENAME.zip

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
check $BASENAME LICENSE.txt
check $BASENAME DISCLAIMER

echo "--- build ---"
pushd $BASENAME
mvn clean package &> $LOGFILE
popd
tail $LOGFILE

