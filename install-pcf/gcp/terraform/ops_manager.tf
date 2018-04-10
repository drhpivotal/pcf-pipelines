resource "google_compute_instance" "ops-manager" {
  name         = "${var.prefix}-ops-manager"
  depends_on   = ["google_compute_subnetwork.subnet-ops-manager"]
  machine_type = "n1-standard-2"
  zone         = "${var.gcp_zone_1}"

  tags = ["${var.prefix}-opsman", "allow-https"]

  boot_disk {
    initialize_params {
      image = "${var.pcf_opsman_image_name}"
      size  = 50
    }
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.subnet-ops-manager.name}"

    access_config {
      nat_ip = "${google_compute_address.opsman.address}"
    }
  }

  provisioner "remote exec" {
    inline = [
      "sudo add-apt-repository -y ppa:certbot/certbot",
      "sudo /usr/bin/apt-get -qy update",
      "sudo apt-get -qy install certbot",
      "sudo service nginx restart",
      "sudo certbot certonly --webroot --webroot-path=/usr/share/nginx/html -d opsman.c0drh.pcflabs.io --agree-tos -m foo@pivotal.io -n",
    ]
  }
}

resource "google_storage_bucket" "director" {
  name          = "${var.prefix}-director"
  location      = "${var.gcp_storage_bucket_location}"
  force_destroy = true
}
