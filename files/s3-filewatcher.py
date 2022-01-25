import boto3
import os

# boto3 S3 and SNS initialization
s3_client = boto3.client("s3")
sns_client = boto3.client('sns')
topic = os.environ['alertTopic']
print("[*] boto s3 and sns imported...")

def sns_sender(file_name, topic, subject):
   ##### send alert messages to the specified SNS topic #####
    body = "Hi, \r\n\r\nThe bucket has confirmed that " + file_name + " has been uploaded successfully.\r\n"  
    body = body + "\r\n\r\n"
    body = body + "Thanks,\r\n"
    body = body + "The S3 FileWatcher"
    try:
        print("[*] Sending SNS notification...")
        sns_response = sns_client.publish(
            TopicArn=topic,
            Subject=subject,
            Message=body,
        )
        print(sns_response)
    except Exception as e:
        log_msg = "[ERROR] SNS Sender failed, here is the error:" + str(e)
        
        print(log_msg)

def lambda_handler(event, context):

   # event contains all information about uploaded object
   print("[*] Event:", event)
   
   # Bucket Name where file was uploaded
   source_bucket_name = event['detail']['requestParameters']['bucketName']
   print("[*] Monitoring " + source_bucket_name)
   
   # Filename of object (with path)
   file_key_name = event['detail']['requestParameters']['key']
   print("[*] " + file_key_name + " has been successfully uploaded.")
   file_name = file_key_name
   subject="File Upload Confirmation"
   sns_sender(file_name, topic, subject)

