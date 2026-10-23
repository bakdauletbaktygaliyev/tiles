COMPOSE   ?= docker compose
SOURCE    ?= kazakhstan-latest.osm.pbf
SOURCE_URL ?= https://download.geofabrik.de/asia/kazakhstan-latest.osm.pbf
REGION    ?= almaty.osm.pbf
BBOX ?= 76.529388,43.132059,77.343750,43.389082
FLEX_CONFIG ?= /config/roads.lua
TEST_DATABASE_URL ?= postgres://tiles:tiles@localhost:5432/tiles
DATABASE_URL ?= postgres://tiles:tiles@localhost:5432/tiles

# BBOX      ?= 76.75,43.12,77.15,43.42
DB_USER ?= tiles
DB_NAME ?= tiles


.PHONY: help up down download info extract import psql logs clean build run test

help:
	@echo "make up        start PostGIS"
	@echo "make down      stop containers (keeps data)"
	@echo "make download  fetch $(SOURCE) into data/"
	@echo "make info      show header/bbox of $(REGION)"
	@echo "make extract   cut BBOX from $(SOURCE) into $(REGION)"
	@echo "make import    load $(REGION) into PostGIS with $(FLEX_CONFIG)"
	@echo "make psql      open psql shell"
	@echo "make logs      follow db logs"
	@echo "make clean     remove extracted file"
	@echo "make build     build the Go program into bin/app"
	@echo "make run       run the Go program"
	@echo "make test      run Go tests"

up:
	$(COMPOSE) up -d --wait db

down:
	$(COMPOSE) down

download:
	mkdir -p data
	curl -L -o data/$(SOURCE) $(SOURCE_URL)

info:
	$(COMPOSE) --profile tools run --rm osmium fileinfo $(REGION)

extract:
	$(COMPOSE) --profile tools run --rm osmium extract \
		--set-bounds -b $(BBOX) $(SOURCE) -o $(REGION) --overwrite

import: up
	$(COMPOSE) --profile tools run --rm osm2pgsql \
		-H db -U $(DB_USER) -d $(DB_NAME) -O flex -S $(FLEX_CONFIG) /data/$(REGION)

psql:
	$(COMPOSE) exec db psql -U $(DB_USER) -d $(DB_NAME)

logs:
	$(COMPOSE) logs -f db

clean:
	rm -f data/$(REGION)

build:
	go build -o bin/app .

run:
	DATABASE_URL=$(DATABASE_URL) go run .

test: up
	TEST_DATABASE_URL=$(TEST_DATABASE_URL) go test -v -count=1 ./...
