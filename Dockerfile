FROM python:3.6-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    redis-server supervisor mariadb-client \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple

COPY requirements.txt .

RUN grep -v "pywin32" requirements.txt > linux_req.txt && \
    pip install --no-cache-dir -r linux_req.txt

COPY . .

RUN mkdir -p /etc/supervisor/conf.d && \
    echo "[supervisord]" > /etc/supervisor/conf.d/autotest.conf && \
    echo "nodaemon=true" >> /etc/supervisor/conf.d/autotest.conf && \
    echo "" >> /etc/supervisor/conf.d/autotest.conf && \
    echo "[program:web]" >> /etc/supervisor/conf.d/autotest.conf && \
    echo "command=python manage.py runserver 0.0.0.0:8000" >> /etc/supervisor/conf.d/autotest.conf && \
    echo "directory=/app" >> /etc/supervisor/conf.d/autotest.conf && \
    echo "autostart=true" >> /etc/supervisor/conf.d/autotest.conf && \
    echo "autorestart=true" >> /etc/supervisor/conf.d/autotest.conf && \
    echo "stdout_logfile=/var/log/web.log" >> /etc/supervisor/conf.d/autotest.conf

EXPOSE 8000

CMD ["supervisord", "-n", "-c", "/etc/supervisor/conf.d/autotest.conf"]
