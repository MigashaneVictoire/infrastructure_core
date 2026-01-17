# Infrastructure Core Management 

### Initial Setup
Make all shell scripts executable by running:
```sh
chmod +x set_exec.sh
./set_exec.sh
```

### Core Services
The `run-services.sh` script manages all core infrastructure services including PostgreSQL, PgAdmin, Redis, and Apache Airflow.

**Usage:**
```sh
./run-services.sh [SERVICE] [COMMAND]
```

**Available Services:**
- `all` - All services (default)
- `postgres` - PostgreSQL database
- `pgadmin` - pgAdmin web interface
- `redis` - Redis message broker
- `airflow` - All Airflow services
- `airflow-web` - Airflow webserver only
- `airflow-scheduler` - Airflow scheduler only
- `airflow-worker` - Airflow worker only
- `airflow-triggerer` - Airflow triggerer only

**Available Commands:**
- `start` - Create necessary directories and start services
- `stop` - Stop services
- `restart` - Restart services
- `logs` - View logs from services (Ctrl+C to exit)
- `status` - Show status of services
- `clean` - Stop services and remove volumes ⚠️ **WARNING: Deletes data**
- `deep-clean` - Remove everything including images, networks, and directories ⚠️ **DANGER: Cannot be undone**

**Examples:**
```sh
# Start all infrastructure services
./run-services.sh start

# Start specific services
./run-services.sh postgres start
./run-services.sh airflow start

# Stop specific services
./run-services.sh airflow-web stop
./run-services.sh redis stop

# View logs
./run-services.sh airflow-scheduler logs
./run-services.sh logs  # all services

# Check status
./run-services.sh status
./run-services.sh postgres status

# Restart services
./run-services.sh airflow restart

# Clean up (requires confirmation)
./run-services.sh clean
./run-services.sh postgres clean

# Deep clean everything (requires typing 'DELETE EVERYTHING')
./run-services.sh deep-clean
```

### Directory Structure
When you run `./run-services.sh start` for the first time, the following directories are automatically created:
- `dags/` - Airflow DAG definitions
- `logs/` - Airflow task logs
- `plugins/` - Airflow custom plugins
- `config/` - Airflow configuration files
- `init-scripts/` - PostgreSQL initialization scripts

## Configuration

### Environment Variables
Create a `.env` file in the project root with the following variables:
```env
# PostgreSQL
POSTGRES_VERSION=
POSTGRES_HOST=
POSTGRES_USER=
POSTGRES_PASSWORD=
POSTGRES_DB=
POSTGRES_PORT=
POSTGRES_MAX_CONNECTIONS=
POSTGRES_SHARED_BUFFERS=
POSTGRES_EFFECTIVE_CACHE=
POSTGRES_SHM_SIZE=

# PgAdmin
PGADMIN_VERSION=
PGADMIN_EMAIL=
PGADMIN_PASSWORD=
PGADMIN_PORT=
PGADMIN_SERVER_MODE=
PGADMIN_MASTER_PASSWORD_REQUIRED=

# Redis
REDIS_VERSION=
REDIS_PORT=

# Apache Airflow
AIRFLOW_VERSION=
AIRFLOW_USERNAME=
AIRFLOW_PASSWORD=
AIRFLOW_FERNET_KEY=
AIRFLOW_UID=
AIRFLOW_DB=  # same as POSTGRES_DB
AIRFLOW_EXECUTOR=
AIRFLOW_DAGS_PAUSED_AT_CREATION=
AIRFLOW_LOAD_EXAMPLES=
AIRFLOW_WEBSERVER_PORT=
AIRFLOW_DAGS_DIR=./dags
AIRFLOW_LOGS_DIR=./logs
AIRFLOW_PLUGINS_DIR=./plugins
AIRFLOW_CONFIG_DIR=./config
```