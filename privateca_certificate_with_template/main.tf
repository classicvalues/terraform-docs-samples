# [START privateca_create_certificate_template]
resource "google_privateca_certificate_template" "template" {
  location    = "us-central1"
  name = "my-certificate-template"
  description = "An updated sample certificate template"

  identity_constraints {
    allow_subject_alt_names_passthrough = true
    allow_subject_passthrough           = true

    cel_expression {
      description = "Always true"
      expression  = "true"
      location    = "any.file.anywhere"
      title       = "Sample expression"
    }
  }

  passthrough_extensions {
    additional_extensions {
      object_id_path = [1, 6]
    }

    known_extensions = ["EXTENDED_KEY_USAGE"]
  }

  predefined_values {
    additional_extensions {
      object_id {
        object_id_path = [1, 6]
      }

      value    = "c3RyaW5nCg=="
      critical = true
    }

    aia_ocsp_servers = ["string"]

    ca_options {
      is_ca                  = false
      max_issuer_path_length = 6
    }

    key_usage {
      base_key_usage {
        cert_sign          = false
        content_commitment = true
        crl_sign           = false
        data_encipherment  = true
        decipher_only      = true
        digital_signature  = true
        encipher_only      = true
        key_agreement      = true
        key_encipherment   = true
      }

      extended_key_usage {
        client_auth      = true
        code_signing     = true
        email_protection = true
        ocsp_signing     = true
        server_auth      = true
        time_stamping    = true
      }

      unknown_extended_key_usages {
        object_id_path = [1, 6]
      }
    }

    policy_ids {
      object_id_path = [1, 6]
    }
  }
}

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
  certificate_template = google_privateca_certificate_template.template.id
}
# [END privateca_create_certificate_template]
