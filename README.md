CHIP Battery Auto-Shutdown
============================

This script will check the level of a battery attached to the CHIP.

This needs to be run as root due to the shutdown command.

This script does not have a loop internal to it and should be set to a cron job (preferably root cron) at a 5 or 10 minute interval.

# Installation

  ```
  git clone https://github.com/xtacocorex/chip_batt_autoshutdown.git
  cd chip_batt_autoshutdown.sh
  sudo cp ./chip_batt_autoshutdown.sh /usr/bin/
  ```

Refer to Debian docs on setting up cron jobs
