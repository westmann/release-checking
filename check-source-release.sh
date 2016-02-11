#/bin/bash

# runs some checks on an asterixdb source release artifact

SCRIPTNAME=$(basename $0)
LOGFILE=$(pwd)/$SCRIPTNAME.log

BASENAME=apache-asterixdb-hyracks-0.2.17-incubating
ARCHIVENAME=$BASENAME-source-release
MD5=e8390e5821b5d10b3b8a996f59c7f06a
SHA1=b1b3e1d7c19f9384e3f311aff54dba95acb9c788
COMMIT=3945f24ea72908e8ded1a56c712de097a09e6d01
REPO=incubator-asterixdb-hyracks
TAG=apache-asterixdb-hyracks-0.2.17-incubating-rc1

REPO_URL=https://dist.apache.org/repos/dist/dev/incubator/asterixdb

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
target
.*\.piglet
.*\.tbl
.*\.txt
.*\.js
jquery-ui.css
data1
data2
data3
data4
name1
name2
ClusterControllerService
tpch.ddl
scanMicroSortWrite.out
master
slaves
wordcount.tsv
conf.xml
part-0
part-0
dist.all.first.cleaned
dist.all.last.cleaned
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
check $BASENAME LICENSE
check $BASENAME DISCLAIMER

echo "--- build ---"
pushd $BASENAME
mvn -o install -DskipTests &> $LOGFILE
popd
tail $LOGFILE

