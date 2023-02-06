import kfp
import argparse

from kfp.registry import RegistryClient
from kfp.v2 import compiler
from google_cloud_pipeline_components import aiplatform as gcc_aip

parser = argparse.ArgumentParser()
parser.add_argument(
    "--project",
    help="the project ID",
    type=str,
)
parser.add_argument(
    "--region",
    help="the region where the pipeline will be stored",
    type=str,
)
parser.add_argument(
    "--pipeline-name",
    help="the name of the pipeline",
    type=str,
    default="pipeline",
)
parser.add_argument(
    "--pipeline-file",
    help="the location to write the pipeline JSON to",
    type=str,
    default="pipeline.yaml",
)
parser.add_argument(
    "--artifact-registry-url",
    help="the Artifact Registry URL to save the pipeline template to",
    type=str,
)
parser.add_argument(
    "-t",
    "--tags",
    nargs="*",
    help="Extra tags to set on the image.",
    default=["latest"],
)
args = parser.parse_args()


@kfp.dsl.pipeline(name=args.pipeline_name)
def pipeline(
    project: str,
    region: str,
    endpoint_name: str,
    bq_source: str,
    dataset_name: str = "penguin",
):
    dataset_create_op = gcc_aip.TabularDatasetCreateOp(
        project=project,
        display_name=dataset_name,
        location=region,
        bq_source=bq_source,
    )

    training_op = gcc_aip.AutoMLTabularTrainingJobRunOp(
        project=project,
        display_name=args.pipeline_name,
        optimization_prediction_type="classification",
        column_specs={
            "species": "categorical",
            "island": "categorical",
            "culmen_length_mm": "numeric",
            "culmen_depth_mm": "numeric",
            "flipper_length_mm": "numeric",
            "body_mass_g": "numeric",
            "sex": "categorical",
        },
        dataset=dataset_create_op.outputs["dataset"],
        target_column="sex",
        location=region,
    )

    endpoint_op = gcc_aip.EndpointCreateOp(
        project=project,
        location=region,
        display_name=args.pipeline_name,
        endpoint_name=endpoint_name,
    )

    deploy_op = gcc_aip.ModelDeployOp(
        project=project,
        location=region,
        model=training_op.outputs["model"],
        endpoint=endpoint_op.outputs["endpoint"],
        dedicated_resources_machine_type="n1-standard-4",
        dedicated_resources_min_replica_count=1,
        dedicated_resources_max_replica_count=1,
        deployed_model_display_name=args.pipeline_name,
    )


compiler.Compiler().compile(
    pipeline_func=pipeline,
    package_path=args.pipeline_file,
)

client = RegistryClient(host=args.artifact_registry_url)
templateName, versionName = client.upload_pipeline(
    file_name=args.pipeline_file,
    tags=args.tags,
    extra_headers={"description": "Sample classification AutoML pipeline."},
)