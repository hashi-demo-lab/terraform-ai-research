#!/bin/bash
# Internal CA certificate setup for DevContainers
# Installs certificates from internal services into the system CA store
set -e

# ============================================================================
# CONFIGURATION - UPDATE THESE VALUES FOR YOUR ENVIRONMENT
# ============================================================================
INTERNAL_HOST="${INTERNAL_CA_HOST:-}"
INTERNAL_IP="${INTERNAL_CA_IP:-}"
CERT_NAME="${INTERNAL_CA_CERT_NAME:-internal-ca-chain}"
# ============================================================================

if [ -z "$INTERNAL_HOST" ]; then
    echo "Error: INTERNAL_CA_HOST environment variable is required"
    echo "Usage: INTERNAL_CA_HOST=myservice.internal INTERNAL_CA_IP=10.0.0.1 $0"
    exit 1
fi

CERT_PATH="/usr/local/share/ca-certificates/${CERT_NAME}.crt"

echo "=== Internal CA Certificate Setup ==="
echo "Host: $INTERNAL_HOST"
[ -n "$INTERNAL_IP" ] && echo "IP:   $INTERNAL_IP"
echo ""

# Step 1: Add hostname to /etc/hosts (if IP provided)
echo "[1/4] Configuring DNS resolution..."
if [ -z "$INTERNAL_IP" ]; then
    echo "  - Skipped (no IP provided, using DNS)"
elif grep -q "$INTERNAL_HOST" /etc/hosts 2>/dev/null; then
    echo "  ✓ Host already in /etc/hosts"
else
    echo "$INTERNAL_IP $INTERNAL_HOST" | sudo tee -a /etc/hosts > /dev/null
    echo "  ✓ Added $INTERNAL_HOST -> $INTERNAL_IP to /etc/hosts"
fi

# Step 2: Extract and install certificate chain
echo "[2/4] Installing certificate chain..."
if [ -f "$CERT_PATH" ]; then
    echo "  ✓ Certificate already exists at $CERT_PATH"
else
    # Try to extract from server
    echo "  Extracting certificate chain from $INTERNAL_HOST:443..."
    if openssl s_client -connect "${INTERNAL_HOST}:443" -showcerts </dev/null 2>/dev/null \
        | awk '/BEGIN CERTIFICATE/,/END CERTIFICATE/{ print }' \
        | sudo tee "$CERT_PATH" > /dev/null; then

        CERT_COUNT=$(grep -c "BEGIN CERTIFICATE" "$CERT_PATH" 2>/dev/null || echo "0")
        if [ "$CERT_COUNT" -gt 0 ]; then
            echo "  ✓ Extracted $CERT_COUNT certificate(s)"
        else
            echo "  ✗ Failed to extract certificates"
            echo "    Try placing the certificate chain manually at: $CERT_PATH"
            exit 1
        fi
    else
        echo "  ✗ Could not connect to $INTERNAL_HOST:443"
        echo "    Ensure the host is reachable and try again"
        exit 1
    fi
fi

# Step 3: Update system CA certificates
echo "[3/4] Updating system CA store..."
RESULT=$(sudo update-ca-certificates 2>&1)
ADDED=$(echo "$RESULT" | grep -oP '\d+(?= added)' || echo "0")
echo "  ✓ CA store updated ($ADDED certificates added)"

# Step 4: Verify certificate trust
echo "[4/4] Verifying certificate trust..."

# Test TLS handshake with curl (system CA)
echo -n "  curl (system CA): "
if curl -s --connect-timeout 5 "https://${INTERNAL_HOST}" -o /dev/null 2>/dev/null; then
    echo "✓ TLS handshake successful"
else
    echo "✗ TLS handshake failed"
    echo "    Check certificate installation and network connectivity"
fi

# Test with Node.js (custom CA)
echo -n "  node (NODE_EXTRA_CA_CERTS): "
if NODE_EXTRA_CA_CERTS="$CERT_PATH" node -e "
    fetch('https://${INTERNAL_HOST}')
        .then(() => process.exit(0))
        .catch(() => process.exit(1))
" 2>/dev/null; then
    echo "✓ TLS handshake successful"
else
    echo "✗ TLS handshake failed"
    echo "    Ensure NODE_EXTRA_CA_CERTS=$CERT_PATH is set"
fi

echo ""
echo "=== Setup Complete ==="
echo ""
echo "Certificate installed at: $CERT_PATH"
echo ""
echo "For Node.js applications, set:"
echo "  export NODE_EXTRA_CA_CERTS=$CERT_PATH"
