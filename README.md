# Influxdb / Telegraf / Grafana metrics

This repo was cloned from Ruben Sanchez's [metrics-stack](https://github.com/rubenwap/metrics-stack) repo but I found that it didn't work with newer versions of the TIF stack and didn't fit my needs. I needed a quick way to set up a TIF stack and I wanted to do *ZERO* configuration afterwards. I got tired of setting up email alerting only to find that I needed to tear down the stack again.

This repo allows the user to spin up a Telegraf/InfluxDB/Grafana stack very easily.

- Read and Write tokens are created during setup.
- Grafana and Telegraf connect with no further setup.
- Email alerting is set up in Grafana if desired.
- Telegraf collects data from a Postgresql database if environment variables are filled in.
- HTTPS is automatically enabled via [Caddy](https://caddyserver.com/)

## Getting Started
First, you're going to need docker and docker-compose. Install them if you haven't already and then come back to this point. Then, find the example environment files and rename them. Then, fill them in with your desired values.

- **.env**
    - You'll want to fill in the INFLUX_ORG AND INFLUX_BUCKET.
- **telegraf.env**
    - Ignore the TELEGRAF_WRITE_TOKEN. It will be filled in automatically.
    - Fill in the PG_HOST, PG_PORT, PG_USER, PGPASSWORD, PG_DATABASE with your postgresql host, port and credentials.
    - PG_OUTPUT_ADDRESS is a tag that is attached to the data collected.
- **influxdb.env**
    - Fill in the INFLUX_USERNAME and INFLUX_PASSWORD. These will be your login credentials to the influxDB instance.
- **grafana.env**
    - Ignore the GRAFANA_READ_TOKEN. It will be filled in automatically.
    - Fill in the GF_SECURITY_ADMIN_USER and GF_SECURITY_ADMIN_PASSWORD. These will be your admin credentials to the grafana instance.
    - Fill in the GF_SMTP_* entries if you wish to have email alerting set up by default.

Run `./run.sh up` and the containers will be spun up and configured.

Now, if you go to http://localhost:3000 you'll see your grafana instance. InfluxDB is at http://localhost:8086. You should be able to log in with the credentials you specified in the `grafana.env` and `influxdb.env` files respectively.

## HTTPS
Configure your DNS server (I use a [pihole](https://pi-hole.net/) at home and at my job) to serve your ip address for `metrics.local.lan` and `influx.local.lan` domains. If you don't have a DNS server, make entries in your HOSTS file to serve localhost for `influx.local.lan` and `metrics.local.lan`.

Now go to `https://metrics.local.lan` and you should see the warning page because your browser does not trust the internal Caddy CA. The root certificate caddy uses is extracted to `./caddy/root.crt`. Load this into keychain on a mac and you're good to go.

If you're hesitant to trust the root.crt created by caddy, know that it is only good for pages served by this instance of Caddy itself. It won't be any good anywhere else.

If you're still hesitant, just use the http://localhost:3000 and http://localhost:8086 urls.

## The run.sh File

The run.sh file serves as a container for scripts needed to setup and run the project. If you get tired of typing `./run.sh`, you can add
```bash
alias run="./run.sh"
```
 to your `.zshrc` or `.bash_aliases` to let you use it like `run up`.

Some points of interest in there are:

- `cmd` - The `cmd` function allows you to run a command inside of the influx container while shortcutting some of the verbosity. So instead of this:
```bash
docker-compose exec influxdb influx bucket list
```
do this
```bash
run cmd influx bucket list
```

- `start_over` - DANGER! This command will wipe your grafana and influx container volumes. Use this to start over and set the project up again.

- `wipe_telegraph` - If you need to configure telegraph and rebuild the container, use this followed by `docker-compose up -d`

## Telegraf Plugins

[More info on telegraf plugins](https://github.com/influxdata/telegraf/tree/master/plugins)

## Grafana Datasource Provisioning

An example YAML file for InfluxDB 2.0 can be found on the [grafana datasource docs](https://grafana.com/docs/grafana/latest/datasources/influxdb/#influxdb-2x-for-flux-example)
