#!/bin/bash
set -e -u -x
export GOPATH=$PWD/ops-repo
cd $GOPATH
/usr/local/bin/kops export kubecfg ${NAME}
kubectl patch deployment msvc1 -p "{\"spec\":{\"template\":{\"metadata\":{\"labels\":{\"date\":\"`date +'%s'`\"}}}}}" --namespace=kube-system
