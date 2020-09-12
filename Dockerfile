FROM python:3.7.4-slim-stretch
COPY . /app
WORKDIR /app
EXPOSE 5000
RUN pip install -r requirements.txt
ENTRYPOINT python /app/main.py

