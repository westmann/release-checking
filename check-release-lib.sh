#/bin/bash

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

function checkArchives() {
  ARCHIVENAME=$1
  MD5=$2
  SHA1=$3
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
}

