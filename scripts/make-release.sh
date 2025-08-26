#! /bin/bash

VERSION=$1

if [ -z "$VERSION" ];
then
    echo "You need to specify a version number."
    exit 1
fi


RELEASE_DIR=release/preview/pergamon/$VERSION


# Put together release

rm -rf $RELEASE_DIR
mkdir -p $RELEASE_DIR

cp lib.typ $RELEASE_DIR/lib.typ
cp -r src $RELEASE_DIR
cp README.md $RELEASE_DIR/
cp LICENSE $RELEASE_DIR/

# replace version in typst.toml
sed -i '.bak' "s/^version = \".*\"/version = \"$VERSION\"/" typst.toml
# -i .bak is Mac-specific
cp typst.toml $RELEASE_DIR
# old: sed "s/VERSION/$VERSION/g" typst-template.toml > $RELEASE_DIR/typst.toml

echo "Package is ready for release in $RELEASE_DIR."

