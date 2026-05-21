#!/bin/bash

# setup_vps.sh
# Run this script on your Ubuntu VPS to automatically deploy the Fuel-Cal backend.
# Usage: sudo ./setup_vps.sh

set -e

echo "🚀 Starting Fuel-Cal VPS Setup..."

# 1. Update system packages
echo "📦 Updating system packages..."
apt-get update && apt-get upgrade -y

# 2. Install Docker & Docker Compose if not present
if ! command -v docker &> /dev/null; then
    echo "🐳 Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
else
    echo "✅ Docker is already installed."
fi

if ! command -v docker-compose &> /dev/null; then
    echo "🐙 Installing Docker Compose..."
    curl -L "https://github.com/docker/compose/releases/download/v2.24.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
else
    echo "✅ Docker Compose is already installed."
fi

# 3. Install Nginx
echo "🌐 Installing Nginx..."
apt-get install -y nginx

# 4. Copy Nginx config
echo "⚙️ Configuring Nginx..."
cp nginx.conf /etc/nginx/sites-available/fuel_backend

# Enable the site if not already enabled
if [ ! -L /etc/nginx/sites-enabled/fuel_backend ]; then
    ln -s /etc/nginx/sites-available/fuel_backend /etc/nginx/sites-enabled/
fi

# Remove default nginx site
if [ -L /etc/nginx/sites-enabled/default ]; then
    rm /etc/nginx/sites-enabled/default
fi

# 5. Restart Nginx
echo "🔄 Restarting Nginx..."
systemctl restart nginx

# 6. Start the Backend Stack!
echo "🚢 Starting Docker containers..."
# Navigate up to the backend directory containing docker-compose.yml
cd ..
docker-compose up -d --build

echo "🎉 Deployment Complete!"
echo "Your FastAPI backend is now running and exposed on port 80."
echo "Test it by visiting: http://<YOUR_VPS_IP>/docs"
