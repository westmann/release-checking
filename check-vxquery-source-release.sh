#/bin/bash

# runs some checks on an asterixdb source release artifact

SCRIPTNAME=$(basename $0)
. $(dirname $0)/check-release-lib.sh
LOGFILE=$(pwd)/$SCRIPTNAME.log

BASENAME=apache-vxquery-0.6
ARCHIVENAME=$BASENAME-source-release
MD5=b8923b6b5b28ae5c6cca70cb9446737f
SHA1=0ec5ddaf308e8291c46bf9b7e8972d40e743f45f
COMMIT=a678444605bfe7a1edaea13d5a07a1bc7b675939
REPO=vxquery
TAG=apache-vxquery-0.6

REPO_URL=https://repository.apache.org/content/groups/staging/org/apache/vxquery/apache-vxquery/0.6

#.gitignore
#.git/**/*
#testsuites/**/*
#reports/**/*
#**/ExpectedTestResults/**/*
#**/xqts.txt
#test-suite*/**/*

function rat() {
    DIRNAME=$1
    RATREPORT=$(pwd)/rat.report
    RATEXCLUDES=$(pwd)/rat.excludes
    cat > $RATEXCLUDES << EOF
target
ExpectedTestResults
xqts.txt
EOF
    echo "running RAT with excludes in $RATEXCLUDES"
    java -jar ~/soft/apache-rat/apache-rat-0.12.jar -E $RATEXCLUDES -d $DIRNAME > $RATREPORT
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
mvn package &> $LOGFILE
popd
tail $LOGFILE

