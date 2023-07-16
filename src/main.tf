#CONFIGURACION INICIAL  ---------------------------
# Configure the Microsoft Azure Provider
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
}
provider "azurerm" {
  features {}
}

# RECURSOS y COMPONENTES --------------------------
# Grupo de recursos
resource "azurerm_resource_group" "AV_parte_3" { #el segundo se puede cambiar -> nombre descriptivo
    name     = "AV_parte_3"
    location = "eastus"

    tags = {
        environment = "Terraform" # Etiquetas
    }
}

# Red virtual
resource "azurerm_virtual_network" "PracticaCloud_VirtualNetwork" {
    name                = "PracticaCloud_VirtualNetwork"
    address_space       = ["10.0.0.0/16"]
    location            = "eastus"
    resource_group_name = azurerm_resource_group.AV_parte_3.name #referencia la grupo de recursos

    tags = {
        environment = "Terraform"
    }
}

# Subred
#   app-subnet
resource "azurerm_subnet" "PracticaCloud_app-subnet" {
    name                 = "PracticaCloud_app-subnet"
    resource_group_name  = azurerm_resource_group.AV_parte_3.name
    virtual_network_name = azurerm_virtual_network.PracticaCloud_VirtualNetwork.name
    address_prefixes       = ["10.0.2.0/24"]
}
#   web-subnet
resource "azurerm_subnet" "PracticaCloud_web-subnet" {
    name                 = "PracticaCloud_web-subnet"
    resource_group_name  = azurerm_resource_group.AV_parte_3.name
    virtual_network_name = azurerm_virtual_network.PracticaCloud_VirtualNetwork.name
    address_prefixes       = ["10.0.4.0/24"]
}
#   backend-subnet
resource "azurerm_subnet" "PracticaCloud_backend-subnet" {
    name                 = "PracticaCloud_backend-subnet"
    resource_group_name  = azurerm_resource_group.AV_parte_3.name
    virtual_network_name = azurerm_virtual_network.PracticaCloud_VirtualNetwork.name
    address_prefixes       = ["10.0.6.0/24"]
}
#   pasarela-subnet
resource "azurerm_subnet" "PracticaCloud_pasarela-subnet" {
    name                 = "PracticaCloud_pasarela-subnet"
    resource_group_name  = azurerm_resource_group.AV_parte_3.name
    virtual_network_name = azurerm_virtual_network.PracticaCloud_VirtualNetwork.name
    address_prefixes       = ["10.0.8.0/24"]
}

# Ip publica
resource "azurerm_public_ip" "PracticaCloud_app-public-ip" {
    name                         = "PracticaCloud_app-public-ip"
    location                     = "eastus"
    resource_group_name          = azurerm_resource_group.AV_parte_3.name
    allocation_method            = "Dynamic"

    tags = {
        environment = "Terraform"
    }
}
resource "azurerm_public_ip" "PracticaCloud_web-public-ip" {
    name                         = "PracticaCloud_web-public-ip"
    location                     = "eastus"
    resource_group_name          = azurerm_resource_group.AV_parte_3.name
    allocation_method            = "Dynamic"

    tags = {
        environment = "Terraform"
    }
}
resource "azurerm_public_ip" "PracticaCloud_pasarela-public-ip" {
    name                         = "PracticaCloud_pasarela-public-ip"
    location                     = "eastus"
    resource_group_name          = azurerm_resource_group.AV_parte_3.name
    allocation_method            = "Dynamic"

    tags = {
        environment = "Terraform"
    }
}

