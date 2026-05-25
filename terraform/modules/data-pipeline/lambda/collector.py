import json
import os
import time
import urllib.request
from datetime import datetime, timezone

import boto3


s3 = boto3.client("s3")
sqs = boto3.client("sqs")


def lambda_handler(event, context):
    raw_bucket_name = os.environ["RAW_BUCKET_NAME"]
    queue_url = os.environ["QUEUE_URL"]
    environment = os.environ.get("ENVIRONMENT", "dev")
    project_name = os.environ.get("PROJECT_NAME", "moment")
    public_data_api_url = os.environ.get("PUBLIC_DATA_API_URL", "")

    collected_at = datetime.now(timezone.utc).isoformat()
    payload = {
        "project": project_name,
        "environment": environment,
        "collectedAt": collected_at,
        "source": "sample",
        "publicDataApiUrl": public_data_api_url,
        "event": event,
    }

    if public_data_api_url:
        try:
            with urllib.request.urlopen(public_data_api_url, timeout=10) as response:
                payload["source"] = "public-data-api"
                payload["statusCode"] = response.status
                payload["body"] = response.read().decode("utf-8")[:5000]
        except Exception as exc:
            payload["source"] = "public-data-api-error"
            payload["error"] = str(exc)

    object_key = f"raw/{environment}/public-data/{int(time.time())}.json"

    s3.put_object(
        Bucket=raw_bucket_name,
        Key=object_key,
        Body=json.dumps(payload, ensure_ascii=False).encode("utf-8"),
        ContentType="application/json",
    )

    message = {
        "bucket": raw_bucket_name,
        "key": object_key,
        "environment": environment,
        "collectedAt": collected_at,
    }

    sqs.send_message(
        QueueUrl=queue_url,
        MessageBody=json.dumps(message, ensure_ascii=False),
    )

    return {
        "statusCode": 200,
        "body": message,
    }
