import json
import boto3
from datetime import datetime

awsregion=boto3.session.Session().region_name
sns_topic_arn="arn:aws:sns:us-east-1:646738440247:EC2-Create-SNS-Topic"
def lambda_handler(event, context):
  sns_client = boto3.client("sns", region_name=awsregion)  
  current_date_time = datetime.now()
  current_time_str = current_date_time.strftime("%H:%M")
  current_time = datetime.strptime(current_time_str, "%H:%M")


  print("Current Time:", current_time)

  with open('./lambda/asg_list.json', 'r') as file:
   data = json.load(file) 
   for asg, attr in data.items():
       desired_cnt=attr["DesiredCount"];
       start_time= datetime.strptime(attr["StartTime"],"%H:%M");
       end_time=datetime.strptime(attr["EndTime"], "%H:%M");    
       message = f"ASG {asg} is running with desired capacity: "+str(desired_cnt)
       subject = f"{asg} ASG not running with desired capacity"
       if start_time <= current_time <= end_time:
        try:
          asg_client = boto3.client("autoscaling",region_name=awsregion)
          response_asg = asg_client.describe_auto_scaling_groups(AutoScalingGroupNames=[asg])          
          if "AutoScalingGroups" in response_asg and response_asg["AutoScalingGroups"]:
             desired_capacity = response_asg["AutoScalingGroups"][0]["DesiredCapacity"]
             if(desired_capacity < desired_cnt):
               response_sns = sns_client.publish(
                   TopicArn=sns_topic_arn,
                   Message=message,
                   Subject=subject
               )
               print(f"Message sent! Message ID: {response_sns['MessageId']}")
          else:
           print(f"Auto Scaling Group '{asg}' not found.")
        except Exception as e:
              print(f"Error sending SNS notification: {str(e)} for {asg}")
       else:
         print(f"{current_time} not falling with in {start_time} and {end_time}")
         
if __name__ == "__main__":  
    print(lambda_handler(None, None))
 

 