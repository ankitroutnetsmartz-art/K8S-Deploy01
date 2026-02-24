# Multi-Tier Kubernetes Infrastructure Project
**Status:** Production-Ready (Project 5/5)

## 🏗️ Architecture Stack
* **Orchestration:** Kubernetes (Minikube on Ubuntu)
* **Traffic Management:** NGINX Ingress Controller (`azure-site.local`)
* **Scaling:** Horizontal Pod Autoscaler (HPA) targeting 50% CPU
* **Monitoring:** K8s Metrics Server with UI Resource Tracking
* **Storage:** ConfigMap-backed static assets for zero-downtime UI updates

## 🚀 Key Features
1. **Self-Healing:** Readiness and Liveness probes ensure traffic only hits healthy pods.
2. **Auto-Scaling:** Cluster dynamically scales from 2 to 10 replicas based on real-time load.
3. **Professional DNS:** Accessible via host-mapped domain `http://azure-site.local` using L7 routing.
4. **Automated CI/CD:** Unified `deploy_stack.sh` for one-command infrastructure deployment.

## 🛠️ Operational Commands
### Access Frontend
```bash
# Ensure tunnel is active in a separate terminal
minikube tunnel

# Visit in browser
[http://azure-site.local](http://azure-site.local)