# Grupo de seguridad
resource "azurerm_network_security_group" "PracticaCloud_app-nsg" {
    count               = 2  #-----
    #name                = "PracticaCloud_app-nsg"
    name                = "PracticaCloud_app-nsg${count.index}" #----
    location            = "eastus"
    resource_group_name = azurerm_resource_group.AV_parte_3.name

    security_rule {
        name                       = "HTTP"
        priority                   = 1010
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "10.0.2.0/24"
    }

    security_rule {
        name                       = "SSH_pasarela"
        priority                   = 1020
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "10.0.8.0/24"
        destination_address_prefix = "10.0.2.0/24"
    }

    security_rule {
        name                       = "SSH_deny"
        priority                   = 1030
        direction                  = "Inbound"
        access                     = "Deny"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "10.0.2.0/24"
    }


    tags = {
        environment = "Terraform"
    }
}
resource "azurerm_network_security_group" "PracticaCloud_web-nsg" {
    name                = "PracticaCloud_web-nsg"
    location            = "eastus"
    resource_group_name = azurerm_resource_group.AV_parte_3.name

    security_rule {
        name                       = "HTTP"
        priority                   = 1010
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "10.0.4.0/24"
    }

    security_rule {
        name                       = "SSH"
        priority                   = 1020
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "10.0.8.0/24"
        destination_address_prefix = "10.0.4.0/24"
    }


    security_rule {
        name                       = "SSH_deny"
        priority                   = 1030
        direction                  = "Inbound"
        access                     = "Deny"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "10.0.4.0/24"
    }

    tags = {
        environment = "Terraform"
    }
}
resource "azurerm_network_security_group" "PracticaCloud_backend-nsg" {
    name                = "PracticaCloud_backend-nsg"
    location            = "eastus"
    resource_group_name = azurerm_resource_group.AV_parte_3.name

    security_rule {
        name                       = "DB-app"
        priority                   = 1010
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "1530"
        source_address_prefix      = "10.0.2.0/24"
        destination_address_prefix = "10.0.6.0/24"
    }

    security_rule {
        name                       = "DB-web"
        priority                   = 1020
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "1530"
        source_address_prefix      = "10.0.4.0/24"
        destination_address_prefix = "10.0.6.0/24"
    }

    security_rule {
        name                       = "SSH"
        priority                   = 1030
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "10.0.8.0/24"
        destination_address_prefix = "10.0.6.0/24"
    }


    security_rule {
        name                       = "SSH_deny"
        priority                   = 1040
        direction                  = "Inbound"
        access                     = "Deny"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "10.0.6.0/24"
    }


    security_rule {
        name                       = "DB_deny"
        priority                   = 1050
        direction                  = "Inbound"
        access                     = "Deny"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "1530"
        source_address_prefix      = "*"
        destination_address_prefix = "10.0.6.0/24"
    }

    tags = {
        environment = "Terraform"
    }
}

resource "azurerm_network_security_group" "PracticaCloud_pasarela-nsg" {
    name                = "PracticaCloud_pasarela-nsg"
    location            = "eastus"
    resource_group_name = azurerm_resource_group.AV_parte_3.name

    security_rule {
        name                       = "SSH"
        priority                   = 1010
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "10.0.8.0/24"
    }

    tags = {
        environment = "Terraform"
    }
}

# Interfaz de red
resource "azurerm_network_interface" "PracticaCloud_app-nt" {
    count                     = 2
    name                      = "PracticaCloud_app${count.index}_nt"
    location                  = "eastus"
    resource_group_name       = azurerm_resource_group.AV_parte_3.name

    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = azurerm_subnet.PracticaCloud_app-subnet.id
        private_ip_address_allocation = "Dynamic"
        #public_ip_address_id          = azurerm_public_ip.PracticaCloud_app-public-ip.id #SOLO PARTE 1 y 2
    }

    tags = {
        environment = "Terraform"
    }
}
resource "azurerm_network_interface" "PracticaCloud_web-nt" {
    name                      = "PracticaCloud_web-nt"
    location                  = "eastus"
    resource_group_name       = azurerm_resource_group.AV_parte_3.name

    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = azurerm_subnet.PracticaCloud_web-subnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.PracticaCloud_web-public-ip.id
    }

    tags = {
        environment = "Terraform"
    }
}
resource "azurerm_network_interface" "PracticaCloud_backend-nt" {
    name                      = "PracticaCloud_backend-nt"
    location                  = "eastus"
    resource_group_name       = azurerm_resource_group.AV_parte_3.name

    ip_configuration {
        name                          = "ip-backend-fija"
        subnet_id                     = azurerm_subnet.PracticaCloud_backend-subnet.id
        private_ip_address_allocation = "static"
        private_ip_address            = "${cidrhost("10.0.6.4/24", 4)}"
        #public_ip_address_id          = azurerm_public_ip.PracticaCloud_backend-public-ip.id 
    }

    tags = {
        environment = "Terraform"
    }
}
resource "azurerm_network_interface" "PracticaCloud_pasarela-nt" {
    name                      = "PracticaCloud_pasarela-nt"
    location                  = "eastus"
    resource_group_name       = azurerm_resource_group.AV_parte_3.name

    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = azurerm_subnet.PracticaCloud_pasarela-subnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.PracticaCloud_pasarela-public-ip.id 
    }

    tags = {
        environment = "Terraform"
    }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "app" {
    #network_interface_id      = azurerm_network_interface.PracticaCloud_app-nt.id #SOLO parte 1 y 2
    count                     = 2
    network_interface_id      = element(azurerm_network_interface.PracticaCloud_app-nt.*.id, count.index)
    #network_security_group_id = azurerm_network_security_group.PracticaCloud_app-nsg.id
    network_security_group_id = element(azurerm_network_security_group.PracticaCloud_app-nsg.*.id, count.index)
}
resource "azurerm_network_interface_security_group_association" "web" {
    network_interface_id      = azurerm_network_interface.PracticaCloud_web-nt.id
    network_security_group_id = azurerm_network_security_group.PracticaCloud_web-nsg.id
}
resource "azurerm_network_interface_security_group_association" "backend" {
    network_interface_id      = azurerm_network_interface.PracticaCloud_backend-nt.id
    network_security_group_id = azurerm_network_security_group.PracticaCloud_backend-nsg.id
}
resource "azurerm_network_interface_security_group_association" "pasarela" {
    network_interface_id      = azurerm_network_interface.PracticaCloud_pasarela-nt.id
    network_security_group_id = azurerm_network_security_group.PracticaCloud_pasarela-nsg.id
}

