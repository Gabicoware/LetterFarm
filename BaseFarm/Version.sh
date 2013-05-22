#!/bin/sh

#  Version.sh
#  LetterFarm
#
#  Created by Daniel Mueller on 10/5/12.
#

START_TIME=`expr 12 \* 12 \* 100 + 4 \* 100`

YEAR=`date +"%y"`
MONTH=`date +"%m"`
DAY=`date +"%d"`

CURRENT_TIME=`expr $YEAR \* 12 \* 100 + $MONTH \* 100 + $DAY`


BUILD_NUMBER=`expr $CURRENT_TIME - $START_TIME`

echo "Setting build number to : ${BUILD_NUMBER}"

VERSION="${YEAR}.${MONTH}"
#.${DAY}"

echo "Setting version to : ${VERSION}"

/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $BUILD_NUMBER" "${TARGET_BUILD_DIR}"/"${INFOPLIST_PATH}"
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $VERSION" "${TARGET_BUILD_DIR}"/"${INFOPLIST_PATH}"
