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
    error_message = "Invalid environment"
  }
}

variable "vnet" {
  default = ""
  type    = string
}

variable "vnet_address_space" {
  default = "10.1.0.0/23"
  type = string
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

variable "encryption_at_host_enabled" {
  default = false
  type    = bool
}

variable "enroll_in_intune" {
  default = true
  type    = bool
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
