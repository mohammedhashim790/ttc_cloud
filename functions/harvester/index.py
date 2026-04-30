import json

def lambda_handler(event, context):
    print("Harvesting TTC GTFS data...")
    # TODO: Implement GTFS download logic here
    
    return {
        'statusCode': 200,
        'body': json.dumps('Harvester execution complete')
    }
