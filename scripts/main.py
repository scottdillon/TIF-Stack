from time import sleep
import random
from influxdb_client import InfluxDBClient, Point, Dialect
from influxdb_client.client.write_api import SYNCHRONOUS


client = InfluxDBClient('http://127.0.0.1:8086', token="JCyBj__e1bDVIKroLvwdgC4f8mjhxKqnG8b3pK-GUUvccXxDrEAyuyikJVI620ScH_qNUVeM1fw-CdSMdgbn4Q==", org="Hexatech")

write_api = client.write_api(write_options=SYNCHRONOUS)
# @app.route("/bye")
# def bye():
#     client.write_points([{
#         "measurement": "endpoint_request",
#         "tags": {
#             "endpoint": "/bye",
#         },
#         "time": datetime.now(),
#         "fields": {
#             "value": 1
#         }
#     }])
#     return "Bye World!"

if __name__ == "__main__":
    while True:
        time = random.randrange(0, 1000)
        p = Point('test_python').tag('endpoint', "login").field('response_time', time)
        write_api.write(bucket='sensors', record=p)
        print(p)
        sleep(5)
