#/bin/bash

# runs some checks on an asterixdb source release artifact

SCRIPTNAME=$(basename $0)
. $(dirname $0)/check-release-lib.sh
LOGFILE=$(pwd)/$SCRIPTNAME.log

BASENAME=apache-hyracks-0.3.3
ARCHIVENAME=$BASENAME-source-release
SHA1=1457b140e61a11da8caa6da75cbeba7c553371de
GERRIT_CHANGE=refs/changes/70/2170/1
REPO=asterixdb
REPO_DIR=hyracks-fullstack

REPO_URL=https://dist.apache.org/repos/dist/dev/asterixdb

MVN_ARGS=-DskipTests

function rat() {
    DIRNAME=$1
    RATREPORT=$(pwd)/rat.report
    RATEXCLUDES=$(pwd)/rat.excludes
    cat > $RATEXCLUDES << EOF
.*\.txt
.*\.tbl
.*tpch.ddl
.*wordcount.tsv
.*scanMicroSortWrite.out
.*master
.*slaves
.*part-0
EOF
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
git fetch https://asterix-gerrit.ics.uci.edu/asterixdb $GERRIT_CHANGE && git checkout FETCH_HEAD
popd

diff -r $REPO/$REPO_DIR $BASENAME

echo "--- files ---"
check $BASENAME NOTICE
check $BASENAME LICENSE

echo "--- build ---"
pushd $BASENAME
mvn install $MVN_ARGS &> $LOGFILE
popd
tail $LOGFILE

