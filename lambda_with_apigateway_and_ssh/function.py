import boto3
import paramiko
import os
import json

def lambda_handler(event, context):
    # Print the event for debugging purposes
    print("Received event:", json.dumps(event, indent=2))
    
    # Initialize S3 client to download the private key for SSH
    s3_client = boto3.client('s3')
    
    # Download private key file from secure S3 bucket
    s3_client.download_file('private-key-bucket-03', 'keys/keyname.pem', '/tmp/keyname.pem')
    
    # Load the private key from the downloaded file
    k = paramiko.RSAKey.from_private_key_file("/tmp/keyname.pem")
    
    # Initialize SSH client
    c = paramiko.SSHClient()
    c.set_missing_host_key_policy(paramiko.AutoAddPolicy())

    # Hardcoding the IP address of the EC2 instance
    host = '13.233.133.150'  # Replace with your actual EC2 instance IP address
    print("Connecting to " + host)
    
    # Establish SSH connection to EC2 instance
    c.connect(hostname=host, username="ubuntu", pkey=k)
    print("Connected to " + host)
    
    # Retrieve 'script' query parameter from the event (API Gateway)
    script_id = event.get('queryStringParameters', {}).get('script')
    
    # Log the script_id for debugging
    print(f"Received script_id: {script_id}")
    
    # Validate script_id and determine the corresponding script to run
    if not script_id or script_id not in ['1', '2', '3', '4']:
        return {
            'statusCode': 400,
            'body': json.dumps({
                'message': 'Invalid or missing "script" query parameter. Expected values: 1, 2, 3, 4.'
            })
        }

    # Map script_id to the actual Python script path on the EC2 instance
    script_map = {
        '1': '/home/ubuntu/script_1.py',
        '2': '/home/ubuntu/script_2.py',
        '3': '/home/ubuntu/script_3.py',
        '4': '/home/ubuntu/script_4.py',
    }
    
    script_path = script_map[script_id]
    
    # Full command to activate the virtual environment and run the selected Python script
    command = f"source /home/ubuntu/pyenvnew/bin/activate && python {script_path}"

    print("Executing: {}".format(command))
    
    # Execute the command via SSH
    stdin, stdout, stderr = c.exec_command(f'bash -l -c "{command}"')
    
    # Read and capture the output and errors from the command execution
    stdout_output = stdout.read().decode()  # Decode bytes to string (standard output)
    stderr_output = stderr.read().decode()  # Decode bytes to string (standard error)
    
    print("STDOUT: ", stdout_output)
    print("STDERR: ", stderr_output)

    # Close the SSH connection
    c.close()

    # Return a response with the output of the script execution
    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': f"Script {script_id} executed successfully!",
            'stdout': stdout_output,
            'stderr': stderr_output
        })
    }
