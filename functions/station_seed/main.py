import argparse
import csv
import os
import sys
from decimal import Decimal

import boto3
import math
from botocore.exceptions import ClientError


script_dir = os.path.dirname(os.path.abspath(__file__))

def clean_float(val):
    if not val:
        return None
    try:
        f = float(val)
        if math.isnan(f) or math.isinf(f):
            return None

        return Decimal(str(f))
    except ValueError:
        return None


def seed_stops(table_name, profile_name):
    if profile_name:
        session = boto3.Session(profile_name=profile_name, region_name='ca-central-1')
    else:
        session = boto3.Session()

    dynamodb_client = session.client('dynamodb')

    try:
        dynamodb_client.describe_table(TableName=table_name)
        print(f"Table '{table_name}' found. Proceeding with batch data insertion...")
    except ClientError as e:
        if e.response['Error']['Code'] == 'ResourceNotFoundException':
            print(f"Error: DynamoDB table '{table_name}' does not exist. Please create it first.")
            sys.exit(1)
        else:
            print(f"An error occurred while checking table: {e}")
            sys.exit(1)

    dynamodb = session.resource('dynamodb')
    table = dynamodb.Table(table_name)

    try:
        with open(os.path.join(script_dir, "processed_stations.csv"), mode='r', encoding='utf-8') as csvfile:
            reader = csv.DictReader(csvfile)
            count = 0

            with table.batch_writer() as batch:
                for row in reader:
                    item = {}

                    id_val = row.get('station_id')
                    if not id_val:
                        continue
                    item['id'] = str(id_val)

                    for field in ['stop_name', 'parent_station', 'wheelchair_boarding', 'parent_station_id', 'agency',
                                  'line_number']:
                        val = row.get(field)
                        if val is not None and val != "":
                            item[field] = val

                    lat = clean_float(row.get('stop_lat'))
                    if lat is not None:
                        item['stop_lat'] = lat

                    lon = clean_float(row.get('stop_lon'))
                    if lon is not None:
                        item['stop_lon'] = lon

                    batch.put_item(Item=item)
                    count += 1
            print(f"Batch insertion completed successfully. Added/updated {count} stations.")
    except FileNotFoundError:
        print(f"Error: The file 'processed_stations.csv' was not found.")
        sys.exit(1)
    except Exception as e:
        print(f"An unexpected error occurred: {e}")
        sys.exit(1)


def seed_subway(table_name, profile_name):
    if profile_name:
        session = boto3.Session(profile_name=profile_name, region_name='ca-central-1')
    else:
        session = boto3.Session()

    dynamodb_client = session.client('dynamodb')

    try:
        dynamodb_client.describe_table(TableName=table_name)
        print(f"Table '{table_name}' found. Proceeding with batch data insertion...")
    except ClientError as e:
        if e.response['Error']['Code'] == 'ResourceNotFoundException':
            print(f"Error: DynamoDB table '{table_name}' does not exist. Please create it first.")
            sys.exit(1)
        else:
            print(f"An error occurred while checking table: {e}")
            sys.exit(1)

    dynamodb = session.resource('dynamodb')
    table = dynamodb.Table(table_name)

    try:
        with open(os.path.join(script_dir, "subways_stations.csv"), mode='r', encoding='utf-8') as csvfile:
            reader = csv.DictReader(csvfile)
            count = 0

            with table.batch_writer() as batch:
                for row in reader:
                    # {'mode': 'SUBWAY', 'parent_station': 'Bay Station', 'parent_station_id': '235'}
                    batch.put_item(Item=row)
                    count += 1
            print(f"Batch insertion completed successfully. Added/updated {count} stations.")
    except FileNotFoundError:
        print(f"Error: The file 'subways_stations.csv' was not found.")
        sys.exit(1)
    except Exception as e:
        print(f"An unexpected error occurred: {e}")
        sys.exit(1)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Seed DynamoDB with TTC stations from a CSV file.")
    parser.add_argument('--table', nargs="+", required=True, help="DynamoDB table name")
    parser.add_argument('--profile', help="AWS profile name")
    args = parser.parse_args()

    seed_stops(args.table[0], args.profile)
    seed_subway(args.table[1], args.profile)
