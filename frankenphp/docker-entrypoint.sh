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

	echo 'Hello World!'

	# Display information about the current project
	# Or about an error in project initialization
	php artisan


	if [ "$( find ./database/migrations -iname '*.php' -print -quit )" ]; then
		if [ "$APP_ENV" != "production" ]; then
			php artisan migrate:fresh --seed --no-interaction
		else
	echo "Hey"
			php artisan migrate --no-interaction
			echo "Ho"
		fi
	fi

	if [ -f package.json ] && [ "$NODE_ENV" = "development" ]; then
		npm install
		echo "Starting the development server..."
		npm run dev -- --host &
	fi

	setfacl -R -m u:www-data:rwX -m u:"$(whoami)":rwX bootstrap/cache
	setfacl -dR -m u:www-data:rwX -m u:"$(whoami)":rwX bootstrap/cache

	echo 'PHP app ready!'
fi

exec docker-php-entrypoint "$@"
