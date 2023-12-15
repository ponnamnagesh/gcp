  filename = "new_${var.env == "prod" ? local_file.example.filename : var.env == "dev" ? "dev.txt" : var.env == "sbx" ? "sbx.txt" : "exercise.txt"}"


  filename = var.env == "prod" ? local_file.example.filename : var.env == "dev" ? "dev.txt" : var.env == "sbx" ? "sbx.txt" : "exercise.txt"

  filename = var.env == "prod" ? "new_excercise.txt" : var.env == "dev" ? "dev.txt" : var.env == "sbx" ? "sbx.txt" : "exercise.txt"

  value = substr(module.project_ref.data.alerting.notification_channel, index(module.project_ref.data.alerting.notification_channel, "/") + 1)
    
      value = element(split("/", module.project_ref.data.alerting.notification_channel), 1)
        
          value = regex("([0-9]+)$", module.project_ref.data.alerting.notification_channel)
            
              value = element(split("/", module.project_ref.data.alerting.notification_channel)[length(split("/", module.project_ref.data.alerting.notification_channel)) - 1], 1)
                
                  value = regex("[0-9]+$", element(split("/", module.project_ref.data.alerting.notification_channel), 3))
                    
                      value = number(regex("[0-9]+$", element(split("/", module.project_ref.data.alerting.notification_channel), 3)))
                        
                          value = can(number(regex("[0-9]+$", element(split("/", module.project_ref.data.alerting.notification_channel), 3))))
                            
                            locals {
  buckets_data = {
    for element in var.data_list :
    "${element.location}-${element.purpose}-${element.classification}" => element
  }
}

                              
                                  "${get(element, "location", "US")}-${element.purpose}-${element.classification}" => element
                              
                                  "${element.location != null ? element.location : "US"}-${element.purpose}-${element.classification}" => element
                              
                                  "${coalesce(element.location, "US")}-${element.purpose}-${element.classification}" => element
                              
                                  "${try(element.location, "US")}-${element.purpose}-${element.classification}" => element


locals {
  buckets_data = {
    for element in var.data_list :
    "${coalesce(element.location, "US")}-${element.purpose}-${element.classification}" => {
      purpose        = element.purpose
      location       = coalesce(element.location, "US")
      classification = element.classification
    }
  }
}

  locals {
  default_location = {
    location = "US"
  }

  buckets_data = {
    for element in var.data_list :
    "${element.purpose}-${element.classification}" => merge(element, local.default_location)
  }
}

    for_each = {
  for k, v in local.buckets_data :
  k => v
  if fileexists(v["file_path"])
}
    
    
    {
      location       = v.location
      purpose        = v.purpose
      classification = v.classification
      file_path      = v.file_path
    }
    
    
    variable "bucket_purposes" {
  type = map(string)
  default = {
    bucket1 = "purpose1"
    bucket2 = "purpose2"
    bucket3 = "purpose3"
    bucket4 = "purpose4"
    bucket5 = "purpose5"
    bucket6 = "purpose6"
    bucket7 = "purpose7"
    bucket8 = "purpose8"
    bucket9 = "purpose9"
    bucket10 = "purpose10"
  }
}

module "storage_buckets" {
  source = "./modules/storage_buckets"

  for_each = var.bucket_purposes

  bucket_name    = each.key
  bucket_purpose = each.value
}

Generally, we do not have an immediate solution to create Apache Airflow in dual regions.
Here, we can create environments in two regions.
Then, we have an Apache Airflow server in two regions.
In both regions, we should create DAGs, tasks, etc.
We should ensure that the Apache Airflow instance is running in only one region; in the other region, we should manually stop it.
Then, with the help of a cloud function, we start the second Airflow instance when the first Airflow instance is stopped or terminated.
To trigger the cloud function when the first Airflow instance is stopped, we should use some event-based trigger mechanism.
If I want to store anything from the first Airflow instance, we should store it in a GCS bucket.


create two Airflow environments in separate regions using Terraform. Each environment should have its own infrastructure resources, including a database.

Configure database replication between the environments. The specific steps may vary depending on the database technology you're using. Generally, you would set up replication by configuring replication settings on the primary database in one environment and configuring the secondary database in the other environment as a replica.

Ensure that the necessary network connectivity is established between the environments to allow database replication traffic.

Configure Airflow to use the appropriate database connection settings for each environment. This typically involves updating the Airflow configuration files (e.g., airflow.cfg) or using environment-specific configuration variables.

Deploy the Airflow instances in each environment using Terraform. Ensure that the Airflow deployments are set up to connect to their respective databases.

Test the replication by creating and executing DAGs in one environment and verifying that the changes are reflected in the other environment.

