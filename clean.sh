#!/bin/bash

#Some cleanups before pushing the source

rm -rf $(pwd)/output
rm -rf $(pwd)/hK-out
make clean
make mrproper
echo "Done!"



