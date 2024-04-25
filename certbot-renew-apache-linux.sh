#!/bin/bash

# Function to convert the SSL certificate expiry date to cron format
function convert_date_cron () {
    #grep -oP 'ServerName\s+\K[^:#\s]+' /etc/apache2/sites-enabled/*.conf | awk -F'/' '{print $NF}' | awk -F':' '{print $2}'
    # Store all domain names in an array
    domains=($(grep -oP 'ServerName\s+\K[^:#\s]+' /etc/apache2/sites-enabled/*.conf))
    # Extract domain names without file paths
    cleaned_domains=()
    for domain in "${domains[@]}"; do
        cleaned_domain=$(echo "$domain" | cut -d: -f2)
        cleaned_domains+=("$cleaned_domain")
    done
    # Remove duplicate domain names
    unique_domains=($(echo "${cleaned_domains[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))

    # Print unique domain names
    echo "Unique domain names:"
    for domain in "${unique_domains[@]}"; do
        echo "$domain"

        # Get the SSL certificate expiry date for each domain
        local date_time=$(echo | openssl s_client -connect "$domain":443 2>/dev/null | openssl x509 -noout -enddate)
        local expiry_date=$(echo "$date_time" | grep -oE 'notAfter=.+' | cut -d '=' -f 2-)
        local cron_date=$(date -d "$expiry_date" +"%M %H %d %m *")
        echo "$cron_date"
        # Check if the cron job already exists
        if ! grep -q -F "$cron_date root certbot renew --post-hook 'systemctl reload apache2'" /etc/crontab; then
            # Write the cron job to renew the SSL certificate
            write_crontab "$cron_date"
        fi

        # Remove the cron job after certificate renewal if necessary
        remove_cron_after_renew "$expiry_date"
    done
}

# Function to write the cron job to renew the SSL certificate
function write_crontab () {
    local cron_date=$1
    echo "$cron_date root certbot renew --post-hook 'systemctl reload apache2'" >> /etc/crontab
}

# Function to remove the cron job after certificate renewal
function remove_cron_after_renew () {
    local expiry_date=$1
    # Check if the current date is after the expiry date
    local current_date=$(date +"%s")
    local expiry_date_seconds=$(date -d "$expiry_date" +"%s")

    if [[ "$current_date" -gt "$expiry_date_seconds" ]]; then
        sed -i '/certbot renew/d' /etc/crontab
    fi
}

# Main function
function main () {
    convert_date_cron
}

# Run the main function
main
