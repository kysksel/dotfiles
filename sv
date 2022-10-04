#!/usr/bin/bash

UNAMEOUT="$(uname -s)"

# Verify operating system is supported...
case "${UNAMEOUT}" in
    Linux*)             MACHINE=linux;;
    Darwin*)            MACHINE=mac;;
    *)                  MACHINE="UNKNOWN"
esac

if [ "$MACHINE" == "UNKNOWN" ]; then
    echo "Unsupported operating system [$(uname -s)]. Serv supports macOS, Linux, and Windows (WSL2)." >&2

    exit 1
fi

# Determine if stdout is a terminal...
if test -t 1; then
    # Determine if colors are supported...
    ncolors=$(tput colors)

    if test -n "$ncolors" && test "$ncolors" -ge 8; then
        BOLD="$(tput bold)"
        YELLOW="$(tput setaf 3)"
        GREEN="$(tput setaf 2)"
        NC="$(tput sgr0)"
    fi
fi

# Function that prints the available commands...
function display_help {
    echo "Serv"
    echo
    echo "${YELLOW}Usage:${NC}" >&2
    echo "  serv COMMAND [options] [arguments]"
    echo
    echo "Unknown commands are passed to the docker-compose binary."
    echo
    echo "${YELLOW}docker-compose Commands:${NC}"
    echo "  ${GREEN}serv up${NC}        Start the application"
    echo "  ${GREEN}serv up -d${NC}     Start the application in the background"
    echo "  ${GREEN}serv stop${NC}      Stop the application"
    echo "  ${GREEN}serv restart${NC}   Restart the application"
    echo "  ${GREEN}serv ps${NC}        Display the status of all containers"
    echo
    echo "${YELLOW}Artisan Commands:${NC}"
    echo "  ${GREEN}serv artisan ...${NC}          Run an Artisan command"
    echo "  ${GREEN}serv artisan queue:work${NC}"
    echo
    echo "${YELLOW}PHP Commands:${NC}"
    echo "  ${GREEN}serv php ...${NC}   Run a snippet of PHP code"
    echo "  ${GREEN}serv php -v${NC}"
    echo
    echo "${YELLOW}Composer Commands:${NC}"
    echo "  ${GREEN}serv composer ...${NC}                       Run a Composer command"
    echo "  ${GREEN}serv composer require laravel/sanctum${NC}"
    echo
    echo "${YELLOW}Node Commands:${NC}"
    echo "  ${GREEN}serv node ...${NC}         Run a Node command"
    echo "  ${GREEN}serv node --version${NC}"
    echo
    echo "${YELLOW}NPM Commands:${NC}"
    echo "  ${GREEN}serv npm ...${NC}        Run a npm command"
    echo "  ${GREEN}serv npx${NC}            Run a npx command"
    echo "  ${GREEN}serv npm run prod${NC}"
    echo
    echo "${YELLOW}Yarn Commands:${NC}"
    echo "  ${GREEN}serv yarn ...${NC}        Run a Yarn command"
    echo "  ${GREEN}serv yarn run prod${NC}"
    echo
    echo "${YELLOW}Database Commands:${NC}"
    echo "  ${GREEN}serv mysql${NC}     Start a MySQL CLI session within the 'mysql' container"
    echo "  ${GREEN}serv mariadb${NC}   Start a MySQL CLI session within the 'mariadb' container"
    echo "  ${GREEN}serv psql${NC}      Start a PostgreSQL CLI session within the 'pgsql' container"
    echo "  ${GREEN}serv redis${NC}     Start a Redis CLI session within the 'redis' container"
    echo
    echo "${YELLOW}Debugging:${NC}"
    echo "  ${GREEN}serv debug ...${NC}          Run an Artisan command in debug mode"
    echo "  ${GREEN}serv debug queue:work${NC}"
    echo
    echo "${YELLOW}Running Tests:${NC}"
    echo "  ${GREEN}serv test${NC}          Run the PHPUnit tests via the Artisan test command"
    echo "  ${GREEN}serv phpunit ...${NC}   Run PHPUnit"
    echo "  ${GREEN}serv pint ...${NC}      Run Pint"
    echo "  ${GREEN}serv dusk${NC}          Run the Dusk tests (Requires the laravel/dusk package)"
    echo "  ${GREEN}serv dusk:fails${NC}    Re-run previously failed Dusk tests (Requires the laravel/dusk package)"
    echo
    echo "${YELLOW}Container CLI:${NC}"
    echo "  ${GREEN}serv shell${NC}        Start a shell session within the application container"
    echo "  ${GREEN}serv bash${NC}         Alias for 'serv shell'"
    echo "  ${GREEN}serv root-shell${NC}   Start a root shell session within the application container"
    echo "  ${GREEN}serv root-bash${NC}    Alias for 'serv root-shell'"
    echo "  ${GREEN}serv tinker${NC}       Start a new Laravel Tinker session"
    echo
    echo "${YELLOW}Sharing:${NC}"
    echo "  ${GREEN}serv share${NC}   Share the application publicly via a temporary URL"
    echo
    echo "${YELLOW}Binaries:${NC}"
    echo "  ${GREEN}serv bin ...${NC}   Run Composer binary scripts from the vendor/bin directory"
    echo
    echo "${YELLOW}Customization:${NC}"
    echo "  ${GREEN}serv artisan serv:publish${NC}   Publish the Serv configuration files"
    echo "  ${GREEN}serv build --no-cache${NC}       Rebuild all of the Sail containers"

    exit 1
}

