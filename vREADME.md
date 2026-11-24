# ClientoraHQ Self-Hosting Kit

A self-hosting setup for a Next.js application with PostgreSQL 16, Docker, and Docker Compose.

## Project Overview

This project provides a containerized environment for running a Next.js application with a PostgreSQL database.

The application and database run as separate Docker services and are managed through Docker Compose.

## Architecture

```text
             User / Browser
                   |
                   v
          Next.js Application
             (Port 3000)
                   |
                   v
             PostgreSQL 16
             (Port 5432)
                   |
                   v
             Named Volume
              postgres_data
```

## Technologies Used

- Next.js
- Node.js 22
- PostgreSQL 16
- Docker
- Docker Compose
- Git and GitHub
- Drizzle ORM

## Project Structure

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
│   ├── pnpm-lock.yaml
│   └── next.config.ts
│
├── Dockerfile
├── .dockerignore
├── .env.example
├── .gitignore
└── docker-compose.yml
```

## Prerequisites

- Docker Engine
- Docker Compose plugin
- Git

## Environment Configuration

Clone the repository:

```bash
git clone https://github.com/developmentoperation69/clientorahq-self-hosting.git

cd clientorahq-self-hosting
```

Create your environment file:

```bash
cp .env.example .
