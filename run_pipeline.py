"""Example code for running a built pipeline."""

import google.cloud.aiplatform as aip
import os
from kfp.registry import RegistryClient

# Set pipeline parameters
region = "us-central1"
project = "ml-on-gcp-dev"
ops_project = "ml-on-gcp-ops"
model_bucket = "gcs-ml-on-gcp-dev-models"
staging_bucket = "gcs-ml-on-gcp-dev-pipelines-pipeline"
artifact_registry_url = os.environ.get(
    "_ARTIFACT_REGISTRY_CONTAINERS_URL",
    f"{region}-docker.pkg.dev/{ops_project}/pipeline-containers",
)
service_account = (
    "sa-vertex-pipeline@ml-on-gcp-dev.iam.gserviceaccount.com"
)
pipeline_name = "pipeline"
model_display_name = "classifier"

client = RegistryClient(
    host="https://us-central1-kfp.pkg.dev/ml-on-gcp-ops/pipeline-templates"
)
templatePackage = client.download_pipeline(
    package_name="pipeline", tag="latest"
)

# Create and run Vertex AI pipeline
aip.init(project=project, staging_bucket=staging_bucket, location=region)

display_name = pipeline_name
pipeline_root = "gs://{}/{}".format(staging_bucket, pipeline_name)

job = aip.PipelineJob(
    display_name=display_name,
    template_path=templatePackage,
    pipeline_root=pipeline_root,
    project=project,
    location=region,
    parameter_values={
        "project": project,
        "region": region,
        "endpoint_name": "endpoint",
        "bq_source": "bq://bigquery-public-data.ml_datasets.credit_card_default",
        "prediction_type": "classification",
        "dataset_name": "credit_card_default",
        "target_column": "default_payment_next_month",
        "column_specs": {
            "limit_balance": "numeric",
            "sex": "categorical",
            "education_level": "categorical",
            "marital_status": "categorical",
            "pay_0": "numeric",
            "pay_2": "numeric",
            "pay_3": "numeric",
            "pay_4": "numeric",
            "pay_5": "numeric",
            "pay_6": "numeric",
            "bill_amt_1": "numeric",
            "bill_amt_2": "numeric",
            "bill_amt_3": "numeric",
            "bill_amt_4": "numeric",
            "bill_amt_5": "numeric",
            "bill_amt_6": "numeric",
            "pay_amt_1": "numeric",
            "pay_amt_2": "numeric",
            "pay_amt_3": "numeric",
            "pay_amt_4": "numeric",
            "pay_amt_5": "numeric",
            "pay_amt_6": "numeric",
        }
    },
)

job.submit(service_account=service_account)
