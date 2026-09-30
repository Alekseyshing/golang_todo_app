
include .env
export

export PROJECT_ROOT=$(CURDIR)
export MSYS_NO_PATHCONV=1

env-up:
	@docker compose up -d todoapp-postgres

env-down:
	@docker compose down todoapp-postgres

env-cleanup:
	@read -p "Are you sure you want to delete the database data? [y/N]: " ans; \
	if [ "$$ans" = "y" ]; then \
		docker compose down todoapp-postgres && \
		rm -rf out/pgdata && \
		echo "Environment cleaned up."; \
	else \
		echo "Cleanup aborted."; \
	fi

env-port-forward:
	@docker compose up -d port-forward

env-port-forward-stop:
	@docker compose down port-forward

migrate-create:
	@if [ -z "$(seq)" ]; then \
		echo "Error: Please provide a migration name using for example 'make migrate-create seq=init'"; \
		exit 1; \
	fi;
	MSYS_NO_PATHCONV=1 docker compose run --rm todoapp-postgres-migrate \
		create \
		-ext sql \
		-dir /migrations \
		-seq "$(seq)"

migrate-up:
	@make migrate-action action=up

migrate-down:
	@make migrate-action action=down

migrate-action:
	@if [ -z "$(action)" ]; then \
		echo "Error: Please provide a migration action using for example 'make migrate-action action=up' or 'make migrate-action action=down'"; \
		exit 1; \
	fi; \
	docker compose run --rm todoapp-postgres-migrate \
		-path /migrations \
		-database "postgresql://$(POSTGRES_USER):$(POSTGRES_PASSWORD)@todoapp-postgres:5432/$(POSTGRES_DB)?sslmode=disable" \
		"$(action)"

