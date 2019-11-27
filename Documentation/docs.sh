#!/bin/sh
cd ../Framework;
jazzy --min-acl public --module Atom;
rm -rf build;
cd docs;
cp -r * ../../Documentation
cd ..;
rm -rf docs;
