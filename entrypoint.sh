#!/bin/bash

# Ensure the database file exists
touch /etc/serles/data/db.sqlite

# Execute the main command
exec gunicorn --config /etc/serles/gunicorn_config.py 'serles:create_app()'