from airflow import DAG
from airflow.operators.python_operator import PythonOperator
from datetime import datetime

default_args = {
    'owner': 'airflow',
    'start_date': datetime(2023, 1, 1),
}

def list_installed_packages():
    import subprocess
    result = subprocess.run(['pip', 'list'], capture_output=True, text=True)
    return result.stdout

with DAG('list_packages_dag', schedule_interval=None, default_args=default_args) as dag:
    list_packages_task = PythonOperator(
        task_id='list_packages',
        python_callable=list_installed_packages
    )



from airflow import DAG
from airflow.operators.python_operator import PythonOperator
from datetime import datetime
import subprocess

default_args = {
    'owner': 'airflow',
    'start_date': datetime(2023, 1, 1),
}

def install_snowflake_connector():
    try:
        # Use pip to install Snowflake Connector version 3.1.0
        result = subprocess.run(['pip', 'install', 'snowflake-connector-python==3.1.0'], capture_output=True, text=True)
        return result.stdout
    except Exception as e:
        return str(e)

with DAG('install_snowflake_connector_dag', schedule_interval=None, default_args=default_args) as dag:
    install_task = PythonOperator(
        task_id='install_snowflake_connector',
        python_callable=install_snowflake_connector
    )
!/bin/bash

# Set your GCP service account key (authentication)
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/your/gcp-service-account-key.json

# Define Bitbucket repository URL and folder path
BITBUCKET_REPO_URL="https://bitbucket.org/username/repo.git"
BITBUCKET_FOLDER_PATH="path/to/folder/in/bitbucket"
BITBUCKET_BRANCH="master"  # Replace with the desired branch/tag/commit

# Define a temporary directory to store the exported tarball
TEMP_DIR="/tmp"

# Generate a unique tarball file name
TAR_FILE="$TEMP_DIR/bitbucket_folder_$(date +'%Y%m%d%H%M%S').tar.gz"

# Export the folder from Bitbucket as a tarball using 'git archive'
git archive --remote="$BITBUCKET_REPO_URL" --format=tar.gz "$BITBUCKET_BRANCH:$BITBUCKET_FOLDER_PATH" > "$TAR_FILE"

# Upload the exported tarball to GCS bucket
gsutil cp "$TAR_FILE" gs://your-gcs-bucket/

# Clean up the temporary tarball file
rm "$TAR_FILE"

curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-install.sh

Invoke-WebRequest -Uri "https://dl.google.com/dl/cloudsdk/channels/rapid/GoogleCloudSDKInstaller.exe" -OutFile "$env:USERPROFILE\Downloads\GoogleCloudSDKInstaller.exe"

wget https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-install.sh

chmod +x google-cloud-sdk-install.sh


#!/bin/bash

# Path to the bumpversion.cfg file
BUMPVERSION_FILE="path/to/bumpversion.cfg"

# Extract the release version
RELEASE_VERSION=$(grep "current_version" "$BUMPVERSION_FILE" | awk -F'=' '{print $2}' | tr -d '[:space:]')

echo "Release Version: $RELEASE_VERSION"


echo "##teamcity[setParameter name='env.RELEASE_VERSION' value='$RELEASE_VERSION']"

# Access the release version
echo "Release Version: $RELEASE_VERSION"



@echo off

REM Define the path to your bumpversion.cfg file
set BUMPVERSION_CFG="C:\path\to\bumpversion.cfg"

REM Extract the release version using findstr and for
for /f "tokens=2 delims==" %%i in ('findstr /C:"current_version" %BUMPVERSION_CFG%') do set RELEASE_VERSION=%%i

REM Print the release version
echo Latest Release Version: %RELEASE_VERSION%

bamboo_variable "RELEASE_VERSION" "${RELEASE_VERSION}"

flyway.cmd -url=jdbc:your_database_url -user=your_username -password=your_password -schemas=your_schema -locations=filesystem:path_to_sql_scripts migrate


flyway.url=jdbc:your_database_url
flyway.user=your_username
flyway.password=your_password
flyway.schemas=your_schema
flyway.locations=filesystem:path_to_sql_scripts

export FLYWAY_URL=jdbc:your_database_url
export FLYWAY_USER=your_username
export FLYWAY_PASSWORD=your_password
export FLYWAY_SCHEMAS=your_schema
export FLYWAY_LOCATIONS=filesystem:path_to_sql_scripts

flyway.cmd migrate

flyway.cmd migrate -configFile=flyway.conf


flyway migrate \
  -url=jdbc:your_database_url \
  -locations=filesystem:/path/to/scripts \
  -user=your_ssh_username \
  -keyPath=/path/to/private/key \
  -password=your_passphrase


