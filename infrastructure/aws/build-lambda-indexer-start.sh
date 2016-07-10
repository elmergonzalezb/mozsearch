#!/bin/bash

# Usage: build-lambda-indexer-start.sh <config-repo> [release|dev]

set -e # Errors are fatal
set -x # Show commands

if [ $# != 2 ]
then
    echo "usage: $0 <config-repo> <channel>"
    exit 1
fi

CONFIG_REPO=$1
CHANNEL=$2

SCRIPT_PATH=$(readlink -f "$0")
MOZSEARCH_ROOT=$(dirname "$SCRIPT_PATH")/../..

mkdir /tmp/lambda
cp $MOZSEARCH_ROOT/infrastructure/aws/trigger_indexer.py /tmp/lambda

cat >/tmp/lambda/lambda-indexer-start.py <<EOF
#!/usr/bin/env python

import boto3
import trigger_indexer

def start(event, context):
    trigger_indexer.trigger("$CONFIG_REPO", "$CHANNEL", False)
EOF

pushd /tmp/lambda
virtualenv env
env/bin/pip install boto3
cp -r env/lib/python2.7/site-packages/* .
rm -rf env

rm -rf /tmp/lambda.zip
zip -r /tmp/lambda.zip *

popd
rm -rf /tmp/lambda

echo "Upload /tmp/lambda.zip to AWS Lambda"
