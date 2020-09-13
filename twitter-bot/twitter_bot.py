# pylint: disable=W0613

import os
import sys
import requests
import boto3
import logging
from base64 import b64decode

log = logging.getLogger()
log.setLevel(logging.DEBUG)

log.debug('Logging enabled')

ACCOUNTS_CHECK_KEY = "twitter_accounts_check"
ACCOUNTS_FOUND_KEY = "twitter_accounts_found"
ACCOUNTS_CHECK_PATH = '/tmp/{}'.format(ACCOUNTS_CHECK_KEY)
ACCOUNTS_FOUND_PATH = "/tmp/{}".format(ACCOUNTS_FOUND_KEY)
S3_CLIENT = boto3.client('s3', region_name='us-east-1')
KMS_CLIENT = boto3.client('kms', region_name='us-east-1')
SLACK_WEBHOOK = KMS_CLIENT.decrypt(CiphertextBlob=b64decode(os.environ['SLACK_WEBHOOK']))['Plaintext']


def post_to_slack(user=None, message=None):
    log.debug(f"Posting to slack: {user} : {message}")
    msg = f'{user} : {message}'
    slack_payload = {
        "channel": "#twitter-testing",
        "username": "twitter-bot",
        "text": msg,
        "icon_emoji": ":ghost:"
    }
    requests.post(SLACK_WEBHOOK, json=slack_payload)

def handler(event, context):
    print("Starting handler")
    """ main Lambda handler """
    unavailable_accounts = []

    available_accounts = []
    available_accounts.append('savewithfacts')
    available_accounts.append('jeffabailey')

    for user in available_accounts:
        request_url = "https://twitter.com/{}".format(user)
        request = requests.get(request_url)
        result = request.text.find("that page doesn’t exist!")
        #log.debug(request.text)

        if result != -1:
            log.debug("account {} does not exist!".format(user))
            post_to_slack(user=user)
        else:
            post_to_slack(user=user, message="Found a user")    
