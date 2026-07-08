AWSTemplateFormatVersion: '2010-09-09'
Description: 'Creazione Bucket S3 Sicuro'

Parameters:
  EnvironmentName:
    Type: String
    Default: dev

Resources:
  MyDevOpsStorageBucket:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: !Sub 'azienda-devops-${EnvironmentName}'
      PublicAccessBlockConfiguration:
        BlockPublicAcls: true
        BlockPublicPolicy: true

Outputs:
  BucketARN:
    Value: !GetAtt MyDevOpsStorageBucket.Arn