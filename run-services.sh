#!/bin/bash

# ============================================================================
# Docker Compose Service Management Script
# ============================================================================
# Usage: ./run-services.sh [SERVICE] [COMMAND]
# 
# Services:
#   all            - All services (default)
#   postgres       - PostgreSQL database
#   pgadmin        - pgAdmin web interface
#   redis          - Redis message broker
#   airflow        - All Airflow services
#   airflow-web    - Airflow webserver only
#   airflow-scheduler - Airflow scheduler only
#   airflow-worker - Airflow worker only
#   airflow-triggerer - Airflow triggerer only
#
# Commands:
#   start      - Create directories and start services
#   stop       - Stop services
#   restart    - Restart services
#   logs       - View logs from services
#   status     - Show status of services
#   clean      - Stop services and remove volumes (WARNING: deletes data)
#   deep-clean - Remove everything including images, networks, and directories
#
# Examples:
#   ./run-services.sh postgres start
#   ./run-services.sh airflow stop
#   ./run-services.sh airflow-web logs
#   ./run-services.sh all status
#   ./run-services.sh start              # same as: all start
#   ./run-services.sh clean              # same as: all clean
# ============================================================================

# Parse arguments - support both orders
if [ $# -eq 0 ]; then
    SERVICE="all"
    ACTION="start"
elif [ $# -eq 1 ]; then
    # Check if it's a service or command
    case "$1" in
        start|stop|restart|logs|status|clean|deep-clean)
            SERVICE="all"
            ACTION="$1"
            ;;
        *)
            SERVICE="$1"
            ACTION="start"
            ;;
    esac
else
    SERVICE="$1"
    ACTION="$2"
fi

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

create_directories() {
    echo -e "${BLUE}======================================"
    echo 'Creating required directories...'
    echo -e "======================================${NC}"
    
    mkdir -p dags logs plugins config init-scripts
    
    if [ -d "dags" ] && [ -d "logs" ] && [ -d "plugins" ] && [ -d "config" ] && [ -d "init-scripts" ]; then
        echo -e "${GREEN}✓ All directories created successfully:${NC}"
        echo "  - dags/          (Airflow DAG definitions)"
        echo "  - logs/          (Airflow task logs)"
        echo "  - plugins/       (Airflow custom plugins)"
        echo "  - config/        (Airflow configuration files)"
        echo "  - init-scripts/  (PostgreSQL init scripts)"
    else
        echo -e "${RED}✗ Error: Failed to create one or more directories${NC}"
        exit 1
    fi
    echo ""
}

get_service_names() {
    case "$1" in
        all)
            echo ""
            ;;
        postgres)
            echo "postgres"
            ;;
        pgadmin)
            echo "pgadmin"
            ;;
        redis)
            echo "redis"
            ;;
        airflow)
            echo "airflow-webserver airflow-scheduler airflow-worker airflow-triggerer"
            ;;
        airflow-web|airflow-webserver)
            echo "airflow-webserver"
            ;;
        airflow-scheduler)
            echo "airflow-scheduler"
            ;;
        airflow-worker)
            echo "airflow-worker"
            ;;
        airflow-triggerer)
            echo "airflow-triggerer"
            ;;
        airflow-init)
            echo "airflow-init"
            ;;
        *)
            echo -e "${RED}✗ Unknown service: $1${NC}"
            echo "Valid services: all, postgres, pgadmin, redis, airflow, airflow-web, airflow-scheduler, airflow-worker, airflow-triggerer"
            exit 1
            ;;
    esac
}

