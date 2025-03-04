# [START privateca_create_certificate_csr]
resource "google_privateca_certificate_authority" "test-ca" {
  pool = ""
  certificate_authority_id = "my-certificate-authority"
  location = "us-central1"
  config {
    subject_config {
      subject {
        organization = "HashiCorp"
        common_name = "my-certificate-authority"
      }
      subject_alt_name {
        dns_names = ["hashicorp.com"]
      }
    }
    x509_config {
      ca_options {
        # is_ca *MUST* be true for certificate authorities
        is_ca = true
      }
      key_usage {
        base_key_usage {
          # cert_sign and crl_sign *MUST* be true for certificate authorities
          cert_sign = true
          crl_sign = true
        }
        extended_key_usage {
          server_auth = false
        }
      }
    }
  }
  key_spec {
    algorithm = "RSA_PKCS1_4096_SHA256"
  }
}


resource "google_privateca_certificate" "default" {
  pool = ""
  location = "us-central1"
  certificate_authority = google_privateca_certificate_authority.test-ca.certificate_authority_id
  lifetime = "860s"
  name = "my-certificate"
  pem_csr = file("test-fixtures/rsa_csr.pem")
}
# [END privateca_create_certificate_csr]
