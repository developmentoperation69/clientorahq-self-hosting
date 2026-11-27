# ClientoraHQ Self-Hosting Kit

A self-hosted deployment solution for a Next.js application with PostgreSQL 16, Docker, Docker Compose, and Nginx reverse proxy.

## 1. Project Overview

ClientoraHQ Self-Hosting Kit provides a Docker-based environment to deploy and manage a Next.js application with a PostgreSQL database.

The project focuses on reliable deployment, persistent database storage, HTTPS configuration, automated backups, and application recovery.

### Key Features

- Next.js application containerization
- PostgreSQL 16 database integration
- Docker Compose service orchestration
- Nginx reverse proxy configuration
- HTTPS and TLS configuration
- HTTP to HTTPS redirection
- Security headers
- Persistent PostgreSQL storage
- Automated database backup
- Database restore testing
- Application update and rollback procedures

## 2. Architecture

```text
                 User / Browser
                       |
                       v
                 Nginx Reverse Proxy
                    Port 80/443
                       |
                       v
               Next.js Application
                    Port 3000
                       |
                       v
                 PostgreSQL 16
                    Port 5432
                       |
                       v
                 Docker Volume
                  postgres_data
```

### Services

| Service | Technology | Purpose |
|---|---|---|
| app | Next.js / Node.js 22 | Web application |
| db | PostgreSQL 16 | Database |
| nginx | Nginx Alpine | Reverse proxy and HTTPS |

## 3. Technologies Used

- Next.js
- Node.js 22
- PostgreSQL 16
- Docker Engine
- Docker Compose
- Nginx
- Git and GitHub
- Drizzle ORM
- Bash Scripting
- OpenSSL

## 4. Repository Structure

```text
clientorahq-self-hosting/
│
├── app/
│   ├── app/
│   ├── lib/
│   │   └── db/
│   │       ├── migrations/
│   │       ├── drizzle.ts
│   │       ├── queries.ts
│   │       └── schema.ts
│   ├── package.json
│   └── pnpm-lock.yaml
│
├── nginx/
│   ├── certs/
│   └── default.conf
│
├── backups/
│   └── logs/
│
├── Dockerfile
├── docker-compose.yml
├── .dockerignore
├── .env.example
├── .gitignore
├── backup.sh
├── restore.sh
└── README.md
```

Note: `.env`, SSL certificates, and backup files are excluded from Git where configured in `.gitignore`.

## 5. Server Requirements

Recommended environment:

- Ubuntu 22.04 or later
- Git
- Docker Engine
- Docker Compose plugin
- OpenSSL
- Internet connection
- Ports 80 and 443 available

## 6. Install Docker on Ubuntu

Update package information:

```bash
sudo apt update
sudo apt upgrade -y
```

Install required packages:

```bash
sudo apt install -y ca-certificates curl git openssl
```

Install Docker using the official convenience script:

```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```

Verify Docker:

```bash
sudo docker --version
sudo docker compose version
```

Optional: allow your user to run Docker without sudo:

```bash
sudo usermod -aG docker $USER
```

Log out and log back in for group membership to take effect.

## 7. Clone the Repository

Clone the project:

```bash
git clone https://github.com/developmentoperation69/clientorahq-self-hosting.git
```

Move into the project directory:

```bash
cd clientorahq-self-hosting
```

## 8. Configure Environment Variables

Create the environment file:

```bash
cp .env.example .env
```

Edit it:

```bash
nano .env
```

Configure your database credentials:

```env
POSTGRES_DB=appdb
POSTGRES_USER=appuser
POSTGRES_PASSWORD=CHANGE_TO_A_STRONG_PASSWORD
POSTGRES_URL=postgresql://appuser:CHANGE_TO_A_STRONG_PASSWORD@db:5432/appdb
```

Important:

- Replace the placeholder password with a strong password.
- Use the same password in both variables.
- Ensure special characters are URL-encoded in the database connection URL where necessary.
- Never upload `.env` to GitHub.

Secure the file:

```bash
chmod 600 .env
```

## 9. Configure SSL Certificates

Create the certificate directory:

```bash
mkdir -p nginx/certs
```

For local testing, generate a self-signed certificate:

```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
-keyout nginx/certs/localhost-key.pem \
-out nginx/certs/localhost.pem \
-subj "/CN=localhost"
```

The Nginx configuration expects:

```text
nginx/certs/localhost.pem
nginx/certs/localhost-key.pem
```

For a public production server:

- Configure your actual domain in Nginx.
- Obtain a trusted TLS certificate.
- Update certificate paths in the Nginx configuration.
- Configure DNS to point to your server.

A self-signed certificate is suitable for local testing but is not trusted by browsers for normal public production use.

## 10. Check Docker Compose Configuration

Validate the Compose configuration:

```bash
docker compose config
```

Check that the required services are defined:

```bash
docker compose config --services
```

Expected services:

```text
db
app
nginx
```

