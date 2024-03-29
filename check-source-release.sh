#/bin/bash

# runs some checks on an asterixdb source release artifact

SCRIPTNAME=$(basename $0)
. $(dirname $0)/check-release-lib.sh
LOGFILE=$(pwd)/$SCRIPTNAME.log

BASENAME=apache-asterixdb-0.9.8.1
ARCHIVENAME=$BASENAME-source-release
SHA512=35e80f1f2068da10820777b2308a2b5e96727aecc46232beaeff5166dd0a625a8441bbe7961bf70b4796462f7c4dfa004c51685f70702404cde1961cd2e854fc
GERRIT_CHANGE=refs/changes/02/17502/2
REPO=asterixdb
REPO_DIR=asterixdb

REPO_URL=https://dist.apache.org/repos/dist/dev/asterixdb

MVN_ARGS=-DskipTests

function rat() {
    DIRNAME=$1
    RATREPORT=$(pwd)/rat.report
    RATEXCLUDES=$(pwd)/rat.excludes
    ratexcludes > $RATEXCLUDES
    echo "running RAT with excludes in $RATEXCLUDES"
    java -jar ~/soft/apache-rat/apache-rat-0.13.jar -E $RATEXCLUDES -d $DIRNAME > $RATREPORT
    echo "RAT report in $RATREPORT"
    echo -n "  "
    grep "Unknown Licenses" $RATREPORT
}

function ratexcludes() {
    case $REPO_DIR in
    asterixdb)
        cat << EOF
.*\.adm
.*big_object.*20M.*\.adm.template
.*\.ast
.*dist.*\.cleaned
.*\.csv
.*\.dgen
.*\.csv.cr
.*\.csv.crlf
.*\.csv.lf
.*\.iml
.*\.json
.*\.plan
.*\.scm
.*\.tbl
.*\.tbl\.big
order\.tbl\.verylong\.big
.*\.tsv
.*\.txt
.*\.regexadm
.*\.regex
.*\.regexjson
.*\.ignore
.*\.ebnf
part-0000.*
jobads\.new
jobads\.old
large_text
tpch\.ddl
overlapping\.data
classad-with-temporals\.classads
bootstrap\.min\.js
jquery\.autosize-min\.js
jquery\.min\.js
rainbowvis\.js
policy\.properties
LockRequestFile
asm\.objectweb\.org_license\.html
glassfish\.dev\.java\.net_public_CDDL_GPL_1_1\.html
jline\.sourceforge\.net_license\.html
www\.antlr\.org_license\.html
www\.eclipse\.org_legal_epl-v10\.html
www\.json\.org_license\.html
www\.sun\.com_cddl_cddl\.html
cc.crt
cc.key
asterix_nc1.crt
asterix_nc1.key
asterix_nc2.crt
asterix_nc2.key
rootCA.crt
rootCA.key
passwd
EOF
        ;;
    hyracks-fullstack)
        cat << EOF
.*\.iml
.*\.txt
.*\.tbl
.*tpch.ddl
.*wordcount.tsv
.*scanMicroSortWrite.out
.*master
.*slaves
.*part-0
EOF
        ;;
    *)
        >&2 echo ERROR Unknown project $REPO_DIR
        exit 1
        ;;
    esac
}

rm $LOGFILE

checkArchives $ARCHIVENAME $SHA256

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
    echo git clone https://gitbox.apache.org/repos/asf/$REPO.git
    git clone https://gitbox.apache.org/repos/asf/$REPO.git >> $LOGFILE
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

