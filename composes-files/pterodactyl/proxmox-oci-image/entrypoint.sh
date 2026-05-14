sh -c 'mkdir -p /run/nginx && chown -R nginx:nginx /run/nginx && exec /bin/ash /app/.github/docker/entrypoint.sh supervisord -n -c /etc/supervisord.conf'
