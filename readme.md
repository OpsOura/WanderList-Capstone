
# Wanderlist DevOps Final Project

## Introduction
This repository contains the Wanderlist application and course material for the DevOps final project. The goal is to practice end-to-end DevOps workflows: containerization, orchestration, automation, CI/CD, and monitoring.

Key technologies used in the course:
- Docker & Docker Compose
- Kubernetes (Minikube) + kubectl
- Ansible
- GitHub Actions (self-hosted runner pattern recommended)
- Prometheus & Grafana for monitoring
- PostgreSQL container for the database

Important project constraints:
- PostgreSQL should be run in Docker (do not require manual host installation).
- Helm is intentionally not used in the course materials (we prefer plain manifests for clarity).
- README guidance avoids using GitHub Secrets — prefer a self-hosted runner or external secure CI variables.

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

Or use docker-compose (recommended for development). Create `docker-compose.yml` and run `docker-compose up -d --build`.

4) Build and run the app container:

```bash
docker build -t wanderlist-app .
docker run -d -p 3000:3000 --env-file .env --name wanderlist-app wanderlist-app
```

Open http://localhost:3000

---

## Part 1 – Local development (details)

This project is designed to run fully containerized. If you build and run the app inside Docker, you do NOT need to install Node.js or npm on the host. If you do want to run locally on host for development, install node and npm, then run `npm install`.

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

Example `build_run.sh` (helper script to build and run locally):

```bash
#!/usr/bin/env bash
set -e
IMAGE_TAG=wanderlist-app
CONTAINER_NAME=wanderlist

docker build -t ${IMAGE_TAG} .
if docker ps -a --format "{{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
  docker stop ${CONTAINER_NAME} || true
  docker rm ${CONTAINER_NAME} || true
fi
docker run -d --name ${CONTAINER_NAME} -p 3000:3000 ${IMAGE_TAG}
docker logs -f ${CONTAINER_NAME}
```

---

## Part 2 – Kubernetes (Minikube)

Start Minikube and apply manifests (we avoid Helm in this course):

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

Example `deployment.yml` should reference your DockerHub image (or a local image loaded into minikube).

---

## Part 3 – Ansible automation

Write `deploy_wanderlist.yml` to perform these steps on a target machine:
- Install Docker and Minikube
- Copy Kubernetes manifests
- Apply manifests with kubectl

Run with:

```bash
ansible-playbook deploy_wanderlist.yml -i hosts
```

---

## Part 4 – CI/CD (GitHub Actions, self-hosted runner pattern)

The sample workflow should:
- Build the Docker image
- Push the image to DockerHub
- Trigger a deployment step (run on a self-hosted runner which has kubectl and docker access)

This repository intentionally avoids using GitHub Secrets for the student exercises. Recommended secure patterns:
- Self-hosted runner with access to your kubeconfig and docker credentials
- Use a CI provider that supports encrypted variables (if not using a runner)
- Manual deployment from a trusted machine with kubeconfig

---

## Part 5 – Monitoring & Logging

We use Prometheus + Grafana without Helm for clarity. Deploy Prometheus and Grafana using manifests or operator bundles and configure scraping for the cluster and app.

In addition to Prometheus/Grafana, the repo includes two helper scripts:

- `scripts/check_db.sh` — a small shell script to validate database readiness. It prefers checking inside the Postgres container using `docker exec` and `pg_isready`, and falls back to host `pg_isready`.
- `scripts/monitor_docker.py` — a Python script that appends a timestamped snapshot of `docker ps -a` output to `logs/docker_monitor.log`. It is intended to be run hourly via cron or a systemd timer.

Cron example (run at the top of every hour):

```cron
0 * * * * /usr/bin/env python3 /path/to/repo/scripts/monitor_docker.py
```

Systemd timer example: create `docker-monitor.service` and `docker-monitor.timer` to run the script hourly.

Important: ensure the user running these tasks has permission to run `docker ps` and `docker exec` (docker group or root). Add log rotation for `logs/docker_monitor.log` as needed.

---

## Part 6 – Final Deliverables

Submit the following from your fork:

1) Repository with these artifacts:
- `Dockerfile`
- `build_run.sh` (or equivalent build script)
- `k8s/` manifests (deployment.yml, service.yml, configmap.yml, secret.yml)
- `deploy_wanderlist.yml` (Ansible playbook)
- `.github/workflows/ci-cd.yml` (sample workflow for self-hosted runner)
- `scripts/check_db.sh`
- `scripts/monitor_docker.py`

2) Screenshots showing:
- App running in Docker
- App running on Kubernetes
- Grafana dashboard with metrics
- Output from `scripts/check_db.sh`

3) Short report describing:
- Commands used
- Tools installed
- Problems encountered and their resolution

---

## Notes & Next Steps

- If you'd like, I can:
  - add a `Dockerfile` and a `docker-compose.yml` to the repo,
  - add example `k8s/` manifests into the `k8s/` folder,
  - make `scripts/*.sh` executable (`chmod +x`) and add a basic `logrotate` config for `logs/docker_monitor.log`, or
  - create a sample `build_run.sh` and a sample `.github/workflows/ci-cd.yml` wired for a self-hosted runner.

Reply with which of these you'd like me to add next and I'll create the files and run quick validations.

			POSTGRES_PASSWORD: wanderpass
			POSTGRES_DB: wanderlistdb
		ports:
			- "5432:5432"
		volumes:
			- db-data:/var/lib/postgresql/data

volumes:
	db-data:
