#!/bin/usr/env bash

bucket_name="gs://${PROJECT}-dummy-pipeline-staging"

gsutil mb -l $REGION -c standard -p $PROJECT $bucket_name
gcloud storage buckets add-iam-policy-binding $bucket_name --member="serviceAccount:${TF_SA}" --role="roles/storage.admin"
datetime=$(date +'%s')
pipeline_job="https://europe-west1-aiplatform.googleapis.com/v1/projects/${PROJECT}/locations/europe-west1/pipelineJobs?pipelineJobId=hello-world-${datetime}"

curl -X POST -H "Authorization: Bearer $(gcloud auth print-access-token)" -H "Content-Type: application/json" $pipeline_job -d '{
  "name": "dummy-pipeline",
  "displayName": "dummy-pipeline",
  "pipelineSpec": {
    "components": {
      "comp-echo": {
        "executorLabel": "exec-echo"
      }
    },
    "schemaVersion": "2.1.0",
    "root": {
      "dag": {
        "tasks": {
          "echo": {
            "taskInfo": {
              "name": "echo"
            },
            "cachingOptions": {
              "enableCache": true
            },
            "componentRef": {
              "name": "comp-echo"
            }
          }
        }
      }
    },
    "sdkVersion": "kfp-2.0.0-beta.4",
    "pipelineInfo": {
      "name": "dummy-pipeline"
    },
    "deploymentSpec": {
      "executors": {
        "exec-echo": {
          "container": {
            "image": "busybox:latest",
            "command": [
              "echo",
              "init Vertex AI custom code service agent"
            ]
          }
        }
      }
    }
  },
  "runtimeConfig": {
    "gcsOutputDirectory": "'$bucket_name'"
  },
  "serviceAccount": "'$TF_SA'"
}'

gcloud storage rm --recursive $bucket_name
