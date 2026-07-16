# Automates what doc Section 5 (SSH/SFTP) and Section 7.2 (running
# setup_vm.sh) did by hand in the original deployment. Terraform connects
# over SSH using the same credentials, copies the app folder, and runs the
# same setup script.

# Give the VM time to finish booting and start sshd before we try to connect.
# Azure VMs can report "creation complete" 1-3 minutes before SSH is actually
# reachable, and the "triggers" block alone does NOT create a real ordering
# dependency in Terraform's graph - only depends_on does that.
resource "time_sleep" "wait_for_vm_boot" {
  create_duration = "90s"

  triggers = {
    vm_id     = var.vm_id
    nic_assoc = var.nic_association_id
  }
}

resource "null_resource" "deploy_app" {
  triggers = {
    vm_id       = var.vm_id
    nic_assoc   = var.nic_association_id
    app_py_hash = filemd5("${var.app_files_path}/app.py")
    db_py_hash  = filemd5("${var.app_files_path}/database.py")
    setup_hash  = filemd5("${var.app_files_path}/setup_vm.sh")
  }

  # This is what actually forces correct ordering: wait for the VM to boot
  # AND for the NSG-to-NIC association to exist before attempting SSH.
  depends_on = [time_sleep.wait_for_vm_boot]

  connection {
    type     = "ssh"
    host     = var.vm_public_ip
    user     = var.vm_admin_username
    password = var.vm_admin_password
    timeout  = "5m"
  }

  # Step 1: make sure the target directory exists
  provisioner "remote-exec" {
    inline = [
      "mkdir -p /home/${var.vm_admin_username}/real_estate_flask"
    ]
  }

  # Step 2: copy the whole app_files folder onto the VM
  # (replaces the manual MobaXterm SFTP drag-and-drop from doc Section 5.3)
  provisioner "file" {
    source      = "${var.app_files_path}/"
    destination = "/home/${var.vm_admin_username}/real_estate_flask"
  }

  # Step 3: prep the VM (doc Section 6) and run setup_vm.sh (doc Section 7.2)
  provisioner "remote-exec" {
    inline = [
      "export DEBIAN_FRONTEND=noninteractive",
      "sudo apt-get update",
      "sudo DEBIAN_FRONTEND=noninteractive apt-get install -y python3 python3-pip python3-venv nginx mysql-client",
      "cd /home/${var.vm_admin_username}/real_estate_flask",
      "chmod +x setup_vm.sh",
      "DB_HOST='${var.mysql_fqdn}' DB_USER='${var.mysql_admin_username}' DB_PASS='${var.mysql_admin_password}' DB_NAME='${var.mysql_database_name}' bash setup_vm.sh"
    ]
  }
}

# One-time DB seeding (replaces doc Section 7.3: `python index.py`)
resource "null_resource" "seed_database" {
  triggers = {
    deploy_id = null_resource.deploy_app.id
  }

  connection {
    type     = "ssh"
    host     = var.vm_public_ip
    user     = var.vm_admin_username
    password = var.vm_admin_password
    timeout  = "5m"
  }

  provisioner "remote-exec" {
    inline = [
      "cd /home/${var.vm_admin_username}/real_estate_flask",
      "pwd",
      "ls -la",
      "ls -la venv/bin",
      "./venv/bin/python --version",
      "DB_HOST='${var.mysql_fqdn}' DB_USER='${var.mysql_admin_username}' DB_PASS='${var.mysql_admin_password}' DB_NAME='${var.mysql_database_name}' ./venv/bin/python index.py"
    ]
  }

  depends_on = [null_resource.deploy_app]
}
