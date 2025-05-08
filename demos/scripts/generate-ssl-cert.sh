#!/bin/bash

# Create directories if they don't exist
mkdir -p ../cert

# Certificate details
CERT_DIR="../cert"
DAYS_VALID=365
COUNTRY="CN"
STATE="Shanghai"
LOCALITY="Shanghai"
ORGANIZATION="Development"
ORGANIZATIONAL_UNIT="Development Team"
COMMON_NAME="localhost"
EMAIL="dev@example.com"

echo "Generating SSL certificates for development..."

# Generate private key and certificate
openssl req -x509 \
    -newkey rsa:2048 \
    -nodes \
    -sha256 \
    -days $DAYS_VALID \
    -keyout $CERT_DIR/private.key \
    -out $CERT_DIR/certificate.crt \
    -subj "/C=$COUNTRY/ST=$STATE/L=$LOCALITY/O=$ORGANIZATION/OU=$ORGANIZATIONAL_UNIT/CN=$COMMON_NAME/emailAddress=$EMAIL"

# Set permissions
chmod 600 $CERT_DIR/private.key
chmod 644 $CERT_DIR/certificate.crt

echo "SSL certificates generated successfully!"
echo "Location: $CERT_DIR"
echo "  - Private key: private.key"
echo "  - Certificate: certificate.crt" 