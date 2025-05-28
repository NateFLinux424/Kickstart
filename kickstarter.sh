# Install Docker & dependencies
sudo apt-get update
sudo apt-get install -y ca-certificates curl

# Setup keyrings and add Docker's official GPG key
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the Docker repository to Apt sources
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update

# Install Docker components
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Verify installation
sudo docker run hello-world

# Ensure Docker is running
sudo systemctl start docker
sudo systemctl enable docker

# Ensure container runtime is running
sudo systemctl restart containerd
sudo systemctl status containerd

# Write docker-compose.yml file
cat <<EOF > docker-compose.yml
services:
  database:
    image: mysql:8.0
    command: '--default-authentication-plugin=mysql_native_password'
    ports:
      - "3306:3306"
    environment:
      MYSQL_ROOT_PASSWORD: wordpress
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wordpress
      MYSQL_PASSWORD: wordpress
    volumes:
      - db-data:/var/lib/mysql
    networks:
      - wordpress-network

  wordpress:
    depends_on:
      - database
    image: wordpress:latest
    ports:
      - "8080:80"
    environment:
      WORDPRESS_DB_HOST: database
      WORDPRESS_DB_NAME: wordpress
      WORDPRESS_DB_USER: wordpress
      WORDPRESS_DB_PASSWORD: wordpress
    volumes:
      - ./:/var/www/html
    networks:
      - wordpress-network

networks:
  wordpress-network:

volumes:
  db-data:
EOF

# Check VM resource usage
echo "Final checks complete. VM should be accessible!"

# Run Docker Compose
sudo docker compose up -d