## 11. Deploy the Application

Build and start the services:

```bash
docker compose up -d --build
```

Check running containers:

```bash
docker compose ps
```

View application logs:

```bash
docker compose logs -f app
```

View all service logs:

```bash
docker compose logs
```

## 12. Verify Deployment

Check HTTPS response:

```bash
curl -k -I https://localhost
```

Check HTTP redirection:

```bash
curl -I http://localhost
```

Check database readiness:

```bash
docker exec clientorahq-db pg_isready -U appuser -d appdb
```

Check service status:

```bash
docker compose ps
```

Expected result:

- Application container is running.
- PostgreSQL container is healthy.
- Nginx container is running.
- HTTP requests redirect to HTTPS.
- HTTPS requests reach the application.

## 13. Nginx Reverse Proxy

Nginx acts as a reverse proxy between the user and the Next.js application.

Responsibilities:

- Accept HTTP and HTTPS requests.
- Redirect HTTP traffic to HTTPS.
- Forward requests to the application on port 3000.
- Forward client request headers.
- Apply security headers.
- Enable gzip compression.

The application is exposed internally through Docker Compose, while Nginx handles external web traffic.

## 14. Database Backup Automation

The project includes a Bash backup script.

Run the backup:

```bash
./backup.sh
```

The script:

- Checks PostgreSQL container availability.
- Creates a PostgreSQL database dump.
- Compresses the backup using gzip.
- Saves backups inside the `backups/` directory.
- Writes backup logs.
- Removes backups older than seven days.

List backup files:

```bash
ls -lh backups/
```

Check backup logs:

```bash
cat backups/logs/backup.log
```

## 15. Database Restore Testing

The restore script tests database recovery using a separate database named `appdb_restore_test`.

Run:

```bash
./restore.sh backups/<backup-file-name>.sql.gz
```

The script:

- Checks PostgreSQL availability.
- Creates or recreates the dedicated restore test database.
- Restores the selected backup into that test database.
- Logs the restore operation.

Check restore logs:

```bash
cat backups/logs/restore.log
```

Important: This restore test does not overwrite the production `appdb` database.

## 16. Update Application

Before updating, ensure that a recent database backup exists.

Check the current Git version:

```bash
git log --oneline -5
```

Pull the latest changes:

```bash
git pull origin main
```

Rebuild and restart services:

```bash
docker compose up -d --build
```

Verify the deployment:

```bash
docker compose ps
```

Check application logs:

```bash
docker compose logs --tail=100 app
```

Verify the application:

```bash
curl -k -I https://localhost
```

## 17. Application Rollback

If a new application deployment fails, identify the previous working Git commit.

View recent commits:

```bash
git log --oneline -5
```

Check out the previous working commit:

```bash
git checkout <previous-commit-id>
```

Rebuild and restart:

```bash
docker compose up -d --build
```

Verify the application:

```bash
docker compose ps
curl -k -I https://localhost
```

Return to the latest main branch when appropriate:

```bash
git checkout main
```

Important:

- This procedure rolls back application code.
- Database schema changes may require a separate migration rollback.
- Database backups should be available before risky updates.
- Do not use `docker compose down -v` during routine deployment or rollback because it can remove the PostgreSQL volume.

## 18. Persistent Database Storage

PostgreSQL data is stored in the named Docker volume:

```text
postgres_data
```

The volume allows database data to persist when containers are recreated.

Check Docker volumes:

```bash
docker volume ls
```

Inspect the project volume:

```bash
docker volume inspect clientorahq-self-hosting_postgres_data
```

Never remove the database volume during normal application updates.

## 19. Security Best Practices

- Keep database credentials private.
- Use strong database passwords.
- Never commit `.env` files.
- Never commit private SSL keys.
- Use trusted TLS certificates for public production deployments.
- Keep Ubuntu and Docker updated.
- Restrict database access to trusted services.
- Maintain regular database backups.
- Verify application health after updates.
- Test database restoration regularly.

## 20. Troubleshooting

### Check container status

```bash
docker compose ps
```

### View service logs

```bash
docker compose logs -f
```

### Check Nginx logs

```bash
docker compose logs nginx
```

### Check application logs

```bash
docker compose logs app
```

### Check database logs

```bash
docker compose logs db
```

### Check ports 80 and 443

```bash
sudo ss -ltnp | grep -E ':80|:443'
```

If another service is using these ports, investigate it before changing or stopping services.

### Restart services

```bash
docker compose restart
```

## 21. GitHub Repository

Repository:

https://github.com/developmentoperation69/clientorahq-self-hosting

## 22. Project Information

**Project:** ClientoraHQ Self-Hosting Kit

**Focus Areas:**

- Containerization
- Docker Compose
- PostgreSQL Deployment
- Nginx Reverse Proxy
- HTTPS Configuration
- Database Backup and Recovery
- Application Updates and Rollbacks

---

Maintained as a DevOps self-hosting deployment project.