# Balanceador de carga
resource "azurerm_lb" "app-nbl" {
    name                = "app-nbl"
    location            = azurerm_resource_group.AV_parte_3.location
    resource_group_name = azurerm_resource_group.AV_parte_3.name

    frontend_ip_configuration {
        name                 = "publicIPAddress"
        public_ip_address_id = azurerm_public_ip.PracticaCloud_app-public-ip.id
    }
}
resource "azurerm_lb_backend_address_pool" "backend-pool" {
    #resource_group_name = azurerm_resource_group.AV_parte_3.name
    loadbalancer_id     = azurerm_lb.app-nbl.id
    name                = "BackEndAddressPool"
}
resource "azurerm_network_interface_backend_address_pool_association" "example" {
    count                   = 2
    #network_interface_id    = element(azurerm_network_interface.PracticaCloud_app-nt.*.id, count.index) #sin element
    network_interface_id    = azurerm_network_interface.PracticaCloud_app-nt.*.id[count.index]
    #network_interface_id    = azurerm_network_interface.PracticaCloud_app-nt.id
    ip_configuration_name   = "myNicConfiguration"
    backend_address_pool_id = azurerm_lb_backend_address_pool.backend-pool.id
}
#resource "azurerm_lb_backend_address_pool_address" "backend-pool-1" {
#    name                    = "backend-pool-1"
#    backend_address_pool_id = azurerm_lb_backend_address_pool.backend-pool.id
#    virtual_network_id      = azurerm_virtual_network.PracticaCloud_VirtualNetwork.id
#    ip_address              = "10.0.2.5"
#}
#resource "azurerm_lb_backend_address_pool_address" "backend-pool-2" {
#    name                    = "backend-pool-2"
#    backend_address_pool_id = azurerm_lb_backend_address_pool.backend-pool.id
#    virtual_network_id      = azurerm_virtual_network.PracticaCloud_VirtualNetwork.id
#    ip_address              = "10.0.2.4"
#}
resource "azurerm_lb_probe" "lb-probe" {
    resource_group_name = azurerm_resource_group.AV_parte_3.name
    loadbalancer_id     = azurerm_lb.app-nbl.id
    name                = "classiclb"
    port                = 80
    interval_in_seconds = 10
    number_of_probes    = 3
    protocol            = "Http"
    request_path        = "/"
}
resource "azurerm_lb_rule" "example" {
    resource_group_name            = azurerm_resource_group.AV_parte_3.name
    loadbalancer_id                = azurerm_lb.app-nbl.id
    name                           = "classiclb"
    protocol                       = "Tcp"
    frontend_port                  = 80
    backend_port                   = 80
    frontend_ip_configuration_name = "publicIPAddress"
    backend_address_pool_id        = azurerm_lb_backend_address_pool.backend-pool.id
    probe_id                       = azurerm_lb_probe.lb-probe.id
}
#NOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO
#resource "azurerm_lb_nat_rule" "example" {
#    resource_group_name            = azurerm_resource_group.AV_parte_3.name
#    loadbalancer_id                = azurerm_lb.app-nbl.id
#    name                           = "HTTPAccess"
#    protocol                       = "Tcp"
#    frontend_port                  = 80
#    backend_port                   = 80
#    frontend_ip_configuration_name = "publicIPAddress"
#}
#Cluster 2 servidores
#resource "azurerm_managed_disk" "test" {
#    count                = 2
#    name                 = "datadisk_existing_${count.index}"
#    location             = azurerm_resource_group.AV_parte_3.location
#    resource_group_name  = azurerm_resource_group.AV_parte_3.name
#    storage_account_type = "Standard_LRS"
#    create_option        = "Empty"
#    disk_size_gb         = "1023"
#}

