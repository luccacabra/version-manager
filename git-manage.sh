#!/bin/bash
#=============================================
#
# FILE: git-manage.sh
#
# USAGE: git-manage.sh
#
# DESCRIPTION: Git-version managing for python projects. Tag current git branch, 
#              increment project version number, add and commit project, then push.
#
#=============================================

#If source directory isn't specified, assume current directory
if [ -z "${SRC_DIR}" ]; then
	SRC_DIR=$PWD
fi

if [ ! -d "$SRC_DIR/.git" ]; then
	echo "No git repo identified. Exiting"
	exit 1
fi

if [ ! -f "$SRC_DIR/setup.py" ]; then
	echo "No setup file found. Exiting"
	exit 1
fi

#Pull version number from setup.py
VERSION=`grep 'version=' $SRC_DIR/setup.py | awk -F\' '{print $2}'`

#Pull current tags
TAGS=`git tag`

for tag in ${TAGS}
do
	if [ "${tag}" = "${VERSION}" ]; then
		echo "Version has already been tagged and commited. Exiting."
		exit 0 #Counts as a successfull exit
	fi
done

#git tag $VERSION
git tag $VERSION

#Assumes version is in #.#...# format (i.e. 0.1 or 0.1.2)
LAST_CHAR=${VERSION#${VERSION%?}}
NEW_VERSION=`echo $VERSION | sed 's/[0-9]$/'"$((LAST_CHAR+1))"'/'` #increments version (0.1 -> 0.2)

sed -i -e "s/\(version=\).*/\1\'${NEW_VERSION}\',/" $SRC_DIR/setup.py

git add .
git commit -a -m "$VERSION"
git push origin master