```

Start it with:

```bash
docker-compose up -d
```

Notes on connectivity

- If you map the DB port to the host (examples above), set `DB_HOST=localhost` in `.env`.
- If you run your app in a separate Docker network alongside the DB (for example with `docker-compose` that defines both services), use the DB service name (e.g. `DB_HOST=db`).
- The `POSTGRES_*` environment variables create the initial DB and user, so you do not need to run `psql` to create them manually unless you want custom roles.

Step 5: Configure Environment

Create a `.env` file in the project root:

```
DB_HOST=localhost
DB_USER=wanderuser
DB_PASS=wanderpass
DB_NAME=wanderlistdb
PORT=3000
```

Step 6: Run Application

```bash
# If using docker-compose from this repo
docker-compose up -d --build
# Or run the container directly after building the image
# docker build -t wanderlist-app .
# docker run -d -p 3000:3000 wanderlist-app
```

Open in browser:

http://localhost:3000

If you see the app running, Part 1 is complete.

---

## Part 2 – Containerization with Docker

Step 1: Write Dockerfile

Suggested Dockerfile:

```dockerfile
FROM node:16
WORKDIR /app
COPY package*.json ./
RUN npm ci --production
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
```

Save it as `Dockerfile` in the project root.

Step 2: Build & Run Manually (once)

```bash
docker build -t wanderlist-app .
docker run -d -p 3000:3000 wanderlist-app
```

Verify in browser: http://localhost:3000

Step 3: Automate with Bash Script

Create `build_run.sh` that:

- Builds the image
- Stops and removes any old container
- Runs the new container
- Prints logs to screen

Example `build_run.sh` (make executable with `chmod +x build_run.sh`):

```bash
#!/usr/bin/env bash
set -e
IMAGE_TAG=wanderlist-app
CONTAINER_NAME=wanderlist

docker build -t ${IMAGE_TAG} .
if docker ps -a --format "{{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
	docker stop ${CONTAINER_NAME} || true
	docker rm ${CONTAINER_NAME} || true
fi
docker run -d --name ${CONTAINER_NAME} -p 3000:3000 ${IMAGE_TAG}
docker logs -f ${CONTAINER_NAME}
```

Step 4: Push Image to DockerHub

```bash
docker tag wanderlist-app <your-dockerhub-username>/wanderlist-app:v1
docker push <your-dockerhub-username>/wanderlist-app:v1
```

By the end of Part 2, your app is:

- Running in Docker container
- Automated via Bash script
- Available on DockerHub

---

## Part 3 – Kubernetes (Minikube Deployment)

Step 1: Start Minikube

```bash
minikube start --memory=4096 --cpus=2
```

Step 2: Create Kubernetes Manifests

Write YAML files such as `deployment.yml`, `service.yml`, and `configmap.yml`/`secret.yml`.

Example `deployment.yml` (use your DockerHub image `<username>/wanderlist-app:v1`):

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
	name: wanderlist-deployment
spec:
	replicas: 2
	selector:
		matchLabels:
			app: wanderlist
	template:
		metadata:
			labels:
				app: wanderlist
		spec:
			containers:
			- name: wanderlist
				image: <your-dockerhub-username>/wanderlist-app:v1
				ports:
				- containerPort: 3000
				envFrom:
				- configMapRef:
						name: wanderlist-config
				- secretRef:
						name: wanderlist-secret
```

Create a `service.yml` (ClusterIP or NodePort):

```yaml
apiVersion: v1
kind: Service
metadata:
	name: wanderlist-svc
spec:
	type: NodePort
	selector:
		app: wanderlist
	ports:
	- protocol: TCP
		port: 3000
		targetPort: 3000
		nodePort: 30030
```

Create `configmap.yml` / `secret.yml` for DB and env variables.

Step 3: Apply Manifests

```bash
kubectl apply -f deployment.yml
kubectl apply -f service.yml
kubectl apply -f configmap.yml
kubectl apply -f secret.yml
kubectl get pods
kubectl get svc
```

Step 4: Access Application

```bash
minikube service wanderlist-svc
```

By the end of Part 3, your Wanderlist app should be running on Kubernetes (via Minikube) with multiple pods.

---

## Part 4 – Automating with Ansible

Step 1: Setup Ansible

Install Ansible on your control node and configure an inventory file for target hosts.

Step 2: Create Playbook

Write an Ansible playbook `deploy_wanderlist.yml` that:

- Installs Docker and Minikube on the target machine
- Copies Kubernetes manifests to the target
- Applies the manifests using `kubectl`

Example task outline:

```yaml
- hosts: k8s_nodes
	become: yes
	tasks:
		- name: Install Docker
			...
		- name: Install Minikube
			...
		- name: Copy manifests
			copy:
				src: ./k8s/
				dest: /home/ubuntu/k8s/
		- name: Apply manifests
			command: kubectl apply -f /home/ubuntu/k8s/
```

Step 3: Run Playbook

```bash
ansible-playbook deploy_wanderlist.yml -i hosts
```

By the end of Part 4, you should be able to provision and deploy Wanderlist with a single Ansible command.

---

## Part 5 – CI/CD with GitHub Actions

Step 1: Create `.github/workflows/ci-cd.yml`

Workflow should:

- Trigger on push to `main`
- Build Docker image
- Push image to DockerHub
- Apply Kubernetes manifests using `kubectl`

Step 2: Credentials and security (no GitHub secrets in this guide)

This guide deliberately avoids storing credentials in GitHub Secrets. Instead choose one of the following patterns for secure deployment:

- Self-hosted CI runner: run a GitHub Actions runner on a machine that already has `kubectl` and Docker configured; the runner can access local credentials without storing them in GitHub.
- External CI with secure variables: use a CI provider that offers encrypted environment variables (if you prefer not to run a self-hosted runner).
- Manual deploy with local kubeconfig: CI builds and pushes the image to DockerHub, but you run `kubectl apply` from a trusted machine using your local kubeconfig.

