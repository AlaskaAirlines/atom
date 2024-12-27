#!/bin/sh
cd ../Framework;
jazzy --min-acl public --module AtomNetworking;
rm -rf build;
cd docs;
cp -r * ../../Documentation
cd ..;
rm -rf docs;
