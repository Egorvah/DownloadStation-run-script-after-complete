# DownloadStation-run-script-after-complete
Run script after download on Synology DSM DownloadStation


Test working on DSM 6.2

# Install

## Download script to your NAS (run as superuser)
#### Before copy-paste and run change '{path to download on yor nas}' to your path destination
```
wget https://raw.githubusercontent.com/Egorvah/DownloadStation-run-script-after-complete/master/download_complete.sh -O {path to download on yor nas}"
```

## Install
```
chmod +x {path to your script}
{path to your script} install
```

## Edit script for your algorithm
After line '# Start your algorithm' add you code


For example uses send message to telegram bot


# Add schedule task on DMS
### Open 'Control Panel' > 'Task Scheduler'
### Select 'Create' > 'Scheduled Task' > 'User-defined script'
### Enter task name
### Set Schedule time (you can set every minute)
### Set 'bash {path to your script}' to User-defined script field
### Done!
