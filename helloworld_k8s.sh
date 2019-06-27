#!/usr/bin/env bash

# Author: Gulshankumar Arora


if [ "$#" -lt "1" ]; then
  echo "Script Needs Arguments: Use $0 -h flag for more help"
  exit 1
fi

KUBECTL=$(which kubectl)
HELM=$(which helm)
DOCKER=$(which docker)

check_software_installation() {
  OUTPUT=0

  echo "Checking: Kubectl Installation"
  $KUBECTL version &> /dev/null
  if [[ "$?" != 0 ]];then
    echo "kubectl command does not found.. Please Install it..!!"
    echo "Installation Guide: https://kubernetes.io/docs/tasks/tools/install-kubectl/"
    OUTPUT=$(($OUTPUT+1))
  else
    echo "***  Kubectl exist on the machine  ***"
  fi

  echo "Checking: Helm Installation"
  $HELM version --client &> /dev/null
  if [[ "$?" != 0 ]];then
    echo "helm command does not found.. Please Install it..!!"
    echo "Installation Guide: https://helm.sh/docs/using_helm/"
    OUTPUT=$(($OUTPUT+1))
  else
    echo "***  Helm exist on the machine  ***"
  fi

  echo "Checking: Docker Installation"
  $DOCKER version &> /dev/null
  if [[ "$?" != 0 ]];then
    echo "docker command does not found.. Please Install it..!!"
    echo "Installation Guide: https://www.docker.com/get-started"
    OUTPUT=$(($OUTPUT+1))
  else
    echo "***  Docker exist on the machine  ***"
  fi

  if [[ $OUTPUT > 0 ]]; then
    echo "ERROR: Missing one or more requeriments..Please Check..Exiting.!!"
    exit 1
  else
    echo "All prerequisite software are already installed. Moving for deployment..!!"
  fi
}

initialize_helm() {
  export HELM_HOME=/tmp/local_helm
  if [ ! -d /tmp/local_helm ]; then
    mkdir -p local_helm
  fi

  echo "Checking: Tiller on Kubernetes"
  $HELM version --server &> /dev/null
  if [[ "$?" != 0 ]]; then
    echo "Tiller does not exist on Kubernetes..Installing tiller now..!!"
    $KUBECTL create serviceaccount tiller -n kube-system
    $KUBECTL create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
    $HELM init --service-account tiller --upgrade
  else
    echo "Tiller already exist on Kubernetes..Continue to Deploy..!!"
  fi
}

Kubernetes_deploy_public(){
  $KUBECTL get ns helloworld-python -o name > /dev/null 2>&1
  if [[ "$?" != 0 ]]; then
    echo "Deploying Hello-World Application on Kubernetes"
    $KUBECTL create ns helloworld-python && \
    $HELM upgrade --install helloworld-python helloworld-python/ --namespace helloworld-python
  else
    echo "Helloworld Helm already present on the Kubernetes"
  fi
}

Kubernetes_deploy_own(){
  docker build -t ${REGISTRY}/${IMAGENAME}:$TAG -f Dockerfile .
  docker login -u $USER -p $PASS $REGISTRY
  docker push ${REGISTRY}/${IMAGENAME}:$TAG
  echo "Image has been pushed successfully to dockerhub"
  $KUBECTL get ns helloworld-python -o name > /dev/null 2>&1
  if [[ "$?" != 0 ]]; then
    echo "Deploying Hello-World Application on Kubernetes"
    $KUBECTL create ns helloworld-python && \
    $HELM upgrade --install helloworld-python helloworld-python/ --set-string image.tag=$TAG --set-string image.repository=$REGISTRY/$IMAGENAME --namespace helloworld-python
  else
   echo "Helloworld Helm already present on the Kubernetes"
  fi
}

while getopts 'r:i:u:t:peha' opt; do
  case $opt in
    r) REGISTRY="$OPTARG" ;;
    i) IMAGENAME="$OPTARG" ;;
    u) USERNAME="$OPTARG"
      if [[ "$USERNAME" = "" ]]; then
        echo "Username cannot be left blank"
        exit 1
      fi
    ;;
    t) TAG="$OPTARG" ;;
    p)
      read -s -p "Please Enter repository login password: " password
      PASS=$password
        if [[ "$PASS" = "" ]]; then
          echo "Password cannot be left blank"
          exit 1
        fi
    ;;
    e) use_external="true" ;;
    h)
      printf "\e[1;31mTo Run this script with image available on garoradevops dockerhub\e[0m\n"
      printf "\e[1;34mExample: $0 -a \e[0m\n"
      printf "\e[1;31mTo Run this script with external(your own) docker registry\e[0m\n"
      printf "\e[1;34mExample: $0 -r <registry-name> -i \"image-name\" -t \"image-tag\" -u <registry-login-username> -p <registry-login-password> -e \e[0m\n"
      exit 0
    ;;
    a) use_external="false" ;;
    *) echo "Please choose a valid parameter, use -h flag for more help"
      exit 1 ;;
  esac
done

if [[ "$use_external" != "true" ]];
then
  echo "Running with public image from garoradevops/hellowworld-python."
  check_software_installation
  initialize_helm
  sleep 30s
  Kubernetes_deploy_public
else
  echo "\nRunning Script with own choosen docker registry $REGISTRY"
  check_software_installation
  initialize_helm
  sleep 30s
  Kubernetes_deploy_own
fi
