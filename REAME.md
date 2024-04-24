# Certbot Auto-Renew SSL Certificate in Linux (Ubuntu)

This script automates the renewal process of SSL certificates managed by Certbot in a Linux (Ubuntu) environment. It simplifies the process by extracting domain information from either the Nginx or Apache configuration directories (`/etc/nginx/sites-enabled` or `/etc/apache/sites-enabled`), finding the expiry date of all domains, converting the expiry date to a crontab expression format, and finally adding the necessary crontab entries to ensure automatic renewal.

## Features

- Extracts domain information from Nginx or Apache configuration directories.
- Determines the expiry date of SSL certificates for all domains.
- Converts expiry dates to crontab expressions for scheduling.
- Adds crontab entries to `/etc/crontab` for automated renewal.

## Usage

1. Clone this repository to your Linux server:

   ```bash
   git clone https://github.com/singhragvendra503/certbot_auto_renew_script.git
   
   
![demo.png]    
 
Note* You can also integrate this script into your system's crontab for periodic execution. It automatically removes old crontab entries related to Certbot and adds new ones for seamless renewal.