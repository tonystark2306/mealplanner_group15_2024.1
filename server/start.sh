#!/bin/bash

# Migrate database
flask db upgrade

# Start Celery worker in the background
celery -A celery_worker.celery worker --loglevel=info &

# Start Flask server
python run.py