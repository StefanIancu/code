#!/usr/bin/env python3

#-*-coding:utf-8 -*-

import os
import boto3
from botocore.exceptions import ClientError

"""A python script for working with Amazon S3"""

ACCESS_KEY = "AWS_ACCES_KEY_ID"
SECRET_KEY = "AWS_SECRET_ACCESS_KEY"
PRI_BUCKET_NAME = "sti2802"
TRANSIENT_BUCKET_NAME = "sti1998"
F1 = "file1.txt"
F2 = "file2.txt"
F3 = "file3.txt"
DIR = "C:\Users\User\Desktop\code-dev-ops\amazon_s3"
DOWN_DIR = """C:\Users\User\Desktop\code-dev-ops\amazon_s3\downloads"""

def upload_file(bucket, directory, file, s3, s3path=None):
    file_path = directory + "/" + file
    remote_path = s3path
    if remote_path is None:
        remote_path = file
    try:
        s3.Bucket(bucket).upload_file(file_path)
    except ClientError as ce:
        print("error", ce)

def download_file(bucket, directory, local_name, key_name, s3):
    file_path = directory + "/" + local_name
    try:
        s3.Bucket(bucket).download_file(key_name, file_path)
    except ClientError as ce:
        print("error", ce)

def delete_files(bucket, keys, s3):
    objects = []
    for key in keys:
        object.append({"Key":key})
    try:
        s3.Bucket(bucket).delete_objects(Delete={"Objects":objects})
    except ClientError as ce:
        print("error", ce)

def list_objects(bucket, s3):
    try:
        response = s3.meta.client.list_objects(Bucket=bucket)
        objects = []
        for content in response["Contents"]:
            objects.append(content["Key"])
        print(bucket, "contains", len(objects), "files")
        return objects
    except ClientError as ce:
        print("error", ce)

def copy_file(source_bucket, destination_bucket, source_key, destination_key, s3):
    try:
        source = {
            "Bucket": source_bucket, 
            "Key" : source_key
        }
        s3.Bucket(destination_bucket).copy(source, destination_key)
    except ClientError as ce:
        print("error", ce)
    
def prevent_public_access(bucket, s3):
    try:
        s3.meta.client.put_public_access_block(Bucket=bucket, PublicAccessBlockConfiguration = {
            "BlockPublicAcls": True,
            "IgnorePublicAcls": True, 
            "BlockPublicPolicy": True, 
            "RestrictPublicBuckets": True
        })
    except ClientError as ce:
        print("error", ce)

def create_bucket(name, s3, secure=False):
    try:
        s3.create_bucket(Bucket=name)
        if secure:
            prevent_public_access(name, s3)
    except ClientError as ce:
        print("error", ce)       

def generate_download_link(bucket, key, expiration_seconds, s3):
    try:
        response = s3.meta.client.generate_presigned_url("get_object", Params = {
            "Bucket": bucket, 
            "Key": key
        }, ExpiresIn=expiration_seconds)
        print(response)
    except ClientError as ce:
        print("error", ce) 

def delete_bucket(bucket, s3):
    try:
        s3.Bucket(bucket).delete()
    except ClientError as ce:
        print("error", ce)

def main():
    """entry point"""
    access = os.getenv(ACCESS_KEY)
    secret = os.getenv(SECRET_KEY)
    s3 = boto3.resource("s3", aws_access_key_id=access, aws_secret_access_key=secret)

    create_bucket(TRANSIENT_BUCKET_NAME, s3, True)

    # here to insert the desired function

    if __name__ == "__main__":
        main()