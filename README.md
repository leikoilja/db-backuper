# DB Backuper

Backing up databases automatically every night at 1AM.
Storing dumps on the volume that is mounted to synology where duplicati is picking up changes

## Building the image and pushing to the registry

- docker build -t registry.gingernest.com/leikoilja/db-backuper:v1 .
- docker push registry.gingernest.com/leikoilja/db-backuper:v1
