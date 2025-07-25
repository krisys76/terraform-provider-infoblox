# Example demonstrating the fixed issue with allocated_ipv4_addr

# Create a fixed address with dynamic allocation
resource "infoblox_ipv4_fixed_address" "test" {
  network_view = "default"
  network      = "10.0.1.0/24"  # Dynamic allocation from network
  name         = "test-host"
  match_client = "RESERVED"
}

# Now this works at plan time because allocated_ipv4_addr is computed
resource "local_file" "host_config" {
  content  = "Host IP: ${infoblox_ipv4_fixed_address.test.allocated_ipv4_addr}\n"
  filename = "/tmp/host_config.txt"
}

# This would have failed before the fix because ipv4addr wasn't computed
# but now works with the new allocated_ipv4_addr field

output "allocated_ip" {
  value = infoblox_ipv4_fixed_address.test.allocated_ipv4_addr
  description = "The dynamically allocated IP address"
}

output "original_ipv4addr" {
  value = infoblox_ipv4_fixed_address.test.ipv4addr
  description = "The original ipv4addr field (for backward compatibility)"
}