# Payroll System - Client Setup

This setup uses **Docker** to run the Rails 8 app and Postgres 16 database.  
The Rails app is prebuilt and hosted on Docker Hub, so no source code is required.

---

## **1. Prerequisites**

- Install [Docker Desktop](https://www.docker.com/products/docker-desktop)
- Modern Docker Desktop includes Docker Compose, no extra installation required

---

## **2. Environment Variables**

1. Copy `.env.example` to `.env`:

```bash
cp .env.example .env

Open .env and fill in:

RAILS_MASTER_KEY → provided by your vendor

PAYROLL_SYSTEM_DATABASE_PASSWORD → already set to secret123 by default

Example .env.example:

RAILS_MASTER_KEY=<paste-your-master-key-here>
PAYROLL_SYSTEM_DATABASE_PASSWORD=secret123
3. Start the Application

Run both the Rails app and Postgres database:

docker compose up -d

Docker will automatically pull the Rails image from Docker Hub and the official Postgres image if not already on your machine.

Containers will restart automatically if your system reboots.

4. First-Time Database Setup

Only required the first time:

docker compose exec web rails db:prepare

This will create the databases, run migrations, and seed initial data.

5. Access the App

Rails server runs at: http://localhost:3000

6. Stop Containers

To stop the app and database:

docker compose down

The Postgres data is persisted in the volume postgres_data, so your database will not be lost.

7. Update the App

When a new version of the Rails app is available on Docker Hub:

docker compose pull web
docker compose up -d

This pulls the new Rails image and restarts the container.

Database remains intact because it is stored in the volume.

8. Notes

No source code is included; the client only runs the prebuilt Docker image.

All secrets are managed via .env.

If you want to modify the app, you need the full Rails source code and a local build.