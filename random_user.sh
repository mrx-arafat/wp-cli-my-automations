#!/bin/bash

# Check if MySQL is running
if ! systemctl is-active --quiet mysql; then
    echo "MySQL service is not running."
    exit 1
fi

# Check if WordPress is installed
if ! wp core is-installed --path=./; then
    read -p "Enter the site URL: " site_url
    read -p "Enter the site title: " site_title
    read -p "Enter the admin username: " admin_user
    read -p "Enter the admin email: " admin_email

    echo "Installing WordPress..."
    wp core install --url="$site_url" --title="$site_title" --admin_user="$admin_user" --admin_email="$admin_email" --path=./
    if [ $? -ne 0 ]; then
        echo "WordPress installation failed."
        exit 1
    fi
fi

# Function to generate user data
generate_user_data() {
    local name=$(curl -s https://randomuser.me/api/ | jq -r '.results[0].name.first')
    local last_name=$(curl -s https://randomuser.me/api/ | jq -r '.results[0].name.last')
    local username=$(echo "${name,,}${last_name,,}" | tr -d ' ')
    local email="${username}@example.com"
    echo "$username $email $name $last_name"
}

# Ask user for the number of commands to generate
read -p "Enter the number of users to create: " count

# Check if count is a valid number
if ! [[ "$count" =~ ^[0-9]+$ ]]; then
    echo "Please enter a valid number."
    exit 1
fi

# Ask user for roles
read -p "Enter roles (comma-separated, e.g., administrator,editor,subscriber): " input_roles
IFS=',' read -r -a roles <<< "$input_roles"

# Generate user commands
for i in $(seq 1 $count); do
    user_data=$(generate_user_data)
    username=$(echo $user_data | awk '{print $1}')
    email=$(echo $user_data | awk '{print $2}')
    first_name=$(echo $user_data | awk '{print $3}')
    last_name=$(echo $user_data | awk '{print $4}')
    
    # Select a random role from the array
    role=${roles[RANDOM % ${#roles[@]}]}
    
    # Run the WP command
    echo "Executing: wp user create $username $email --first_name=$first_name --last_name=$last_name --user_pass=password123 --role=$role"
    wp user create "$username" "$email" --first_name="$first_name" --last_name="$last_name" --user_pass="password123" --role="$role" --path=./
done
