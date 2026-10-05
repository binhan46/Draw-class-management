SHELL := /bin/bash

# Đọc cấu hình từ .env nếu tồn tại
ifneq (,$(wildcard ./.env))
    include .env
    export
endif

# Cổng mặc định nếu chưa được đặt trong .env
BACKEND_PORT ?= 3001
FRONTEND_PORT ?= 3000
SERVICES ?=

.PHONY: help setup dev dev-be dev-fe docker-up docker-down docker-logs docker-restart clean

help: ## Hiển thị danh sách các lệnh có sẵn
	@echo "================================================================="
	@echo "                 Draw Class Management Makefile                  "
	@echo "================================================================="
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

setup: ## Khởi tạo dự án: copy .env, pnpm install, chạy docker services
	@echo "==> [1/3] Thiết lập các file cấu hình môi trường (.env)..."
	@if [ ! -f .env ]; then \
		if [ -f env.example ]; then \
			cp env.example .env && echo "    Đã tạo .env từ env.example"; \
		elif [ -f .env.example ]; then \
			cp .env.example .env && echo "    Đã tạo .env từ .env.example"; \
		fi \
	else \
		echo "    File .env đã tồn tại, bỏ qua bước copy."; \
	fi
	@if [ -f backend/env.example ] && [ ! -f backend/.env ]; then \
		cp backend/env.example backend/.env && echo "    Đã tạo backend/.env từ backend/env.example"; \
	fi
	@if [ -f frontend/env.example ] && [ ! -f frontend/.env ]; then \
		cp frontend/env.example frontend/.env && echo "    Đã tạo frontend/.env từ frontend/env.example"; \
	fi
	@echo ""
	@echo "==> [2/3] Cài đặt dependencies với pnpm..."
	@pnpm install
	@echo ""
	@echo "==> [3/3] Khởi động các dịch vụ Docker (MySQL và các service khác nếu có)..."
	@docker compose up -d $(SERVICES)
	@echo ""
	@echo "==> Setup hoàn tất! Bạn có thể chạy 'make dev' để bắt đầu phát triển."

dev: ## Chạy giao diện Turborepo TUI đồng thời Backend và Frontend
	@pnpm exec turbo dev

dev-be: ## Chỉ chạy riêng Backend (NestJS)
	@echo "==> Khởi động Backend trên port $(BACKEND_PORT)..."
	@cd backend && PORT=$(BACKEND_PORT) pnpm run start:dev

dev-fe: ## Chỉ chạy riêng Frontend (Next.js)
	@echo "==> Khởi động Frontend trên port $(FRONTEND_PORT)..."
	@cd frontend && PORT=$(FRONTEND_PORT) pnpm run dev

docker-up: ## Khởi động tất cả các dịch vụ Docker trong docker-compose.yml
	@docker compose up -d $(SERVICES)

docker-down: ## Dừng và gỡ bỏ tất cả các container Docker
	@docker compose down

docker-logs: ## Xem log các container Docker (ví dụ: make docker-logs hoặc make docker-logs SERVICES=mysql)
	@docker compose logs -f $(SERVICES)

docker-restart: ## Khởi động lại các container Docker
	@docker compose restart $(SERVICES)

clean: ## Dọn dẹp node_modules và build caches
	@echo "==> Đang dọn dẹp node_modules và build cache..."
	@rm -rf node_modules .turbo
	@rm -rf backend/node_modules backend/dist
	@rm -rf frontend/node_modules frontend/.next
	@echo "==> Dọn dẹp hoàn tất."
