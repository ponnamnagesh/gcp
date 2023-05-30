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








