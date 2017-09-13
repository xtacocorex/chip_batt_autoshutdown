CHIP Battery Auto-Shutdown
============================

This script will check the level of a battery attached to the CHIP.

This needs to be run as root due to the shutdown command.

This script does not have a loop internal to it and should be set to a cron job (preferably root cron) at a 5 or 10 minute interval.

# Installation

  ```
  git clone https://github.com/xtacocorex/chip_batt_autoshutdown.git
  cd chip_batt_autoshutdown
  chmod +x chip_autoshutdown.sh
  sudo cp ./chip_autoshutdown.sh /usr/bin/
  ```

If running the script manually, be sure to run with sudo

# Cron Job Setup

Edit the root crontab

  ```
  sudo crontab -e
  ```

For 5 Minute check, enter:

  ```
  */5 * * * * /usr/bin/chip_autoshutdown.sh >> /var/log/chip_batt.log 2>&1
  ```

For 10 Minute check, enter:

  ```
  */10 * * * * /usr/bin/chip_autoshutdown.sh >> /var/log/chip_batt.log 2>&1
  ```

Then do:

  ```
  sudo service cron restart
  ```

To check the status of the script:

  ```
  tail -f /var/log/chip_batt.log
  ```

