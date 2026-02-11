# Alpinehelloworld – CI/CD with Jenkins, Docker, and Heroku

[![Build Status](http://192.168.57.100:8080/buildStatus/icon?job=alpinehelloworld)](http://192.168.57.100:8080/job/alpinehelloworld/)

This project demonstrates a **complete CI/CD pipeline** for a containerized application, from source code to production deployment, using **Jenkins**, **Docker**, **Docker Hub**, and **Heroku**.

It is a hands-on **DevOps / CI-CD learning project**, focused on:
- Jenkins declarative pipelines
- Running Docker from Jenkins
- Secure credentials management
- Deploying Docker images to Heroku
- Handling CI agents and tooling versions properly

---

## 🧱 Global Architecture

```

GitHub (push)
↓
Jenkins (Declarative Pipeline)
↓
Docker build & test
↓
Docker Hub
↓
Heroku (Staging / Production)

```

---

## 📦 Application Overview

- Simple Python web application returning:
```

Hello world!

````
- Application server: **Gunicorn**
- Base image: **Alpine Linux**
- Internal application port: **5000**
- External port is injected via the `$PORT` environment variable (Heroku-compatible)

---

## 🐳 Docker

### Dockerfile Highlights

- Base image: `alpine:latest`
- Installs:
- `python3`
- `pip`
- `bash`
- Creates a Python virtual environment
- Installs dependencies from `requirements.txt`
- Runs the application with **Gunicorn**
- Uses a **non-root user** for security

---

## 🤖 Jenkins

### Jenkins Running in Docker

Jenkins itself runs inside a Docker container with:
- Access to the Docker daemon via `/var/run/docker.sock`
- Docker CLI available inside the Jenkins container

> ⚠️ Mounting the Docker socket alone is not sufficient — the Docker CLI must also be installed in the Jenkins container.

---

## 🔧 Required Jenkins Configuration (MANDATORY)

### 1️⃣ Jenkins Build Parameters

The pipeline relies on **mandatory Jenkins parameters**.  
They must be defined **before running the pipeline**.

In Jenkins:
1. Open the job
2. Click **Configure**
3. Enable **This project is parameterized**
4. Add the following parameters:

#### 🔹 `ID_DOCKER_PARAMS`
- **Type**: String Parameter
- **Description**: Docker Hub username
- **Example value**:
```text
beranger26
````

Used for:

* Docker image tagging
* Docker Hub authentication
* Publishing images

---

#### 🔹 `PORT_EXPOSED`

* **Type**: String Parameter
* **Description**: Port exposed on the Jenkins host
* **Example value**:

  ```text
  80
  ```

Used for:

* Local container port mapping
* HTTP testing via `curl`

---

### 2️⃣ Required Jenkins Plugin: Docker Pipeline

This project **requires** the Docker Pipeline plugin.

* **Plugin name**: Docker Pipeline
* **Plugin ID**: `docker-workflow`

#### Installation steps:

1. Jenkins → **Manage Jenkins**
2. **Plugins**
3. **Available plugins**
4. Search for **Docker Pipeline**
5. Install
6. Restart Jenkins

> Without this plugin, Jenkins will not recognize:
>
> ```groovy
> agent { docker { ... } }
> ```

---

### 3️⃣ Jenkins Prerequisites Summary

| Requirement                      | Mandatory |
| -------------------------------- | --------- |
| Jenkins running in Docker        | ✅         |
| Docker CLI available in Jenkins  | ✅         |
| `/var/run/docker.sock` mounted   | ✅         |
| Docker Pipeline plugin installed | ✅         |
| `ID_DOCKER_PARAMS` parameter     | ✅         |
| `PORT_EXPOSED` parameter         | ✅         |
| Docker Hub credentials           | ✅         |
| `HEROKU_API_KEY` credential      | ✅         |

---

## 🔁 Jenkins Pipeline Overview

The pipeline is **declarative** and parameterized.

### Pipeline Stages

1. **Build image**

   * Builds the Docker image
2. **Run container**

   * Runs the container locally
3. **Test image**

   * Performs an HTTP test using `curl`
4. **Clean container**

   * Stops and removes the container
5. **Login & Push Docker Hub**

   * Pushes the image to Docker Hub
6. **Deploy to Staging**

   * Deploys automatically to Heroku (branch `master`)
7. **Deploy to Production**

   * Deploys automatically to Heroku (branch `production`)

---

## 🔐 Credentials Management

All sensitive data is handled via **Jenkins Credentials**:

* Docker Hub credentials
* `HEROKU_API_KEY`

No secrets are stored in the repository.

---

## ☁️ Deployment to Heroku

* Deployment uses **Heroku Container Registry**
* Commands used:

  * `heroku container:login`
  * `heroku container:push`
  * `heroku container:release`
* Deployments are **idempotent**:

  * Existing apps are not recreated
  * Identical images are not redeployed unnecessarily

---

## 🌍 Exposing Jenkins with ngrok

Since Jenkins runs locally (or inside a VM), **ngrok** is used to expose Jenkins to GitHub in order to receive **webhooks**.

### Starting ngrok

```bash
export NGROK_AUTHTOKEN="YOUR_TOKEN_HERE"

docker run -it --network host \
  -e NGROK_AUTHTOKEN=$NGROK_AUTHTOKEN \
  ngrok/ngrok http 8080
```

### Usage

* ngrok provides a public HTTPS URL
* This URL is configured in **GitHub Webhooks**
* Each `git push` automatically triggers the Jenkins pipeline

---

## 🧪 Testing

### Local HTTP Test

```bash
curl http://localhost:<PORT_EXPOSED>
```

Expected output:

```text
Hello world!
```

---

## ✅ Final Outcome

* ✔ Automated Docker build
* ✔ Automated container testing
* ✔ Image pushed to Docker Hub
* ✔ Automatic deployment to Heroku (staging & production)
* ✔ GitHub webhooks working via ngrok
* ✔ Fully reproducible and parameterized pipeline

---

## 🎯 Learning Objectives Achieved

* Understanding Jenkins declarative pipelines
* Running Docker commands from Jenkins
* Managing CI credentials securely
* Deploying containerized applications
* Handling CI tooling versions correctly
* Applying DevOps best practices (idempotency, isolation, automation)

---
