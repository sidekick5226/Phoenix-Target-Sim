.PHONY: help install install-backend install-frontend run-backend run-frontend docker-build docker-up docker-down

help:
	@echo "Targets:"
	@echo "  install           Install backend and frontend dependencies"
	@echo "  install-backend   Install backend Python dependencies"
	@echo "  install-frontend  Install frontend npm dependencies"
	@echo "  run-backend       Run FastAPI backend locally"
	@echo "  run-frontend      Run Vite frontend locally"
	@echo "  docker-build      Build Docker images"
	@echo "  docker-up         Start Docker Compose stack"
	@echo "  docker-down       Stop Docker Compose stack"

install: install-backend install-frontend

install-backend:
	cd backend; pip install -r requirements.txt

install-frontend:
	cd frontend; npm install

run-backend:
	cd backend; uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

run-frontend:
	cd frontend; npm run dev

docker-build:
	docker compose build

docker-up:
	docker compose up -d

docker-down:
	docker compose down