resource "azurerm_availability_set" "avset" {
    name                         = "avset"
    location                     = azurerm_resource_group.AV_parte_3.location
    resource_group_name          = azurerm_resource_group.AV_parte_3.name
    platform_fault_domain_count  = 2
    platform_update_domain_count = 2
    managed                      = true
}


# Numero para disco
resource "random_id" "randomId_app" {
    keepers = {
        # generar numero aleatorio
        resource_group = azurerm_resource_group.AV_parte_3.name
    }

    byte_length = 8
}
resource "random_id" "randomId_web" {
    keepers = {
        # generar numero aleatorio
        resource_group = azurerm_resource_group.AV_parte_3.name
    }

    byte_length = 8
}
resource "random_id" "randomId_backend" {
    keepers = {
        # generar numero aleatorio
        resource_group = azurerm_resource_group.AV_parte_3.name
    }

    byte_length = 8
}
resource "random_id" "randomId_pasarela" {
    keepers = {
        # generar numero aleatorio
        resource_group = azurerm_resource_group.AV_parte_3.name
    }

    byte_length = 8
}

# Disco
resource "azurerm_storage_account" "mystorageaccount_app" {
    name                        = "diag${random_id.randomId_app.hex}"
    resource_group_name         = azurerm_resource_group.AV_parte_3.name
    location                    = "eastus"
    account_tier                = "Standard"
    account_replication_type    = "LRS"

    tags = {
        environment = "Terraform"
    }
}
resource "azurerm_storage_account" "mystorageaccount_web" {
    name                        = "diag${random_id.randomId_web.hex}"
    resource_group_name         = azurerm_resource_group.AV_parte_3.name
    location                    = "eastus"
    account_tier                = "Standard"
    account_replication_type    = "LRS"

    tags = {
        environment = "Terraform"
    }
}
resource "azurerm_storage_account" "mystorageaccount_backend" {
    name                        = "diag${random_id.randomId_backend.hex}"
    resource_group_name         = azurerm_resource_group.AV_parte_3.name
    location                    = "eastus"
    account_tier                = "Standard"
    account_replication_type    = "LRS"

    tags = {
        environment = "Terraform"
    }
}
resource "azurerm_storage_account" "mystorageaccount_pasarela" {
    name                        = "diag${random_id.randomId_pasarela.hex}"
    resource_group_name         = azurerm_resource_group.AV_parte_3.name
    location                    = "eastus"
    account_tier                = "Standard"
    account_replication_type    = "LRS"

    tags = {
        environment = "Terraform"
    }
}

# Automatizacion
data "template_file" "DB_init" {
  template = file("DB-init.sh")
}
data "template_file" "nginx-vm-cloud-init" {
  template = file("install-nginx.sh")
}

