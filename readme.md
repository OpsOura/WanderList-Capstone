# Wanderlist DevOps Final Project

## Introduction
This repository contains the Wanderlist application and course material for the DevOps final project. The goal is to practice end-to-end DevOps workflows: containerization, orchestration, automation, CI/CD, and monitoring.

Key technologies used in the course:
- Docker & Docker Compose
- Kubernetes (Minikube) + kubectl
- Ansible
- GitHub Actions (self-hosted runner pattern recommended)
- Prometheus & Grafana for monitoring
- PostgreSQL (run as Docker container)

Important project constraints:
- Run PostgreSQL in Docker (avoid manual host installs for this course).
- We prefer plain Kubernetes manifests (no Helm) so students learn core concepts.
- README guidance avoids recommending storing credentials in GitHub; use a self-hosted runner, external secure CI variables, or manual kubeconfig-based deploys.

---

## Quick start — Run locally with Docker

1) Clone the repo:

```bash
git clone https://github.com/OpsOura/WanderList-Capstone.git
cd WanderList-Capstone
```

2) Create a `.env` file (example):

```
DB_HOST=localhost
DB_USER=wanderuser
DB_PASS=wanderpass
DB_NAME=wanderlistdb
PORT=3000
```

3) Start Postgres in Docker (recommended):

```bash
docker run -d \
	--name wander-postgres \
	-e POSTGRES_USER=wanderuser \
	-e POSTGRES_PASSWORD=wanderpass \
	-e POSTGRES_DB=wanderlistdb \
	-p 5432:5432 \
	postgres:13
```

Alternatively, run the app and DB together with `docker-compose` (recommended for development).

4) Build and run the app container:

```bash
docker build -t wanderlist-app .
docker run -d -p 3000:3000 --env-file .env --name wanderlist-app wanderlist-app
```

Open http://localhost:3000

---

## Part 1 — Local development (details)

This project is designed to run fully containerized. If you run the app inside Docker you do NOT need Node/npm on the host. If you want to run the app on the host for development, install Node.js and run `npm install`.

Recommended Dockerfile (production-friendly):

```dockerfile
FROM node:16
WORKDIR /app
COPY package*.json ./
RUN npm ci --production
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
```

Optional helper `build_run.sh` should:
- Build the image
- Stop and remove the prior container
- Run the new container and tail logs

---

## Part 2 — Containerization & Registry

Build locally and push to DockerHub when ready:

```bash
docker build -t wanderlist-app .
docker run -d -p 3000:3000 wanderlist-app

docker tag wanderlist-app <your-dockerhub-username>/wanderlist-app:v1
docker push <your-dockerhub-username>/wanderlist-app:v1
```

---

## Part 3 — Kubernetes (Minikube)

Create Kubernetes manifests in a `k8s/` folder: `deployment.yml`, `service.yml`, `configmap.yml`, `secret.yml`.

Start Minikube and apply manifests:

```bash
minikube start --memory=4096 --cpus=2
kubectl apply -f k8s/deployment.yml
kubectl apply -f k8s/service.yml
kubectl apply -f k8s/configmap.yml
kubectl apply -f k8s/secret.yml
kubectl get pods
kubectl get svc
minikube service wanderlist-svc
```

Notes:
- Use your DockerHub image or load the local image into minikube (`minikube image load ...`).
- Keep manifests simple and readable for the course — no Helm.

---

## Part 4 — Automating with Ansible

Create an Ansible playbook `deploy_wanderlist.yml` that:
- Installs Docker and Minikube on target host(s)
- Copies `k8s/` manifests to the target
- Executes `kubectl apply -f` on the target

Run the playbook:

```bash
ansible-playbook deploy_wanderlist.yml -i hosts
```

---

## Part 5 — CI/CD (GitHub Actions, self-hosted runner pattern)

Workflow responsibilities:
- Build Docker image on push
- Push image to DockerHub
- (Deployment) Trigger a step on a self-hosted runner with kubectl and Docker to apply manifests

Security note: this guide avoids storing secrets in GitHub; recommended approaches:
- Self-hosted runner with kubeconfig & Docker access
- External CI with encrypted variables
- Manual deploy from a trusted machine using kubeconfig

---

## Part 6 — Monitoring & Logging

Deploy Prometheus + Grafana using manifests or operator bundles (no Helm required). Configure scraping for the app and kubernetes components.

Repository helper scripts:
- `scripts/monitor_system.sh` — shell-based system metrics snapshot (CPU, memory, load, disk). Use this as the Bash-only monitor for course exercises. It appends to `logs/system_monitor.log` and is intended to run hourly via cron or systemd.
- `scripts/monitor_docker.py` — Python script (optional) that appends timestamped `docker ps -a` snapshots to `logs/docker_monitor.log` (use when you need container-level snapshots).

Cron example (hourly):

```cron
0 * * * * /usr/bin/env bash /path/to/repo/scripts/monitor_system.sh
```

Systemd example: create `system-monitor.service` and `system-monitor.timer` to run hourly.

Remember to rotate `logs/system_monitor.log`.

---

## Part 7 — Final Deliverables

From your fork submit:

1) Repository artifacts:
- `Dockerfile`
- `build_run.sh` (or equivalent)
- `k8s/` manifests (deployment.yml, service.yml, configmap.yml, secret.yml)
- `deploy_wanderlist.yml` (Ansible playbook)
- `.github/workflows/ci-cd.yml` (sample workflow for self-hosted runner)
- `scripts/monitor_system.sh` (Bash system-monitor)
- `scripts/monitor_docker.py` (optional Python container snapshots)

2) Screenshots:
- App running in Docker
- App running on Kubernetes
- Grafana dashboard
- Output from `scripts/check_db.sh`

3) Short report: commands used, tools installed, issues and resolutions.

---
