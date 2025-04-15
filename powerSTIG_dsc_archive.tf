# Create a zip archive of the PowerSTIG DSC script and dependencies for use in the DSC extension

data "archive_file" "powerSTIG_dsc_archive" {
  type        = "zip"
  source_dir  = "scripts/PowerSTIG/${var.PowerSTIGScriptVersion}/Windows"
  output_path = "scripts/PowerSTIG/${var.PowerSTIGScriptVersion}/Windows.ps1.zip"
}
