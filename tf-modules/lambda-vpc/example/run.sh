#!/bin/bash

if [ ! -d "./artifacts" ];
then
  mkdir artifacts
else
  if [ -f "./artifacts/app.zip" ] || [ -f "./artifacts/dependencies.zip" ];
  then
    rm ./artifacts/app.zip ./artifacts/dependencies.zip
  fi
fi

pushd "app"
rm -rf dist
npm run build
pushd "dist"
zip -r app.zip ./*
mv app.zip ../../artifacts/
popd
zip -r dependencies.zip node_modules/*
mv dependencies.zip ../artifacts/
