#/bin/bash

# runs some checks on an asterixdb source release artifact

SCRIPTNAME=$(basename $0)
. $(dirname $0)/check-release-lib.sh
LOGFILE=$(pwd)/$SCRIPTNAME.log

BASENAME=apache-asterixdb-0.9.1
ARCHIVENAME=$BASENAME-source-release
SHA1=8fc212b478e1e3ef62865de233e509066dc3445d
GERRIT_CHANGE=refs/changes/60/1660/1
REPO=asterixdb
REPO_DIR=asterixdb

REPO_URL=https://dist.apache.org/repos/dist/dev/asterixdb

MVN_ARGS=-DskipTests

function rat() {
    DIRNAME=$1
    RATREPORT=$(pwd)/rat.report
    RATEXCLUDES=$(pwd)/rat.excludes
    cat > $RATEXCLUDES << EOF
.*\.adm
.*\.adm\.template
.*\.ast
.*\.cleaned
.*\.csv
.*\.dgen
.*\.json
.*\.plan
.*\.tbl
.*\.tbl\.big
.*\.tbl\.verylong\.big
.*\.txt
.*\.regexadm
.*\.regex
.*\.ignore
part-0000.*
master
slaves
jobads\.new
jobads\.old
sample_08_header\.csv.*
large_text
tpch\.ddl
overlapping\.data
foo\.eps
foo\.gpl
gantt\.py
vargantt1\.gpl
vargantt1\.plt
8\.dqgen
classad-with-temporals\.classads
customer\.scm
lineitem\.scm
nation\.scm
orders\.scm
part\.scm
partsupp\.scm
region\.scm
supplier\.scm
bootstrap-theme\.min\.css
bootstrap\.min\.css
glyphicons-halflings-regular\.svg
angular\.min\.js
bootstrap\.min\.js
jquery-1\.12\.4\.min\.js
jquery\.autosize-min\.js
jquery\.min\.js
rainbowvis\.js
policy\.properties
id_rsa
id_rsa\.pub
known_hosts
LockRequestFile
asm\.objectweb\.org_license\.html
glassfish\.dev\.java\.net_public_CDDL_GPL_1_1\.html
jline\.sourceforge\.net_license\.html
www\.antlr\.org_license\.html
www\.eclipse\.org_legal_epl-v10\.html
www\.json\.org_license\.html
www\.sun\.com_cddl_cddl\.html
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
mvn package $MVN_ARGS &> $LOGFILE
popd
tail $LOGFILE

