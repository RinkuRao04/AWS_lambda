import json
import boto3
from botocore.exceptions import ClientError
import os

# Initialize the DynamoDB client
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['DYNAMODB_TABLE'])

def lambda_handler(event, context):
    # Extract the path and HTTP method from the event
    path = event['rawPath']
    method = event['requestContext']['http']['method']

    # Parse the JSON body of the request
    body = json.loads(event['body'])

    if path == '/register' and method == 'POST':
        # Handle user registration
        return register_user(body)
    elif path == '/login' and method == 'POST':
        # Handle user login
        return login_user(body)
    else:
        return {
            "statusCode": 400,
            "body": json.dumps({"message": "Invalid path or method"})
        }

def register_user(body):
    username = body.get('username')
    password = body.get('password')

    # Ensure both username and password are provided
    if not username or not password:
        return {
            "statusCode": 400,
            "body": json.dumps({"message": "Username and password are required"})
        }

    try:
        # Check if the user already exists
        response = table.get_item(Key={'username': username})
        if 'Item' in response:
            return {
                "statusCode": 400,
                "body": json.dumps({"message": "Username already exists"})
            }

        # Insert the new user into DynamoDB
        table.put_item(Item={'username': username, 'password': password})
        return {
            "statusCode": 200,
            "body": json.dumps({"message": "User registered successfully"})
        }
    except ClientError as e:
        return {
            "statusCode": 500,
            "body": json.dumps({"message": "Error registering user", "error": str(e)})
        }

def login_user(body):
    username = body.get('username')
    password = body.get('password')

    # Ensure both username and password are provided
    if not username or not password:
        return {
            "statusCode": 400,
            "body": json.dumps({"message": "Username and password are required"})
        }

    try:
        # Check if the user exists
        response = table.get_item(Key={'username': username})
        if 'Item' not in response:
            return {
                "statusCode": 404,
                "body": json.dumps({"message": "User not found"})
            }

        # Check if the password matches
        stored_password = response['Item'].get('password')
        if stored_password != password:
            return {
                "statusCode": 401,
                "body": json.dumps({"message": "Incorrect password"})
            }

        return {
            "statusCode": 200,
            "body": json.dumps({"message": "Login successful"})
        }
    except ClientError as e:
        return {
            "statusCode": 500,
            "body": json.dumps({"message": "Error checking credentials", "error": str(e)})
        }
