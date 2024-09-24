#!/bin/bash

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

# Define roles
roles=("administrator" "editor" "author" "contributor" "subscriber")

# Display roles as numbered options
echo "Select a role for the users:"
for i in "${!roles[@]}"; do
  echo "$((i + 1)). ${roles[i]}"
done

# Ask user for the role selection
read -p "Enter the number corresponding to the desired role: " role_number

# Validate role selection
if ! [[ "$role_number" =~ ^[1-5]$ ]]; then
  echo "Please enter a valid number between 1 and 5."
  exit 1
fi

# Get the selected role
selected_role=${roles[$((role_number - 1))]}

# Generate user commands
for i in $(seq 1 $count); do
  user_data=$(generate_user_data)
  username=$(echo $user_data | awk '{print $1}')
  email=$(echo $user_data | awk '{print $2}')
  first_name=$(echo $user_data | awk '{print $3}')
  last_name=$(echo $user_data | awk '{print $4}')
  
  echo "wp user create $username $email --first_name=$first_name --last_name=$last_name --user_pass=password123 --role=$selected_role"
done
