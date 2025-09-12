#! /bin/bash

# Creates a new fork of the typst/packages repository on Github
# and copies the package release into it. This script does all the work
# in publishing a package to the Typst Universe, except for the actual
# pull request, which you will still have to do on Github.
#
# The script assumes that you have previously executed make-release.sh.
#
# Usage: ./scripts/create-github.sh <VERSION>

PACKAGE=pergamon
VERSION=$1

if [ -z "$VERSION" ];
then
    echo "You need to specify a version number."
    exit 1
fi


RELEASE_DIR=release/preview/$PACKAGE/$VERSION


# create fork
FORKNAME=typst-packages-$PACKAGE-$VERSION
WORKDIR=`pwd`

cd /tmp
rm -rf $FORKNAME
gh repo fork https://github.com/typst/packages --clone --fork-name $FORKNAME
cd $FORKNAME

# copy stuff from release to fork
mkdir -p packages/preview/$PACKAGE
cp -r $WORKDIR/$RELEASE_DIR packages/preview/$PACKAGE/

# send to Github
git add packages/preview/$PACKAGE/$VERSION
git commit -am "$PACKAGE:$VERSION"
git push

