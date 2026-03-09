module.project_ref.data.environment_type == "prototype" ? [] : try([module.samda_dataproc_serverless[0].serverless_service_account.iam_principal], [])


  module.project_ref.data.environment_type == "prototype" ? [] : [module.samda_dataproc_serverless[0].serverless_service_account.iam_principal]
