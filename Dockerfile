FROM python:3.7.4-slim-stretch
COPY . /app
WORKDIR /app
EXPOSE 5432
ENTRYPOINT python /app/main.py

