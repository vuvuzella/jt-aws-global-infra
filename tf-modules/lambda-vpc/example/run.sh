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
if [ ! -d "./nodejs" ];
then
  mkdir nodejs
fi
cp -r node_modules ./nodejs
zip -r dependencies.zip nodejs
mv dependencies.zip ../artifacts/
rm -rf ./nodejs