perform_action() {
    local services=$(get_service_names "$SERVICE")
    local service_display="$SERVICE"
    
    case "$ACTION" in
        start)
            if [ "$SERVICE" = "all" ]; then
                create_directories
            fi
            
            echo -e "${BLUE}======================================"
            echo "Starting: $service_display"
            echo -e "======================================${NC}"
            
            if [ -z "$services" ]; then
                docker compose -f compose.yml up -d
            else
                docker compose -f compose.yml up -d $services
            fi
            
            echo ""
            echo "Waiting for services to initialize..."
            sleep 2
            echo ""
            
            if [ -z "$services" ]; then
                docker compose -f compose.yml ps
            else
                docker compose -f compose.yml ps $services
            fi
            
            echo ""
            echo -e "${GREEN}======================================"
            echo "✓ $service_display started successfully!"
            echo -e "======================================${NC}"
            ;;
        
        stop)
            echo -e "${BLUE}======================================"
            echo "Stopping: $service_display"
            echo -e "======================================${NC}"
            
            if [ -z "$services" ]; then
                docker compose -f compose.yml down
            else
                docker compose -f compose.yml stop $services
            fi
            
            echo ""
            echo -e "${GREEN}✓ $service_display stopped${NC}"
            ;;
        
        restart)
            echo -e "${BLUE}======================================"
            echo "Restarting: $service_display"
            echo -e "======================================${NC}"
            
            if [ -z "$services" ]; then
                docker compose -f compose.yml restart
            else
                docker compose -f compose.yml restart $services
            fi
            
            echo ""
            echo "Waiting for services to restart..."
            sleep 2
            echo ""
            
            if [ -z "$services" ]; then
                docker compose -f compose.yml ps
            else
                docker compose -f compose.yml ps $services
            fi
            
            echo ""
            echo -e "${GREEN}✓ $service_display restarted${NC}"
            ;;
        
        logs)
            echo -e "${BLUE}======================================"
            echo "Showing logs for: $service_display (Ctrl+C to exit)"
            echo -e "======================================${NC}"
            
            if [ -z "$services" ]; then
                docker compose -f compose.yml logs -f
            else
                docker compose -f compose.yml logs -f $services
            fi
            ;;
        
        status)
            echo -e "${BLUE}======================================"
            echo "Status: $service_display"
            echo -e "======================================${NC}"
            
            if [ -z "$services" ]; then
                docker compose -f compose.yml ps
            else
                docker compose -f compose.yml ps $services
            fi
            ;;
        
        clean)
            echo -e "${YELLOW}======================================"
            echo "⚠️  WARNING: Data Cleanup for $service_display"
            echo -e "======================================${NC}"
            echo "This will stop and remove data for: $service_display"
            echo ""
            read -p "Are you sure? (yes/no): " confirm
            
            if [ "$confirm" = "yes" ]; then
                echo ""
                echo "Cleaning up..."
                
                if [ -z "$services" ]; then
                    docker compose -f compose.yml down -v
                else
                    docker compose -f compose.yml stop $services
                    docker compose -f compose.yml rm -f $services
                fi
                
                echo ""
                echo -e "${GREEN}✓ $service_display cleaned${NC}"
            else
                echo ""
                echo -e "${GREEN}✓ Clean operation cancelled${NC}"
            fi
            ;;
        
        deep-clean)
            if [ "$SERVICE" != "all" ]; then
                echo -e "${RED}✗ Deep clean is only available for 'all' services${NC}"
                exit 1
            fi
            
            echo -e "${RED}======================================"
            echo '⚠️  DANGER: Complete System Cleanup'
            echo -e "======================================${NC}"
            echo "This will permanently delete:"
            echo "  • All containers"
            echo "  • All volumes (PostgreSQL data, pgAdmin settings)"
            echo "  • All networks"
            echo "  • All downloaded images"
            echo "  • All local directories (dags/, logs/, plugins/, config/, init-scripts/)"
            echo ""
            echo -e "${RED}🔴 THIS CANNOT BE UNDONE!${NC}"
            echo ""
            read -p "Type 'DELETE EVERYTHING' to confirm: " confirm
            
            if [ "$confirm" = "DELETE EVERYTHING" ]; then
                echo ""
                echo "Step 1/6: Stopping and removing containers, volumes, and networks..."
                docker compose -f compose.yml down -v --remove-orphans
                
                echo ""
                echo "Step 2/6: Removing Docker images..."
                IMAGES=$(docker compose -f compose.yml config | grep 'image:' | awk '{print $2}' | sort -u)
                if [ -n "$IMAGES" ]; then
                    echo "$IMAGES" | xargs -r docker rmi -f 2>/dev/null || true
                fi
                
                echo ""
                echo "Step 3/6: Removing custom networks..."
                docker network rm postgres-network 2>/dev/null || true
                
                echo ""
                echo "Step 4/6: Removing local directories..."
                rm -rf dags logs plugins config init-scripts
                echo "  ✓ Removed: dags/"
                echo "  ✓ Removed: logs/"
                echo "  ✓ Removed: plugins/"
                echo "  ✓ Removed: config/"
                echo "  ✓ Removed: init-scripts/"
                
                echo ""
                echo "Step 5/6: Cleaning up dangling resources..."
                docker system prune -f --volumes
                
                echo ""
                echo "Step 6/6: Freeing up unused space..."
                docker volume prune -f
                docker network prune -f
                
                echo ""
                echo -e "${GREEN}======================================"
                echo '✓ Deep clean completed!'
                echo -e "======================================${NC}"
                echo "Run './run-services.sh all start' to start fresh."
                
            else
                echo ""
                echo -e "${GREEN}✓ Deep clean cancelled${NC}"
            fi
            ;;
        
        *)
            echo -e "${RED}✗ Unknown action: $ACTION${NC}"
            echo ""
            echo "Valid commands: start, stop, restart, logs, status, clean, deep-clean"
            exit 1
            ;;
    esac
}

# Show help if requested
if [ "$SERVICE" = "help" ] || [ "$SERVICE" = "--help" ] || [ "$SERVICE" = "-h" ]; then
    echo "Usage: $0 [SERVICE] [COMMAND]"
    echo ""
    echo "Services:"
    echo "  all              - All services (default)"
    echo "  postgres         - PostgreSQL database"
    echo "  pgadmin          - pgAdmin web interface"
    echo "  redis            - Redis message broker"
    echo "  airflow          - All Airflow services"
    echo "  airflow-web      - Airflow webserver only"
    echo "  airflow-scheduler - Airflow scheduler only"
    echo "  airflow-worker   - Airflow worker only"
    echo "  airflow-triggerer - Airflow triggerer only"
    echo ""
    echo "Commands:"
    echo "  start      - Create directories and start services"
    echo "  stop       - Stop services"
    echo "  restart    - Restart services"
    echo "  logs       - View logs from services"
    echo "  status     - Show status of services"
    echo "  clean      - Stop services and remove volumes (WARNING: deletes data)"
    echo "  deep-clean - Remove everything including images, networks, and directories"
    echo ""
    echo "Examples:"
    echo "  $0 start                    # Start all services"
    echo "  $0 postgres start           # Start only postgres"
    echo "  $0 airflow stop             # Stop all airflow services"
    echo "  $0 airflow-web logs         # View airflow webserver logs"
    echo "  $0 status                   # Show status of all services"
    echo "  $0 all clean                # Clean all services"
    exit 0
fi

# Execute the requested action
perform_action