variable "spoke_subscription_id" {
  type = string
}

variable "location" {
  default = "canadacentral"
  type    = string
}

variable "telemetry_enabled" {
  default = false
  type    = bool
}

variable "powerstig_enabled" {
  default = false
  type    = bool
}

variable "org" {
  default = "contoso"
  type    = string
}

variable "unit" {
  default = "infra"
  type    = string
}

variable "env" {
  default = "demo"
  type    = string
  validation {
    condition     = contains(["prod", "prd", "stage", "stg", "devel", "dev", "test", "tst", "demo", "dem"], var.env)
    error_message = "Invalid environment, please use one of: prod, prd, stage, stg, devel, dev, test, tst, demo, or dem."
  }
}

variable "vnet" {
  default = ""
  type    = string
}

variable "vnet_rg" {
  default = ""
  type    = string
}

variable "snet" {
  default = ""
  type    = string
}

variable "rdsh_count" {
  default = 2
  type    = number
}

locals {
  # AVD restriction is 11 characters, but ours could be longer
  vm_name_prefix_max_length = 11
}

variable "vm_name_prefix" {
  default = "vm-avd-sh-"
  type    = string
  validation {
    condition     = length(var.vm_name_prefix) <= local.vm_name_prefix_max_length
    error_message = "The VM name prefix must be ${local.vm_name_prefix_max_length} characters or less."
  }
}

variable "session_host_admin_username" {
  default = "srvadmin"
  type    = string
}

variable "session_host_source_image_reference" {
  default = {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "office-365"
    sku       = "win11-24h2-avd-m365"
    version   = "latest"
  }
  type = map(string)
}

variable "session_host_sku_size" {
  default = "Standard_D2as_v5"
  type    = string
}

variable "encryption_at_host_enabled" {
  default = false
  type    = bool
}

variable "enroll_in_intune" {
  default = true
  type    = bool
}

variable "user_assignments" {
  default     = []
  type        = list(string)
  description = "The Entra ID object IDs of the users or groups that should be assigned to the Desktop Application Group. These identities will also be assigned the Virtual Machine User Login role on the session host resource group."
}

variable "admin_assignments" {
  default     = []
  type        = list(string)
  description = "The Entra ID object IDs of the users or groups that should be assigned the Virtual Machine Administrator role on the session host resource group. They will also be assigned to the Desktop Application Group."
}

variable "az_region_abbreviations" {
  type = map(string)
  default = {
    australiacentral   = "acl"
    australiacentral2  = "acl2"
    australiaeast      = "ae"
    australiasoutheast = "ase"
    brazilsouth        = "brs"
    brazilsoutheast    = "bse"
    brazilus           = "bru"
    canadacentral      = "cnc"
    canadaeast         = "cne"
    centralindia       = "inc"
    centralus          = "cus"
    centraluseuap      = "ccy"
    eastasia           = "ea"
    eastus             = "eus"
    eastus2            = "eus2"
    eastus2euap        = "ecy"
    eastusstg          = "eastusstg"
    francecentral      = "frc"
    francesouth        = "frs"
    germanynorth       = "gn"
    germanywestcentral = "gwc"
    israelcentral      = "ilc"
    italynorth         = "itn"
    japaneast          = "jpe"
    japanwest          = "jpw"
    jioindiacentral    = "jic"
    jioindiawest       = "jiw"
    koreacentral       = "krc"
    koreasouth         = "krs"
    mexicocentral      = "mxc"
    newzealandnorth    = "nzn"
    northcentralus     = "ncus"
    northeurope        = "ne"
    norwayeast         = "nwe"
    norwaywest         = "nww"
    polandcentral      = "plc"
    qatarcentral       = "qac"
    southafricanorth   = "san"
    southafricawest    = "saw"
    southcentralus     = "scus"
    southcentralusstg  = "southcentralusstg"
    southindia         = "ins"
    southeastasia      = "sea"
    spaincentral       = "esc"
    swedencentral      = "sdc"
    swedensouth        = "sds"
    switzerlandnorth   = "szn"
    switzerlandwest    = "szw"
    uaecentral         = "uac"
    uaenorth           = "uan"
    uksouth            = "uks"
    ukwest             = "ukw"
    westcentralus      = "wcus"
    westeurope         = "we"
    westindia          = "inw"
    westus             = "wus"
    westus2            = "wus2"
    westus3            = "wus3"
    chinaeast          = "sha"
    chinaeast2         = "sha2"
    chinanorth         = "bjb"
    chinanorth2        = "bjb2"
    chinanorth3        = "bjb3"
    germanycentral     = "gec"
    germanynortheast   = "gne"
    usdodcentral       = "udc"
    usdodeast          = "ude"
    usgovarizona       = "uga"
    usgoviowa          = "ugi"
    usgovtexas         = "ugt"
    usgovvirginia      = "ugv"
    usnateast          = "exe"
    usnatwest          = "exw"
    usseceast          = "rxe"
    ussecwest          = "rxw"
  }
}
