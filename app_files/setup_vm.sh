#!/bin/bash
set -euo pipefail

APP_DIR=/home/azureuser/real_estate_flask

# DB_HOST, DB_USER, DB_PASS, DB_NAME are expected to already be set in the
# environment by the caller (Terraform's app_deploy module passes these in
# directly on the command line before invoking this script). Fail loudly
# instead of silently falling back to stale/hardcoded values.
: "${DB_HOST:?DB_HOST must be set}"
: "${DB_USER:?DB_USER must be set}"
: "${DB_PASS:?DB_PASS must be set}"
: "${DB_NAME:?DB_NAME must be set}"

# Create virtual environment and install dependencies
cd "$APP_DIR"

sudo apt-get update
sudo apt-get install -y python3 python3-pip python3-venv nginx mysql-client
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Create systemd service file
# Credentials are injected from this script's own environment (passed in by
# Terraform) rather than hardcoded, so no plaintext password lives in this
# file or in source control.
sudo tee /etc/systemd/system/realestate.service > /dev/null <<EOF
[Unit]
Description=Real Estate Flask App
After=network.target

[Service]
User=azureuser
WorkingDirectory=/home/azureuser/real_estate_flask
Environment="DB_TYPE=mysql"
Environment="DB_HOST=${DB_HOST}"
Environment="DB_USER=${DB_USER}"
Environment="DB_PASS=${DB_PASS}"
Environment="DB_NAME=${DB_NAME}"
ExecStart=/home/azureuser/real_estate_flask/venv/bin/gunicorn --workers 3 --bind 0.0.0.0:5000 app:app
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Restrict the systemd unit file so other local users on the VM can't read
# the DB password out of it
sudo chmod 600 /etc/systemd/system/realestate.service

# Configure Nginx
sudo tee /etc/nginx/sites-available/realestate > /dev/null <<EOF
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOF

sudo ln -sf /etc/nginx/sites-available/realestate /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Start services
sudo systemctl daemon-reload
sudo systemctl enable realestate
sudo systemctl start realestate
sudo systemctl restart nginx

echo "Deployment complete!"
