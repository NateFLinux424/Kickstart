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
    image: mysql:latest
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
    logging:
      options:
        max-size: "10m"
        max-file: "3"

  wordpress:
    depends_on:
      - database
    image: wordpress:6.8.1
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
    logging:
      options:
        max-size: "10m"
        max-file: "3"

networks:
  wordpress-network:

volumes:
  db-data:
EOF

# Verify NSG Rules for SSH
az network nsg rule create --resource-group midterm3 --nsg-name midterm3test-nsg --name AllowSSH \
  --priority 100 --direction Inbound --access Allow --protocol Tcp --destination-port-ranges 22 --source-address-prefixes "0.0.0.0/0"

echo "Final checks complete. VM should be accessible!"

# run compose.yml
sudo docker compose up 

echo "Waiting for MySQL to be ready..."
while ! docker exec database-1 mysqladmin --user=root --password=wordpress ping --silent; do
    sleep 2
done

echo "Waiting for WordPress to be ready..."
while ! curl -s http://localhost:8080; do
    sleep 2
done


