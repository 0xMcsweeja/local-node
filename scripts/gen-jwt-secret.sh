#!/bin/bash

# Create a 32-byte hex string for JWT secret
echo "Creating jwtsecret/jwt.hex..."
mkdir -p jwtsecret
openssl rand -hex 32 > jwtsecret/jwt.hex
chmod 400 jwtsecret/jwt.hex
echo "JWT secret generated."