# MAQUINA VIRTUAL ----------------------
# MV-app
resource "azurerm_linux_virtual_machine" "app-mv" {
    count                 = 2
    #name                  = "PracticaCloud_app-mv" #nombre en Azure # SOLO PARTE 1 y 2
    name                  = "PracticaCloud-app-mv${count.index}"
    location              = "eastus"
    availability_set_id   = azurerm_availability_set.avset.id
    resource_group_name   = azurerm_resource_group.AV_parte_3.name
    network_interface_ids = [element(azurerm_network_interface.PracticaCloud_app-nt.*.id, count.index)]
    #network_interface_ids = [azurerm_network_interface.PracticaCloud_app-nt.id] #SOLO PARTE 1 y 2
    size               = "Standard_DS1_v2"
    #size                  = "Standard_B1ls" #disco mas barato #SOLO PARTE 1 y 2

    os_disk {
        name              = "myosdisk_app${count.index}"
        caching           = "ReadWrite"
        storage_account_type = "Premium_LRS" #HDD cambiar: Standard_HDD
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    computer_name  = "PracticaCloud-app-mv${count.index}" #nombre en linux
    admin_username = "Asier" 
    admin_password = "Asier201"
    #disable_password_authentication = true #dejamos ssh activado 
    disable_password_authentication = false
    custom_data = base64encode(data.template_file.nginx-vm-cloud-init.rendered)

    boot_diagnostics {
        storage_account_uri = azurerm_storage_account.mystorageaccount_app.primary_blob_endpoint
    }

    tags = {
        environment = "Terraform"
    }
}

# MV-web
resource "azurerm_linux_virtual_machine" "web-mv" {
    name                  = "PracticaCloud_web-mv" #nombre en Azure
    location              = "eastus"
    resource_group_name   = azurerm_resource_group.AV_parte_3.name
    network_interface_ids = [azurerm_network_interface.PracticaCloud_web-nt.id]
    #size                  = "Standard_B1ls" #disco mas barato
    size                  = "Standard_B1ls"

    os_disk {
        name              = "myOsDisk_web"
        caching           = "ReadWrite"
        storage_account_type = "Premium_LRS" #HDD cambiar: Standard_HDD
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    computer_name  = "PracticaCloud-web-mv" #nombre en linux
    admin_username = "Asier" 
    admin_password = "Asier201"
    #disable_password_authentication = true #dejamos ssh activado 
    disable_password_authentication = false
    custom_data = base64encode(data.template_file.nginx-vm-cloud-init.rendered)

    boot_diagnostics {
        storage_account_uri = azurerm_storage_account.mystorageaccount_web.primary_blob_endpoint
    }

    tags = {
        environment = "Terraform"
    }
}

# MV-backend
resource "azurerm_linux_virtual_machine" "backend-mv" {
    name                  = "PracticaCloud_backend-mv" #nombre en Azure
    location              = "eastus"
    resource_group_name   = azurerm_resource_group.AV_parte_3.name
    network_interface_ids = [azurerm_network_interface.PracticaCloud_backend-nt.id]
    size                  = "Standard_B1ls" #disco mas barato

    os_disk {
        name              = "myOsDisk_backend"
        caching           = "ReadWrite"
        storage_account_type = "Premium_LRS" #HDD cambiar: Standard_HDD
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    computer_name  = "PracticaCloud-backend-mv" #nombre en linux
    admin_username = "Asier" 
    admin_password = "Asier201"
    #disable_password_authentication = true #dejamos ssh activado 
    disable_password_authentication = false
    custom_data = base64encode(data.template_file.DB_init.rendered)

    boot_diagnostics {
        storage_account_uri = azurerm_storage_account.mystorageaccount_backend.primary_blob_endpoint
    }

    tags = {
        environment = "Terraform"
    }
}

# MV-pasarela
resource "azurerm_linux_virtual_machine" "app-pasarela" {
    name                  = "PracticaCloud_pasarela-mv" #nombre en Azure
    location              = "eastus"
    resource_group_name   = azurerm_resource_group.AV_parte_3.name
    network_interface_ids = [azurerm_network_interface.PracticaCloud_pasarela-nt.id]
    size                  = "Standard_B1ls" #disco mas barato

    os_disk {
        name              = "myOsDisk_pasarela"
        caching           = "ReadWrite"
        storage_account_type = "Premium_LRS" #HDD cambiar: Standard_HDD
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    computer_name  = "PracticaCloud-pasarela-mv" #nombre en linux
    admin_username = "Asier" 
    admin_password = "Asier201"
    #disable_password_authentication = true #dejamos ssh activado 
    disable_password_authentication = false

    boot_diagnostics {
        storage_account_uri = azurerm_storage_account.mystorageaccount_pasarela.primary_blob_endpoint
    }

    tags = {
        environment = "Terraform"
    }
}#BIEN
