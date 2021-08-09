#!/bin/bash

VERSION=0.1.0
GIT_HASH=$(git rev-parse --short HEAD)

echo "$VERSION-$GIT_HASH"
