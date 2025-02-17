#!/bin/bash

# Input Validation Function (no special characters or spaces allowed)
validate_input() {
	    if [[ ! $1 =~ ^[a-zA-Z0-9_-]+$ ]]; then
		            echo "Error: Name can only contain letters, numbers, underscores, and hyphens"
			            exit 1
				        fi
				}

			# Name provision
			echo "Please enter your name (no spaces or special characters):"
			read name

			# Name validation
			validate_input "$name"

			# Create main directory
			app_dir="submission_reminder_${name}"
			mkdir -p "$app_dir"

			# Create subdirectories
			mkdir -p "$app_dir/app"
			mkdir -p "$app_dir/config"
			mkdir -p "$app_dir/modules"
			mkdir -p "$app_dir/assets"

			# Create and populate config.env
			cat > "$app_dir/config/config.env" << 'EOL'
# This is the config file
ASSIGNMENT="Shell Navigation"
DAYS_REMAINING=2
EOL

# Create and populate reminder.sh
cat > "$app_dir/app/reminder.sh" << 'EOL'
#!/bin/bash

# Source environment variables and helper functions
source ./config/config.env
source ./modules/functions.sh

# Path to the submissions file
submissions_file="./assets/submissions.txt"

# Print remaining time and run the reminder function
echo "Assignment: $ASSIGNMENT"
echo "Days remaining to submit: $DAYS_REMAINING days"
echo "--------------------------------------------"

check_submissions $submissions_file
EOL

# Create and populate functions.sh
cat > "$app_dir/modules/functions.sh" << 'EOL'
#!/bin/bash

# Function to read submissions file and output students who have not submitted
function check_submissions {
    local submissions_file=$1
    echo "Checking submissions in $submissions_file"

    # Skip the header and iterate through the lines
    while IFS=, read -r student assignment status; do
        # Remove leading and trailing whitespace
        student=$(echo "$student" | xargs)
        assignment=$(echo "$assignment" | xargs)
        status=$(echo "$status" | xargs)

        # Check if assignment matches and status is 'not submitted'
        if [[ "$assignment" == "$ASSIGNMENT" && "$status" == "not submitted" ]]; then
            echo "Reminder: $student has not submitted the $ASSIGNMENT assignment!"
        fi
    done < <(tail -n +2 "$submissions_file") # Skip the header
}
EOL

# Create and populate submissions.txt
cat > "$app_dir/assets/submissions.txt" << 'EOL'
student, assignment, submission status
Chinemerem, Shell Navigation, not submitted
Chiagoziem, Git, submitted
Divine, Shell Navigation, not submitted
Anissa, Shell Basics, submitted
Teta, Shell Navigation, not submitted
Ariane, Shell Navigation, not submitted
Naillah, Shell Navigation, not submitted
Nelly, Shell Navigation, not submitted
Stecy, Shell Navigation, not submitted
EOL

# Create startup.sh
cat > "$app_dir/startup.sh" << 'EOL'
#!/bin/bash

# Check if the reminder application is already running
if pgrep -f "app/reminder.sh" > /dev/null; then
    echo "Submission Reminder is already running!"
    exit 1
fi

# Start the reminder application
./app/reminder.sh

echo "Submission check completed!"
EOL

# Make scripts executable
chmod +x "$app_dir/app/reminder.sh"
chmod +x "$app_dir/modules/functions.sh"
chmod +x "$app_dir/startup.sh"

echo "Environment setup completed successfully!"
echo "Directory structure created in: $app_dir"
echo "You can start the application by running: cd $app_dir && ./startup.sh"
