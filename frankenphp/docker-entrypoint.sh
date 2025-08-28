#!/bin/sh
set -e

if [ "$1" = 'frankenphp' ] || [ "$1" = 'php' ]; then
	# Install the project the first time PHP is started
	# After the installation, the following block can be deleted
	if [ ! -f composer.json ]; then
		rm -Rf tmp/
		composer create-project laravel/laravel tmp --prefer-dist

		cd tmp
		cp -Rp . ..
		cd -
		rm -Rf tmp/

		composer require laravel/octane
		php artisan octane:install --server=frankenphp

		if grep -q ^DATABASE_URL= .env; then
			echo 'To finish the installation please press Ctrl+C to stop Docker Compose and run: docker compose up --build --wait'
			sleep infinity
		fi
	fi

	if [ -z "$(ls -A 'vendor/' 2>/dev/null)" ]; then
		composer install --prefer-dist --no-progress --no-interaction
	fi

	# Display information about the current project
	# Or about an error in project initialization
	php artisan

	if grep -q ^DATABASE_URL= .env; then
		if [ "$( find ./migrations -iname '*.php' -print -quit )" ]; then
			php artisan migrate:fresh --seed --no-interaction
		fi
	fi

	# if [ -f package.json ]; then
    #     if [ "$NODE_ENV" = "production" ]; then
    #     	npm install --omit=dev
    #      	echo "Building assets for production..."
    #      	npm run build
    #     else
    #     	npm install
    #      	echo "Starting development server..."
    # 	 	npm run dev -- --host &
    #     fi
    # fi

	setfacl -R -m u:www-data:rwX -m u:"$(whoami)":rwX bootstrap/cache
	setfacl -dR -m u:www-data:rwX -m u:"$(whoami)":rwX bootstrap/cache

	echo 'PHP app ready!'
fi

exec docker-php-entrypoint "$@"
