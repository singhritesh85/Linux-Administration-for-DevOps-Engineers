################## Parameters for GCP to be used for the Project ######################

project_name = "XXXX-XXXXXXX-2XXXX6"  ### Provide the GCP Account Project ID. 

gcp_region = ["us-east1", "us-central1", "asia-south2", "asia-south1", "us-west1"]

prefix = "oscap"

ip_range_subnet = "192.168.0.0/24"

ip_public_range_subnet = "172.20.0.0/24"

ip_proxy_range_subnet = "172.20.1.0/24"

machine_type = ["n1-standard-1", "e2-small", "e2-medium", "n2-standard-4", "c2-standard-4", "c3-standard-4"]

env = [ "dev", "stage", "prod" ]
