FROM php:8.4-apache

RUN docker-php-ext-install pdo_mysql

WORKDIR /var/www/html

COPY apache.conf /etc/apache2/sites-available/000-default.conf
COPY public/ public/
COPY tests/ tests/

# Avec MAINTENANCE=true, toute nouvelle instance démarre en maintenance.
ARG MAINTENANCE=false
RUN if [ "$MAINTENANCE" = true ]; then touch public/.maintenance; fi
