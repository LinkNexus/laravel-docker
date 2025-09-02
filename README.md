# Laravel Docker with FrankenPHP

A modern, production-ready Laravel application setup using Docker and [FrankenPHP](https://frankenphp.dev/) - a modern app server for PHP built on top of Caddy.

## ✨ Features

- 🚀 **FrankenPHP** - Modern PHP app server with automatic HTTPS, HTTP/2, and HTTP/3 support
- 🐳 **Multi-stage Docker builds** - Optimized for both development and production
- 🔄 **Laravel Octane** - High-performance application server for Laravel
- 📦 **PostgreSQL** - Robust database with health checks
- ⚡ **Vite** - Fast frontend asset building
- 🛠️ **Xdebug** - Debugging support in development
- 📧 **MailHog** - Email testing in development
- 🎯 **Hot reload** - File watching in development mode
- 📊 **Health checks** - Built-in monitoring endpoints

## 🏗️ Architecture

### Development Environment

- **FrankenPHP with Xdebug** - PHP 8.4 with debugging capabilities
- **File watching** - Automatic reloading on code changes
- **Volume mounting** - Real-time code synchronization
- **MailHog** - Local email testing server

### Production Environment

- **Optimized FrankenPHP** - Production PHP configuration
- **Pre-built assets** - Compiled frontend assets included
- **Laravel optimization** - Route, config, and view caching
- **Composer optimization** - Authoritative classmap autoloader

## 🚀 Quick Start

### Prerequisites

- Docker and Docker Compose
- Make (optional, for convenient commands)

### Development Setup

1. **Clone the repository**

   ```bash
   git clone <repository-url>
   cd laravel-docker
   ```

2. **Start development environment**

   ```bash
   # Using Make (recommended)
   make start

   # Or using Docker Compose directly
   docker compose up --build
   ```

3. **Access the application**
   - **Application**: https://localhost (with automatic HTTPS)
   - **MailHog**: http://localhost:8025
   - **Health Check**: https://localhost:2019/metrics

### Production Deployment

1. **Build and start production containers**

   ```bash
   # Using Make
   make build-prod
   make up-prod

   # Or using Docker Compose
   docker compose -f compose.yaml -f compose.prod.yaml up --build -d
   ```

## 🛠️ Available Commands

### Docker Management

```bash
make build          # Build development images
make build-prod     # Build production images
make up             # Start containers (development)
make up-prod        # Start containers (production)
make down           # Stop and remove containers
make logs           # View container logs
make sh             # Access application container shell
```

### Laravel Commands

```bash
make artisan                    # List Artisan commands
make artisan c="migrate"        # Run specific Artisan command
make artisan c="make:model User" # Create new model
make cc                         # Clear application cache
```

### Composer Commands

```bash
make composer                           # Show Composer help
make composer c="require package/name"  # Install new package
make composer c="update"                # Update dependencies
make vendor                             # Install production dependencies
```

## 📁 Project Structure

```
├── frankenphp/                 # FrankenPHP configuration
│   ├── conf.d/                # PHP configuration files
│   └── docker-entrypoint.sh   # Container startup script
├── compose.yaml               # Base Docker Compose configuration
├── compose.override.yaml      # Development overrides
├── compose.prod.yaml          # Production overrides
├── Dockerfile                 # Multi-stage Docker build
└── Makefile                   # Convenient command shortcuts
```

## 🔧 Configuration

### Environment Variables

Create a `.env` file based on `.env.example`:

```bash
# Database
DB_CONNECTION=pgsql
DB_HOST=database
DB_PORT=5432
DB_DATABASE=app
DB_USERNAME=app
DB_PASSWORD=!ChangeMe!

# Application
APP_ENV=local
APP_DEBUG=true
APP_URL=https://localhost

# Mail (Development)
MAIL_MAILER=smtp
MAIL_HOST=mailer
MAIL_PORT=1025
```

### PHP Configuration

PHP settings can be customized in:

- `frankenphp/conf.d/10-app.ini` - Base configuration
- `frankenphp/conf.d/20-app.dev.ini` - Development overrides
- `frankenphp/conf.d/20-app.prod.ini` - Production overrides

### Database Persistence

By default, database data is stored in Docker volumes. For production, you can use bind mounts:

```yaml
# In compose.prod.yaml
volumes:
  - ./docker/db/data:/var/lib/postgresql/data:rw
```

## 🚨 Troubleshooting

### Container Fails to Start

```bash
# Check container logs
make logs

# Rebuild containers
make down
make build
make up
```

### Permission Issues

```bash
# Fix file permissions
docker compose exec app chown -R www-data:www-data /app/storage /app/bootstrap/cache
```

### Database Connection Issues

```bash
# Check database status
docker compose exec database pg_isready -d app -U app

# Reset database
make artisan c="migrate:fresh --seed"
```

### Clear All Caches

```bash
make artisan c="optimize:clear"
make cc
```

## 🔒 Security

### Production Checklist

- [ ] Change default database password
- [ ] Set strong `APP_KEY` (automatically generated)
- [ ] Configure proper `APP_URL`
- [ ] Set `APP_DEBUG=false`
- [ ] Review and secure file permissions
- [ ] Configure backup strategy
- [ ] Set up monitoring and logging

### Default Passwords

⚠️ **Change these in production:**

- Database password: `!ChangeMe!`

## 📊 Monitoring

### Health Checks

- **Application**: https://localhost:2019/metrics
- **Database**: Built-in PostgreSQL health checks
- **Container status**: `docker compose ps`

### Performance

The production build includes:

- Laravel optimization (routes, config, views)
- Composer autoloader optimization
- OPcache for PHP performance
- Asset compilation and optimization

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test in both development and production modes
5. Submit a pull request

## 📄 License

This project is open-sourced software licensed under the [MIT license](LICENSE).

## 🆘 Support

For issues related to:

- **Laravel**: [Laravel Documentation](https://laravel.com/docs)
- **FrankenPHP**: [FrankenPHP Documentation](https://frankenphp.dev/docs/)
- **Docker**: [Docker Documentation](https://docs.docker.com/)

---

**Made with ❤️ using Laravel, FrankenPHP, and Docker**
