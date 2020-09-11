# Influxdb / Telegraf / Grafana metrics

This repo is a template you can apply to projects where you need the following parts:

- Telegraf: This is an agent that will collect metrics from your application 
- Influxdb: A database where the Telegraf data will be sent
- Grafana: A tool to create monitoring dashboards

In order to use together with another project, just reuse the `docker-compose` file and change the web service to whatever is running your application. The other compose components can stay the same. 

Run it with 

    docker-compose up --build

(and omit the build step in future runs unless you change something that requires rebuild)

    docker-compose down

That will switch it off. 

Once you enter Grafana via `localhost:3000`, credentials are `admin/admin`. You can change that. 

Notice that the compose file is mounting some local folders in order to have persisting data. Modify those according to your needs. 