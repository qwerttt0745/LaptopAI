# LaptopAI

AI-powered laptop recommendation service. Users describe their goals and budget — the AI returns personalized recommendations with filters for RAM, CPU, GPU, and price.

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend | Next.js 14 |
| Backend | FastAPI (Python 3.12) |
| AI Service | Python + Claude/OpenAI API |
| Database | PostgreSQL 16 |
| Cache | Redis 7 |
| CI/CD | GitHub Actions |
| GitOps | Argo CD |
| IaC | Terraform |
| Kubernetes | k3s on AWS EC2 |
| Monitoring | Prometheus + Grafana |

## Getting Started

**Prerequisites:** Docker, Docker Compose, Git
```bash
git clone https://github.com/YOUR_USERNAME/LaptopAI.git
cd LaptopAI
cp .env.example .env
docker compose up -d
```

| Service | URL |
|---|---|
| Frontend | http://localhost:3000 |
| Backend API | http://localhost:8000 |
| Swagger Docs | http://localhost:8000/docs |
| AI Service | http://localhost:8001 |

## Architecture
```
GitHub → GitHub Actions → AWS ECR (Docker images)
                                  ↓
                           Argo CD (GitOps)
                                  ↓
                          k3s on AWS EC2
                          ├── namespace: dev
                          └── namespace: prod
```

## Repository Structure
```
LaptopAI/
├── .github/workflows/    # GitHub Actions pipelines
├── frontend/             # Next.js 14
├── backend/              # FastAPI
├── ai-service/           # AI microservice
├── infra/                # Terraform (AWS)
├── k8s/                  # Helm charts + Argo CD
└── scripts/              # Utility scripts
```

## CI/CD Pipeline

1. `git push` → lint + test
2. Merge to `develop` → Docker build → push to AWS ECR
3. Image tag updated in `k8s/helm/*/values.yaml`
4. Argo CD detects change → auto-deploy to `dev`
5. Git tag `v*.*.*` → manual approval → deploy to `prod`

## Branch Strategy

| Branch | Purpose |
|---|---|
| `main` | Production, merge only |
| `develop` | Main development branch |
| `feature/*` | New features |

Commits follow [Conventional Commits](https://www.conventionalcommits.org/) — `feat:`, `fix:`, `ci:`, `infra:`, `docs:`