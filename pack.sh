#!/bin/sh -ex

mkdir -p artifacts

ARCHES="amd64 aarch64"
if [ "$DEVEL" = "false" ]; then
  ARCHES="$ARCHES legacy steamdeck rog-ally armv9"
fi

for arch in $ARCHES
do
  cp linux-$arch/*.AppImage "artifacts/Eden-Linux-${FORGEJO_REF}-${arch}.AppImage"
  if [ "$DEVEL" = "false" ]; then
    cp linux-$arch/*.AppImage.zsync "artifacts/Eden-Linux-${FORGEJO_REF}-${arch}.AppImage.zsync"
  fi
done

cp android/*.apk artifacts/Eden-Android-${FORGEJO_REF}.apk

for arch in amd64 # arm64
do
  cp windows-$arch/*.zip artifacts/Eden-Windows-${FORGEJO_REF}-${arch}.zip
done

if [ -d "source" ]; then
  for ext in zip tar.zst
  do
    cp source/source.$ext artifacts/Eden-Source-${FORGEJO_REF}.$ext
  done
fi
