# Puma configuration file

max_threads_count = ENV.fetch("RAILS_MAX_THREADS", 5)
min_threads_count = ENV.fetch("RAILS_MIN_THREADS", max_threads_count)
threads min_threads_count, max_threads_count

# Specifies the port that Puma will listen on
port ENV.fetch("PORT", 3000)

# Specifies the environment
environment ENV.fetch("RAILS_ENV", "development")

# Specifies the number of workers (processes)
workers ENV.fetch("WEB_CONCURRENCY", 1)

# Preload the application for better memory usage
preload_app!

# Allow puma to be restarted by `rails restart`
plugin :tmp_restart

# PID file
pidfile ENV.fetch("PIDFILE", "tmp/pids/server.pid")

# Worker timeout in development
worker_timeout 3600 if ENV.fetch("RAILS_ENV", "development") == "development"