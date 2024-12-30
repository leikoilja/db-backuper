# 📦 DB Backuper

Automatically backup your PostgreSQL databases with ease at your specified schedule. Perfect for ensuring your data is safe and sound! 🛡️

## 📂 What This Does

- **Automates Backups**: Set up scheduled backups using cron syntax.
- **Stores Securely**: Direct where backups are stored on your host.
- **Cleans Up**: Automatically deletes old backups based on the retention policy you set (`DAYS_TO_KEEP`).

## 🛠️ Build and Push Your Image

### 🔨 Building the Image

- **For ARM Architectures** (e.g., Apple M1/M2):

  ```bash
  docker build -t registry.gingernest.com/USERNAME/db-backuper:v1 .
  ```

- **For AMD Architectures**:

  ```bash
  docker build --platform linux/amd64 -t registry.example.com/USERNAME/db-backuper:v1.2 .
  ```

### 🚢 Pushing the Image to the Registry

Once your build is complete, push the image to your registry:

```bash
docker push registry.example.com/USERNAME/db-backuper:v1.2
```

## 🚀 Quick Start

1. Clone the repo `git clone https://github.com/leikoilja/db-backuper.git`
2. Rename the `db_urls.example` to `my_db_urls` file and fill in with your own information
3. Create `docker-compose.yml` file using the following example

```yaml
services:
  db-backuper:
    image: registry.example.com/USERNAME/db-backuper:v1.2
    container_name: db-backuper
    restart: unless-stopped
    volumes:
      - /homes/USERNAME/Backups/databases:/app/pg_dumps
      - my_db_urls:/app/db_urls
    environment:
      - DAYS_TO_KEEP=7               # keep backups for 7 days
      - CRON_SCHEDULE=0 1 * * *     # backup daily at 1 AM
```

## 📌 Requirements

- Ensure that the file `db_urls.sh` is correctly formatted and accessible.
- The `/homes/USERNAME/Backups/databases` directory must be writable by Docker.

## 📝 Tips

- Customize your `CRON_SCHEDULE` to adjust the timing of your backups easily.
- Monitor your backup logs to ensure everything is running smoothly (`/var/log/cron.log` in your container).
- Review and secure access to your database URLs—these contain sensitive information.

Happy Backing Up! 😊
