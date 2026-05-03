import csv
import argparse
import sys
import math
from decimal import Decimal
import os

import boto3
from botocore.exceptions import ClientError


def clean_float(val):
    if not val:
        return None
    try:
        f = float(val)
        if math.isnan(f) or math.isinf(f):
            return None
        # Convert float to Decimal format that DynamoDB accepts
        return Decimal(str(f))
    except ValueError:
        return None


def seed_stations(table_name, profile_name, csv_file_path):
    # Set up the AWS session with the provided profile
    if profile_name:
        session = boto3.Session(profile_name=profile_name, region_name='ca-central-1')
    else:
        session = boto3.Session()
        
    dynamodb_client = session.client('dynamodb')
    
    # Check if table exists
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
        with open(csv_file_path, mode='r', encoding='utf-8') as csvfile:
            reader = csv.DictReader(csvfile)
            count = 0
            
            with table.batch_writer() as batch:
                for row in reader:
                    item = {}
                    
                    # Check for empty station_id
                    station_id = row.get('station_id')
                    if not station_id:
                        continue
                    
                    item['station_id'] = station_id
                    
                    # Copy values only if they exist and are not empty
                    for field in ['stop_name', 'stop_desc', 'zone_id', 'stop_url', 'location_type', 'parent_station', 'stop_timezone', 'wheelchair_boarding', 'parent_station_id', 'agency', 'line_number']:
                        val = row.get(field)
                        if val is not None and val != "":
                            item[field] = val
                    
                    # Also map 'stop_id' from CSV to 'id' in DynamoDB
                    id_val = row.get('stop_id')
                    if id_val is not None and id_val != "":
                        item['id'] = id_val
                    
                    # Handle floats as Decimals for DynamoDB
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
        print(f"Error: The file {csv_file_path} was not found.")
        sys.exit(1)
    except Exception as e:
        print(f"An unexpected error occurred: {e}")
        sys.exit(1)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Seed DynamoDB with TTC stations from a CSV file.")
    parser.add_argument('--table', required=True, help="DynamoDB table name")
    parser.add_argument('--profile', help="AWS profile name")
    
    args = parser.parse_args()
    
    # Resolving path relative to script
    script_dir = os.path.dirname(os.path.abspath(__file__))
    csv_file = os.path.join(script_dir, "processed_stations.csv")

    seed_stations(args.table, args.profile, csv_file)
