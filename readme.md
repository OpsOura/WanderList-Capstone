# Wanderlist DevOps Final Project

## Project Overview
This repository contains the Wanderlist application and all required files for the DevOps Final Project.  
The project is designed to give you hands-on experience with real-world DevOps practices, tools, and workflows.

By completing this project, you will practice:
- Containerization with Docker
- Orchestration using Kubernetes (Minikube)
- Configuration Management with Ansible
- CI/CD Pipelines using GitHub Actions
- Monitoring and Logging with Prometheus and Grafana
- Python scripting for database validation
- Bash scripting for automation tasks

---

## Project Objectives
- Deploy the Wanderlist app in a containerized environment
- Automate deployments using Kubernetes manifests
- Configure infrastructure tasks using Ansible
- Implement a CI/CD pipeline on GitHub Actions
- Monitor the application using Prometheus and Grafana
- Write simple Python and Bash scripts to extend automation and validation

---

## Student Instructions
1. Fork this repository from the organization into your own GitHub account.
2. Clone your forked repository to your local machine.
3. Follow the project documentation provided separately (step-by-step guide).
4. Implement each stage and commit your changes.
5. Submit the required deliverables as defined in the project instructions.

---

## Part 7 – Final Deliverables

You must submit the following items as proof of completing the Wanderlist DevOps Project:

1. GitHub Repository
	 - Your fork/clone of Wanderlist application
	 - Includes:
		 - Dockerfile
		 - Bash script (`build_run.sh`)
		 - Kubernetes manifests (`deployment.yml`, `service.yml`, etc.)
		 - Ansible playbook (`deploy_wanderlist.yml`)
		 - GitHub Actions workflow (`.github/workflows/ci-cd.yml`)
		 - Shell DB check script (`scripts/check_db.sh`)
		 - Docker monitor script (`scripts/monitor_docker.py`)

2. Screenshots
	 - App running locally on Docker (http://localhost:3000)
	 - App running in Kubernetes (`kubectl get pods` and browser access)
	 - Successful GitHub Actions pipeline run
	 - Grafana dashboard showing `wanderlist` pod metrics
	 - Output of your Python DB check script

3. Written Report (Short)
	 - Tools you installed and used
	 - Commands to reproduce your setup
	 - Any issues you faced and how you solved them

### Submission Checklist

- GitHub repo link with all code/scripts/manifests
- 5 required screenshots
- README or short report

---

## Notes

- Keep commits clear and meaningful.
- Document reproducible commands and configuration in this README or a separate report.
