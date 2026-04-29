import json

def lambda_handler(event, context):
    print("Normalising GTFS data to JSON format...")
    # TODO: Implement GTFS to JSON transformation logic
    
    return {
        'statusCode': 200,
        'body': json.dumps('Normaliser execution complete')
    }
