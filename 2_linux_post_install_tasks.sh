#!/bin/bash

# Enable minikube metrics server
minikube addons enable metrics-server

# Login to GCP
gcloud auth login --no-launch-browser

# Login to AWS
aws login
