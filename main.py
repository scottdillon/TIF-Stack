from flask import Flask
from datetime import datetime
from influxdb import InfluxDBClient


client = InfluxDBClient('influxdb', 8086, 'admin', 'admin', 'metrics')
app = Flask(__name__)

@app.route("/hello")
def hello():
    client.write_points([{
        "measurement": "endpoint_request",
        "tags": {
            "endpoint": "/hello",
        },
        "time": datetime.now(),
        "fields": {
            "value": 1
        }
    }])
    return "Hello World!"


@app.route("/bye")
def bye():
    client.write_points([{
        "measurement": "endpoint_request",
        "tags": {
            "endpoint": "/bye",
        },
        "time": datetime.now(),
        "fields": {
            "value": 1
        }
    }])
    return "Bye World!"

if __name__ == "__main__":
    app.run (host="0.0.0.0")