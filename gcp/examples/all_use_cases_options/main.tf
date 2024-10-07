
# this is an example of how to use the module, you can customize it to your needs,


module "engodo" {
  #checkov:skip=CKV_TF_1
  #checkov:skip=CKV_TF_2
  source = "git::https://github.com/nosportugal/engodo.git?ref=vX.X.X" #choose your version here

  ### general configuration ###

  whitelist_service_accounts = ["someserviceaccount@iam.gserviceaccount.com"] # list of service accounts that should be whitelisted
  allowed_domains            = ["internaldomain.com"]                         #this is the global  value that is shared across all use cases, if you also specify a value in the use case config, it will override this value for that use case

  prefix = "engodo" # prefix added to all resources that do not belong to a specific use case




  ### use cases configuration ###

  uc1_config = {
    enable               = true #enable or disable the use case
    bucket_name          = "attractive-bucket-1337"
    enable_audit_logging = true #disabling this can cause some actions to not be logged
    allowed_domains      = ["internaldomain.com", "externaldomain.com"]
  }

  uc2_config = {
    enable               = true                 #enable or disable the use case
    role_title           = "Organization Admin" #name of the role
    role_description     = "Full access to all organization resources, including administrative tasks, financial data, and sensitive services. Be cautious with its usage."
    role_permissions     = ["storage.buckets.list"] #permissions assigned to the role
    sa_name              = "serviceacc custom name" #name of the service account
    enable_audit_logging = true                     #disabling this can cause some actions to not be logged
    allowed_domains      = ["internaldomain.com", "externaldomain.com"]
  }

  uc3_config = {
    enable               = true                                                   #enable or disable the use case
    secret_id            = "Github Organization Token"                            #name of the secret
    secret_content       = "this is a secret and no one should be able to see it" #content of the secret, if empty, a random content will be generated
    enable_audit_logging = true                                                   #disabling this can cause some actions to not be logged
  }


}


