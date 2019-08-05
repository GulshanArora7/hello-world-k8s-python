# hello-world-k8s-python

Travis-CI: [![Build Status](https://travis-ci.org/GulshanArora7/hello-world-k8s-python.svg?branch=master)](https://travis-ci.org/GulshanArora7/hello-world-k8s-python)

## Prerequisites

* A Locally running kubernetes cluster(MiniKube) or Running kubernetes cluster in your environment
* Basis kubernetes tools like kubectl (to interact with kubernetes cluster), helm(for deployment)
* A Terminal to run all the commands
* Access service endpoint through any browser

## Installation

* To install kubernetes with MiniKube
  * [Minikube](https://kubernetes.io/docs/setup/learning-environment/minikube/#installation)

* To Install Kubectl
  * [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

* To install Helm(Package Manager) & Tiller(Helm Server) for kubernetes cluster
  * [Helm](https://helm.sh/docs/install/)

> `Important Note:`
- > Please configure kubectl command to interact with correct kubernetes cluster using kubernetes-context
- > Get Current Context using below command
    - `kubectl config get-contexts`

Example Output:
```
$ kubectl config get-contexts
CURRENT   NAME                 CLUSTER                      AUTHINFO             NAMESPACE
*         docker-for-desktop   docker-for-desktop-cluster   docker-for-desktop
```


## Automated deployment of helloworld-python app

Clone this repository and follow anyone of the methods for deployment as listed below

* To deploy helloworld-python application using public image from garoradevops dockerhub
    ```
    $ cd hello-world-k8s-python
    $ sh helloworld_kubernetes.sh -a
    ```

* To Build your own Image and Push to your own container repository and deploy helloworld-python application on kubernetes
  ```
  $ cd hello-world-k8s-python
  $ sh helloworld_kubernetes.sh -r "docker-repository-name" -i "image-name" -t "tag-name" -u "login-username" -p  -e

  Please Enter repository login password:

  Note: Enter here your docker repository login password
  ```
  ```
  If you are using container registry rather then dockerhub then you need to create secrets using below command

  kubectl create secret docker-registry regcred --docker-server=<registery name> --docker-username=<username> --docker-password=<password> --docker-email=<email-address> -n <namespace>

  And add this block in your deployment.yaml in helm chart.

  imagePullSecrets:
  - name: regcred
  ```


### To cleanup helloworld-python application

```
$ sh cleanup_helloworld.sh
```

## Manual deployment of helloworld-python application

### First install Tiller (Helm Server)

```
$ kubectl create serviceaccount tiller -n kube-system
$ kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
$ helm init --service-account tiller --upgrade
```

### Install helloworld-python application using helm

```
$ kubectl create ns helloworld-python
$ cd hello-world-k8s-python
$ helm upgrade --install helloworld-python helloworld-python/ --namespace helloworld-python
```

## Access helloworld-python on web browser
http://localhost:9090


## Directory Structure

1. `helloworld-pyhton`: helm chart for helloworld-python application.
2. `Dockerfile`: Dockerfile to build your own image
3. `hello_world.py`: python hello world programme.
4. `cleanup_helloworld.sh`: script to delete helloworld-python helm chart and helloworld-python namespace from kubernetes.
5. `helloworld_kubernetes.sh`: Shell script for automate deployment of helloworld-python application.

## Reference Links
* [Docker](https://docs.docker.com/)
* [HELM](https://helm.sh/docs/install/)
* [Kubernetes](https://kubernetes.io/docs/home/)
* [Python Flask](http://flask.pocoo.org/docs/1.0/)
