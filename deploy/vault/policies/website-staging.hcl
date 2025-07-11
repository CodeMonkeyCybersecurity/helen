# Vault policy for website staging environment

path "secret/data/ssl/staging.cybermonkey.net.au" {
  capabilities = ["read"]
}

path "secret/data/website/staging/*" {
  capabilities = ["read"]
}

path "secret/data/shared/*" {
  capabilities = ["read"]
}

path "database/creds/website-staging" {
  capabilities = ["read"]
}

path "auth/token/lookup-self" {
  capabilities = ["read"]
}

path "auth/token/renew-self" {
  capabilities = ["update"]
}

path "auth/token/revoke-self" {
  capabilities = ["update"]
}

path "sys/wrapping/lookup" {
  capabilities = ["update"]
}

path "sys/wrapping/unwrap" {
  capabilities = ["update"]
}

path "sys/wrapping/rewrap" {
  capabilities = ["update"]
}