#############################################################################
prefix = "ansible-automation"
location = ["East US", "East US 2", "Central India", "Central US"]

env = ["dev", "stage", "prod"]

##################################### Parameters to create Azure VM #######################################

vm_count = 3
vm_size = ["Standard_B2s", "Standard_B2ms", "Standard_B4ms", "Standard_DS1_v2"]
disk_size_gb = 70
extra_disk_size_gb = 50
computer_name = "VM"
admin_username = "ritesh"
admin_password = "Password@#795"
static_dynamic = ["Static", "Dynamic"]
availability_zone = [1] ### Provide the Availability Zones into which the VM to be created.

############################ Create the Azure Application Gateway #################################

ssl_certificate_password = "Dexter@123"

############################ Create PostgreSQL Flexible Servers ###################################

psql_server_admin_username = "postgres"