# Proxy the "help" command...
if [ $# -gt 0 ]; then
    if [ "$1" == "help" ] || [ "$1" == "-h" ] || [ "$1" == "-help" ] || [ "$1" == "--help" ]; then
        display_help
    fi
else
    display_help
fi

# Source the ".env" file so Laravel's environment variables are available...
if [ -f $(pwd)/.env ]; then
  source $(pwd)/.env;
fi

# Define environment variables...
export APP_PORT=${APP_PORT:-80}
export APP_SERVICE=${APP_SERVICE:-"olami.web"}
export DB_PORT=${DB_PORT:-3306}
export WWWUSER=${WWWUSER:-$UID}
export WWWGROUP=${WWWGROUP:-$(id -g)}

export SERV_FILES=${SERV_FILES:-""}
export SERV_SHARE_DASHBOARD=${SERV_SHARE_DASHBOARD:-4040}
export SERV_SHARE_SERVER_HOST=${SERV_SHARE_SERVER_HOST:-"laravel-sail.site"}
export SERV_SHARE_SERVER_PORT=${SERV_SHARE_SERVER_PORT:-8080}
export SERV_SHARE_SUBDOMAIN=${SERV_SHARE_SUBDOMAIN:-""}

# Function that outputs Serv is not running...
function serv_is_not_running {
    echo "${BOLD}Serv is not running.${NC}" >&2

    exit 1
}

# Define Docker Compose command prefix...
docker compose &> /dev/null
if [ $? == 0 ]; then
    DOCKER_COMPOSE=(docker compose)
else
    DOCKER_COMPOSE=(docker-compose)
fi

if [ -n "$SERV_FILES" ]; then
    # Convert SERV_FILES to an array...
    IFS=':' read -ra SERV_FILES <<< "$SERV_FILES"

    for FILE in "${SERV_FILES[@]}"; do
        if [ -f "$FILE" ]; then
            DOCKER_COMPOSE+=(-f "$FILE")
        else
            echo "${BOLD}Unable to find Docker Compose file: '${FILE}'${NC}" >&2

            exit 1
        fi
    done
fi

EXEC="yes"

if [ -z "$SERV_SKIP_CHECKS" ]; then
    # Ensure that Docker is running...
    if ! docker info > /dev/null 2>&1; then
        echo "${BOLD}Docker is not running.${NC}" >&2

        exit 1
    fi

    # Determine if Serv is currently up...
    if "${DOCKER_COMPOSE[@]}" ps "$APP_SERVICE" 2>&1 | grep 'Exit\|exited'; then
        echo "${BOLD}Shutting down old Serv processes...${NC}" >&2

        "${DOCKER_COMPOSE[@]}" down > /dev/null 2>&1

        EXEC="no"
    elif [ -z "$("${DOCKER_COMPOSE[@]}" ps -q)" ]; then
        EXEC="no"
    fi
fi

ARGS=()

# Proxy PHP commands to the "php" binary on the application container...
if [ "$1" == "php" ]; then
    shift 1

    if [ "$EXEC" == "yes" ]; then
        ARGS+=(exec -u kysk)
        [ ! -t 0 ] && ARGS+=(-T)
        ARGS+=("$APP_SERVICE" "php" "$@")
    else
        serv_is_not_running
    fi

# Proxy vendor binary commands on the application container...
elif [ "$1" == "bin" ]; then
    shift 1

    if [ "$EXEC" == "yes" ]; then
        ARGS+=(exec -u kysk)
        [ ! -t 0 ] && ARGS+=(-T)
        ARGS+=("$APP_SERVICE" ../bin/"$@")
    else
        serv_is_not_running
    fi

# Proxy docker-compose commands to the docker-compose binary on the application container...
elif [ "$1" == "docker-compose" ]; then
    shift 1

    if [ "$EXEC" == "yes" ]; then
        ARGS+=(exec -u kysk)
        [ ! -t 0 ] && ARGS+=(-T)
        ARGS+=("$APP_SERVICE" "${DOCKER_COMPOSE[@]}")
    else
        serv_is_not_running
    fi

# Proxy Composer commands to the "composer" binary on the application container...
elif [ "$1" == "composer" ]; then
    shift 1

    if [ "$EXEC" == "yes" ]; then
        ARGS+=(exec -u kysk)
        [ ! -t 0 ] && ARGS+=(-T)
        ARGS+=("$APP_SERVICE" "composer" "$@")
    else
        serv_is_not_running
    fi

# Proxy Artisan commands to the "artisan" binary on the application container...
elif [ "$1" == "artisan" ] || [ "$1" == "art" ]; then
    shift 1

    if [ "$EXEC" == "yes" ]; then
        ARGS+=(exec -u kysk)
        [ ! -t 0 ] && ARGS+=(-T)
        ARGS+=("$APP_SERVICE" php artisan "$@")
    else
        serv_is_not_running
    fi

# Proxy the "debug" command to the "php artisan" binary on the application container with xdebug enabled...
elif [ "$1" == "debug" ]; then
    shift 1

    if [ "$EXEC" == "yes" ]; then
        ARGS+=(exec -u kysk -e XDEBUG_SESSION=1)
        [ ! -t 0 ] && ARGS+=(-T)
        ARGS+=("$APP_SERVICE" php artisan "$@")
    else
        serv_is_not_running
    fi

# Proxy the "test" command to the "php artisan test" Artisan command...
elif [ "$1" == "test" ]; then
    shift 1

    if [ "$EXEC" == "yes" ]; then
        ARGS+=(exec -u kysk)
        [ ! -t 0 ] && ARGS+=(-T)
        ARGS+=("$APP_SERVICE" php artisan test "$@")
    else
        serv_is_not_running
    fi

# Proxy the "phpunit" command to "php vendor/bin/phpunit"...
elif [ "$1" == "phpunit" ]; then
    shift 1

    if [ "$EXEC" == "yes" ]; then
        ARGS+=(exec -u kysk)
        [ ! -t 0 ] && ARGS+=(-T)
        ARGS+=("$APP_SERVICE" php vendor/bin/phpunit "$@")
    else
        serv_is_not_running
    fi

# Proxy the "pint" command to "php vendor/bin/pint"...
elif [ "$1" == "pint" ]; then
    shift 1

    if [ "$EXEC" == "yes" ]; then
        ARGS+=(exec -u kysk)
        [ ! -t 0 ] && ARGS+=(-T)
        ARGS+=("$APP_SERVICE" php vendor/bin/pint "$@")
    else
        serv_is_not_running
    fi

# Proxy the "dusk" command to the "php artisan dusk" Artisan command...
elif [ "$1" == "dusk" ]; then
    shift 1

    if [ "$EXEC" == "yes" ]; then
        ARGS+=(exec -u kysk)
        [ ! -t 0 ] && ARGS+=(-T)
        ARGS+=(-e "APP_URL=http://${APP_SERVICE}")
        ARGS+=(-e "DUSK_DRIVER_URL=http://selenium:4444/wd/hub")
        ARGS+=("$APP_SERVICE" php artisan dusk "$@")
    else
        serv_is_not_running
    fi

# Proxy the "dusk:fails" command to the "php artisan dusk:fails" Artisan command...
elif [ "$1" == "dusk:fails" ]; then
    shift 1

    if [ "$EXEC" == "yes" ]; then
        ARGS+=(exec -u kysk)
        [ ! -t 0 ] && ARGS+=(-T)
        ARGS+=(-e "APP_URL=http://${APP_SERVICE}")
        ARGS+=(-e "DUSK_DRIVER_URL=http://selenium:4444/wd/hub")
        ARGS+=("$APP_SERVICE" php artisan dusk:fails "$@")
    else
        serv_is_not_running
    fi

# Initiate a Laravel Tinker session within the application container...
elif [ "$1" == "tinker" ] ; then
    shift 1

    if [ "$EXEC" == "yes" ]; then
        ARGS+=(exec -u kysk)
        [ ! -t 0 ] && ARGS+=(-T)
        ARGS+=("$APP_SERVICE" php artisan tinker)
    else
        serv_is_not_running
    fi

# Proxy Node commands to the "node" binary on the application container...
elif [ "$1" == "node" ]; then
    shift 1

    if [ "$EXEC" == "yes" ]; then
        ARGS+=(exec -u kysk)
        [ ! -t 0 ] && ARGS+=(-T)
        ARGS+=("$APP_SERVICE" node "$@")
    else
        serv_is_not_running
    fi

# Proxy NPM commands to the "npm" binary on the application container...
elif [ "$1" == "npm" ]; then
    shift 1

    if [ "$EXEC" == "yes" ]; then
        ARGS+=(exec -u kysk)
        [ ! -t 0 ] && ARGS+=(-T)
        ARGS+=("$APP_SERVICE" npm "$@")
    else
        serv_is_not_running
    fi

# Proxy NPX commands to the "npx" binary on the application container...
elif [ "$1" == "npx" ]; then
    shift 1

    if [ "$EXEC" == "yes" ]; then
        ARGS+=(exec -u kysk)
        [ ! -t 0 ] && ARGS+=(-T)
        ARGS+=("$APP_SERVICE" npx "$@")
    else
        serv_is_not_running
    fi

# Proxy YARN commands to the "yarn" binary on the application container...
elif [ "$1" == "yarn" ]; then
    shift 1

    if [ "$EXEC" == "yes" ]; then
        ARGS+=(exec -u kysk)
        [ ! -t 0 ] && ARGS+=(-T)
        ARGS+=("$APP_SERVICE" yarn "$@")
    else
        serv_is_not_running
    fi

# Initiate a MySQL CLI terminal session within the "mysql" container...
elif [ "$1" == "mysql" ]; then
    shift 1

    if [ "$EXEC" == "yes" ]; then
        ARGS+=(exec)
        [ ! -t 0 ] && ARGS+=(-T)
        ARGS+=(mysql bash -c)
        ARGS+=("MYSQL_PWD=\${MYSQL_PASSWORD} mysql -u \${MYSQL_USER} \${MYSQL_DATABASE}")
    else
        serv_is_not_running
    fi

# Initiate a MySQL CLI terminal session within the "mariadb" container...
elif [ "$1" == "mariadb" ]; then
    shift 1

    if [ "$EXEC" == "yes" ]; then
        ARGS+=(exec)
        [ ! -t 0 ] && ARGS+=(-T)
        ARGS+=(mariadb bash -c)
        ARGS+=("MYSQL_PWD=\${MYSQL_PASSWORD} mysql -u \${MYSQL_USER} \${MYSQL_DATABASE}")
    else
        serv_is_not_running
    fi

# Initiate a PostgreSQL CLI terminal session within the "pgsql" container...
elif [ "$1" == "psql" ]; then
    shift 1

    if [ "$EXEC" == "yes" ]; then
        ARGS+=(exec)
        [ ! -t 0 ] && ARGS+=(-T)
        ARGS+=(pgsql bash -c)
        ARGS+=("PGPASSWORD=\${PGPASSWORD} psql -U \${POSTGRES_USER} \${POSTGRES_DB}")
    else
        serv_is_not_running
    fi

# Initiate a Bash shell within the application container...
elif [ "$1" == "shell" ] || [ "$1" == "bash" ]; then
    shift 1

    if [ "$EXEC" == "yes" ]; then
        ARGS+=(exec -u kysk)
        [ ! -t 0 ] && ARGS+=(-T)
        ARGS+=("$APP_SERVICE" bash "$@")
    else
        serv_is_not_running
    fi

# Initiate a root user Bash shell within the application container...
elif [ "$1" == "root-shell" ] || [ "$1" == "root-bash" ]; then
    shift 1

    if [ "$EXEC" == "yes" ]; then
        ARGS+=(exec)
        [ ! -t 0 ] && ARGS+=(-T)
        ARGS+=("$APP_SERVICE" bash "$@")
    else
        serv_is_not_running
    fi

# Initiate a Redis CLI terminal session within the "redis" container...
elif [ "$1" == "redis" ] ; then
    shift 1

    if [ "$EXEC" == "yes" ]; then
        ARGS+=(exec)
        [ ! -t 0 ] && ARGS+=(-T)
        ARGS+=(redis redis-cli)
    else
        serv_is_not_running
    fi

# Share the site...
elif [ "$1" == "share" ]; then
    shift 1

    if [ "$EXEC" == "yes" ]; then
        docker run --init --rm -p "$SERV_SHARE_DASHBOARD":4040 -t beyondcodegmbh/expose-server:latest share http://host.docker.internal:"$APP_PORT" \
            --server-host="$SERV_SHARE_SERVER_HOST" \
            --server-port="$SERV_SHARE_SERVER_PORT" \
            --auth="$SERV_SHARE_TOKEN" \
            --subdomain="$SERV_SHARE_SUBDOMAIN" \
            "$@"

        exit
    else
        serv_is_not_running
    fi

# Pass unknown commands to the "docker-compose" binary...
else
    ARGS+=("$@")
fi

# Run Docker Compose with the defined arguments...
"${DOCKER_COMPOSE[@]}" "${ARGS[@]}"
