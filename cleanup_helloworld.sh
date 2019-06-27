#!/usr/bin/env bash

KUBECTL=$(which kubectl)
HELM=$(which helm)

$HELM delete --purge helloworld-python

$KUBECTL delete ns helloworld-python
