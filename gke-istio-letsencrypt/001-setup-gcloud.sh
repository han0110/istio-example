#!/bin/bash

source .env

gcloud config set project $PROJECT_ID

gcloud config set compute/region $REGION
gcloud config set compute/zone $ZONE

gcloud services enable container.googleapis.com
gcloud services enable dns.googleapis.com
