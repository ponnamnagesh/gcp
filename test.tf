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







