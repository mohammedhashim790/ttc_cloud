import json
import os

import requests
import data


def parse_data():
    response = requests.get(os.environ.get("TTC_FEED"),
                            headers={'Host': 'gtfsrt.ttc.ca', 'Cache-Control': 'max-age=0',
                                     'User-Agent': 'Mozilla/5.0'})

    return response.text


def lambda_handler(event, context):
    print("Normaliser event started")

    parse_data()

    return {'statusCode': 200, 'body': json.dumps('Normaliser execution complete')}
