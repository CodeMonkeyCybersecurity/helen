#!/usr/bin/env python3
import jwt
import datetime

# Admin API key parts
key_id = "687e137adb65b00001a55bbe"
secret = "0d346b24dfa16f8dfe3b8a80acbd7475eeb205bd2957595fe5698b13a81048a5"

# Create JWT token
iat = int(datetime.datetime.now().timestamp())
header = {
    "alg": "HS256",
    "typ": "JWT",
    "kid": key_id
}
payload = {
    "iat": iat,
    "exp": iat + 300,  # 5 minutes
    "aud": "/admin/"
}

# Decode the hex secret
secret_bytes = bytes.fromhex(secret)

# Generate token
token = jwt.encode(payload, secret_bytes, algorithm="HS256", headers=header)
print(token)