# Install Docker & dependencies
sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker repo
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
cat /etc/apt/sources.list.d/docker.list

# Write docker-compose.yml separately (inside EOF block)
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
      WORDPRESS_DB_HOST: database:3306
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
# Check VM resource usage after running Docker

echo "Final checks complete. VM should be accessible!"

# run compose.yml
docker compose up -d

