// 
resource "tls_private_key" "key_pair" {
  algorithm   = "RSA"
  rsa_bits    = "2048"
}

// Render all certs to disk
resource "null_resource" "render_certs" {
  # depends_on = ["aws_key_pair.key_pair"]
  triggers  = {
    // uuid of instance_keypair
    "uuid()" = "${tls_private_key.key_pair.id}",
  }

  // Create dir for certs
  provisioner "local-exec" { command = "mkdir -p config" }

  // Render cluster instance_keypair
  provisioner "local-exec" { command = "cat > config/${var.key_name}.key <<EOL\n${tls_private_key.key_pair.private_key_pem}\nEOL" }
  provisioner "local-exec" { command = "cat > config/${var.key_name}.pub <<EOL\n${tls_private_key.key_pair.public_key_pem}\nEOL" }
  provisioner "local-exec" { command = "cat > config/${var.key_name}.ssh <<EOL\n${tls_private_key.key_pair.public_key_openssh}\nEOL" }
  
  // Wait a few seconds
  provisioner "local-exec" { command = "echo waiting 5 seconds && sleep 5" }
  
  // Set permissions for key file
  provisioner "local-exec" { command = "chmod 600 config/${var.key_name}.key"}
  
  // Add generated key to local SSH daemon
  provisioner "local-exec" { command = "ssh-add config/${var.key_name}.key" }
}

// Output
output "key_pair_ssh_pubkey" {
  value = "${tls_private_key.key_pair.public_key_openssh}"
  sensitive = true
}
