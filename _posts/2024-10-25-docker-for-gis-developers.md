---
title: "Docker for GIS Developers: A Practical Guide"
date: 2024-10-25 11:00:00 +0200
categories: [DevOps, GIS]
tags: [docker, gis, devops, containers, deployment]
---

## Introduction

Docker has revolutionized how we develop and deploy applications. For GIS developers, Docker offers a consistent environment for running spatial databases, GIS servers, and web applications. This guide covers practical Docker usage for GIS workflows.

## Why Docker for GIS?

### Benefits

1. **Consistent Environments** - Same setup across development, testing, and production
2. **Easy Deployment** - Package your entire GIS stack
3. **Isolation** - Run multiple versions of PostGIS or GeoServer
4. **Reproducibility** - Share exact configurations with team members

## Essential Docker Images for GIS

### PostGIS

The most popular spatial database:

```bash
# Pull PostGIS image
docker pull postgis/postgis:15-3.3

# Run PostGIS container
docker run --name my-postgis \
  -e POSTGRES_PASSWORD=mysecretpassword \
  -p 5432:5432 \
  -d postgis/postgis:15-3.3
```

### GeoServer

Open-source server for sharing geospatial data:

```bash
# Run GeoServer
docker run --name geoserver \
  -p 8080:8080 \
  -d kartoza/geoserver:2.23.0
```

### QGIS Server

Serve QGIS projects as web services:

```bash
docker run --name qgis-server \
  -p 8081:80 \
  -d openquake/qgis-server:latest
```

## Creating a Custom GIS Development Environment

### Dockerfile Example

```dockerfile
FROM python:3.11-slim

# Install GDAL and dependencies
RUN apt-get update && apt-get install -y \
    gdal-bin \
    libgdal-dev \
    python3-gdal \
    && rm -rf /var/lib/apt/lists/*

# Install Python GIS libraries
RUN pip install --no-cache-dir \
    geopandas \
    rasterio \
    shapely \
    fiona \
    pyproj

WORKDIR /app

CMD ["python"]
```

Build and run:

```bash
docker build -t my-gis-env .
docker run -it -v $(pwd):/app my-gis-env
```

## Docker Compose for GIS Stack

Create a complete GIS development stack:

```yaml
version: '3.8'

services:
  postgis:
    image: postgis/postgis:15-3.3
    environment:
      POSTGRES_DB: gisdb
      POSTGRES_USER: gisuser
      POSTGRES_PASSWORD: gispass
    ports:
      - "5432:5432"
    volumes:
      - postgis_data:/var/lib/postgresql/data

  geoserver:
    image: kartoza/geoserver:2.23.0
    ports:
      - "8080:8080"
    environment:
      GEOSERVER_ADMIN_PASSWORD: geoserver
    depends_on:
      - postgis

  django-app:
    build: ./app
    command: python manage.py runserver 0.0.0.0:8000
    volumes:
      - ./app:/code
    ports:
      - "8000:8000"
    depends_on:
      - postgis
    environment:
      DATABASE_URL: postgresql://gisuser:gispass@postgis:5432/gisdb

volumes:
  postgis_data:
```

Run the stack:

```bash
docker-compose up -d
```

## Best Practices

### 1. Use Named Volumes

```bash
docker volume create postgis_data
docker run -v postgis_data:/var/lib/postgresql/data postgis/postgis
```

### 2. Environment Variables

```bash
# .env file
POSTGRES_PASSWORD=secure_password
GEOSERVER_ADMIN_PASSWORD=admin_password
```

### 3. Health Checks

```yaml
services:
  postgis:
    image: postgis/postgis:15-3.3
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5
```

### 4. Resource Limits

```yaml
services:
  postgis:
    image: postgis/postgis:15-3.3
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 4G
```

## Common GIS Docker Workflows

### Workflow 1: Data Processing Pipeline

```bash
# Process raster data
docker run --rm \
  -v $(pwd)/data:/data \
  osgeo/gdal:alpine-normal-latest \
  gdalwarp -t_srs EPSG:4326 /data/input.tif /data/output.tif
```

### Workflow 2: Automated Testing

```yaml
# docker-compose.test.yml
services:
  test:
    build: .
    command: pytest tests/
    environment:
      DATABASE_URL: postgresql://test:test@postgis-test:5432/testdb
    depends_on:
      - postgis-test

  postgis-test:
    image: postgis/postgis:15-3.3
    environment:
      POSTGRES_DB: testdb
      POSTGRES_USER: test
      POSTGRES_PASSWORD: test
```

### Workflow 3: Production Deployment

```bash
# Build production image
docker build -t my-gis-app:prod -f Dockerfile.prod .

# Push to registry
docker tag my-gis-app:prod registry.example.com/my-gis-app:prod
docker push registry.example.com/my-gis-app:prod

# Deploy
docker pull registry.example.com/my-gis-app:prod
docker run -d --name gis-app registry.example.com/my-gis-app:prod
```

## Troubleshooting

### Check Container Logs

```bash
docker logs postgis
docker logs -f geoserver  # Follow logs
```

### Access Container Shell

```bash
docker exec -it postgis bash
```

### Inspect Container

```bash
docker inspect postgis
```

### Clean Up

```bash
# Remove stopped containers
docker container prune

# Remove unused images
docker image prune

# Remove unused volumes
docker volume prune
```

## Performance Tips

1. **Use SSD for volumes** - Especially for databases
2. **Allocate enough memory** - PostGIS needs RAM
3. **Use multi-stage builds** - Smaller images
4. **Cache layers** - Order Dockerfile commands properly

## Conclusion

Docker simplifies GIS development and deployment significantly. By containerizing your GIS stack, you ensure consistency, improve collaboration, and streamline deployment processes.

## Resources

- [Docker Documentation](https://docs.docker.com/)
- [PostGIS Docker Hub](https://hub.docker.com/r/postgis/postgis)
- [Kartoza GeoServer](https://hub.docker.com/r/kartoza/geoserver)
- [OSGEO GDAL](https://hub.docker.com/r/osgeo/gdal)
