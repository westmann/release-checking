#/bin/bash

function get() {
    FILENAME=$1
    if [ -f "$FILENAME" ] 
    then
        echo "found $FILENAME"
    else
        echo "getting $REPO_URL/$FILENAME"
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
  SHA1=$2
  for SUFFIX in zip zip.asc zip.sha1
  do
      get $ARCHIVENAME.$SUFFIX
  done

  echo "--- SHA1 ---"
  echo $SHA1
  cat $ARCHIVENAME.zip.sha1
  echo
  cat $ARCHIVENAME.zip | shasum

  echo "--- signature ---"
  gpg --verify $ARCHIVENAME.zip.asc $ARCHIVENAME.zip
}

