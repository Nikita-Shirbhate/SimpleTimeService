import os
"""
This script serves as the entry point for running the WSGI application.

It imports the Flask application instance from the `app` module and starts
the application server. The server listens on all available network interfaces
(`0.0.0.0`) and uses the port specified in the `PORT` environment variable.
If the `PORT` environment variable is not set, it defaults to port 5000.

Modules:
    os: Provides a way to access environment variables.
    app: Imports the Flask application instance.

Usage:
    Run this script directly to start the Flask application server.
"""
from app import app

if __name__ == '__main__':
    port = int(os.environ.get("PORT", 5000)) # Get the port from environment or use 5000 for local
    app.run(host='0.0.0.0', port=5000)