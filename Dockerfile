# Servas (https://github.com/beromir/Servas) for Railway.
# Official image, pinned by version and digest. Bump both together and add a CHANGELOG.md entry.
FROM beromir/servas:1.2.0@sha256:662b0d8f37e67addc0448eb0fecb87c9a1314e2ef51dd8eb3ba222e8a2b726e3

COPY railway/Caddyfile /etc/caddy/Caddyfile
COPY railway/zz-railway.ini /usr/local/etc/php/conf.d/zz-railway.ini
COPY railway/healthz.php /app/public/healthz.php
COPY railway/bootstrap-owner.php /opt/railway/bootstrap-owner.php
COPY railway/start.sh /opt/railway/start.sh
RUN chmod 755 /opt/railway/start.sh

ENV PORT=8080
EXPOSE 8080

ENTRYPOINT ["/opt/railway/start.sh"]
