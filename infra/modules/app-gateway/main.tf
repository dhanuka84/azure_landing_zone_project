# Creates an App Gateway with WAF
resource "azurerm_application_gateway" "app_gw" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "app-gw-ip-config"
    subnet_id = var.subnet_id
  }

  frontend_port {
    name = "https-port"
    port = 443
  }

  frontend_ip_configuration {
    name                 = "app-gw-frontend-ip"
    public_ip_address_id = var.public_ip_address_id
  }

  ssl_certificate {
    name                = var.ssl_certificate_name
    key_vault_secret_id = var.key_vault_secret_id_ssl_cert
  }

  http_listener {
    name                           = "https-listener"
    frontend_ip_configuration_name = "app-gw-frontend-ip"
    frontend_port_name             = "https-port"
    protocol                       = "Https"
    ssl_certificate_name           = var.ssl_certificate_name
  }

  backend_address_pool {
    name = "apim-backend-pool"
    # You will configure this to point to your APIM's internal IP
    fqdns = [var.apim_gateway_url]
  }

  # --- THIS IS THE FIX ---
  # In provider v4.x, 'health_probe' is not a valid block.
  # The block is simply named 'probe'.
  
  probe {
    name                = "apim-probe"
    protocol            = "Https"
    path                = "/status-0123456789abcdef" # APIM default health endpoint
    host                = var.apim_gateway_url
    interval            = 30
    timeout             = 30
    unhealthy_threshold = 3
  }
  
  backend_http_settings {
    name                  = "apim-http-settings"
    cookie_based_affinity = "Disabled"
    port                  = 443
    protocol              = "Https"
    request_timeout       = 20
    probe_name            = "apim-probe" # This name now refers to the 'probe' block
  }

  request_routing_rule {
    name                       = "https-routing-rule"
    rule_type                  = "Basic"
    http_listener_name         = "https-listener"
    backend_address_pool_name  = "apim-backend-pool"
    backend_http_settings_name = "apim-http-settings"
  }

  waf_configuration {
    enabled                  = true
    firewall_mode            = "Prevention"
    rule_set_type            = "OWASP"
    rule_set_version         = "3.2"
  }
}