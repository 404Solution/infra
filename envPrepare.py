# ------------------------------------------------------------------------------ # noqa: E501
# Script Name: envPrepare.py
# Description:
#     Automates creation of an OIDC provider and IAM role in AWS
#     for GitHub Actions integration using Boto3.
# Author: 404Solution
# Date Created: 2025-04-16
# Version: 1.0.0
# Usage:
#     Ensure environment variables are defined in a .env file before execution.
#     - AWS_REGION
#     - AWS_POLICY_ARN
#     - THUMBPRINT
#     - AUDIENCE
#     - ROLE_NAME
#     - OIDC_URL
# ------------------------------------------------------------------------------ # noqa: E501

import json
import logging
import os
import sys
import boto3
from botocore.exceptions import ClientError
from dotenv import load_dotenv

# Load environment variables
load_dotenv("/Users/cupertino/Documents/.env")

region_name = os.getenv("AWS_REGION")
policy_arn = os.getenv("AWS_POLICY_ARN")
thumbprint = os.getenv("THUMBPRINT")
role_name = os.getenv("ROLE_NAME")
audience = os.getenv("AUDIENCE")
oidc_url = os.getenv("OIDC_URL")

sub_pattern = os.getenv("SUB_PATTERN")
if not sub_pattern:
    logging.critical("Environment variable SUB_PATTERN is required.")
    sys.exit(1)

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
)
logger = logging.getLogger(__name__)


class OIDCConnector:
    """Manage AWS IAM resources for OpenID Connect (OIDC) integration."""

    def __init__(self, region_name: str):
        self.iam_client = boto3.client("iam", region_name=region_name)

    def oidc_provider_exists(self, url: str) -> bool:
        """Return True if an OIDC provider with that URL already exists."""
        try:
            for p in self.iam_client.list_open_id_connect_providers()[
                "OpenIDConnectProviderList"
            ]:
                details = self.iam_client.get_open_id_connect_provider(
                    OpenIDConnectProviderArn=p["Arn"]
                )
                if details.get("Url") == url:
                    logger.info(
                        "OIDC provider '%s' already exists (%s)", url, p["Arn"]
                    )  # noqa: E501
                    return True
            return False
        except ClientError as exc:
            logger.error("Error listing OIDC providers: %s", exc)
            raise

    def create_oidc_provider(self, url: str, thumb: str, aud: str) -> str:
        """Create the OIDC provider and return its ARN."""
        try:
            resp = self.iam_client.create_open_id_connect_provider(
                Url=url,
                ThumbprintList=[thumb],
                ClientIDList=[aud],
            )
            arn = resp["OpenIDConnectProviderArn"]
            logger.info("OIDC provider created: %s", arn)
            return arn
        except ClientError as exc:
            logger.error("Could not create OIDC provider: %s", exc)
            raise

    def role_exists(self, name: str) -> bool:
        """Return True if the IAM role already exists."""
        try:
            self.iam_client.get_role(RoleName=name)
            logger.info("Role '%s' already exists.", name)
            return True
        except self.iam_client.exceptions.NoSuchEntityException:
            return False
        except ClientError as exc:
            logger.error("Error checking role '%s': %s", name, exc)
            raise

    def create_role_with_oidc(self, name: str, oidc_arn: str) -> str:
        """Create an IAM role trusted by the OIDC provider."""
        trust_policy = {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Effect": "Allow",
                    "Principal": {"Federated": oidc_arn},
                    "Action": "sts:AssumeRoleWithWebIdentity",
                    "Condition": {
                        "StringEquals": {
                            "token.actions.githubusercontent.com:aud": audience  # noqa: E501
                        },
                        "StringLike": {
                            "token.actions.githubusercontent.com:sub": sub_pattern  # noqa: E501
                        },
                    },
                }
            ],
        }

        try:
            resp = self.iam_client.create_role(
                RoleName=name,
                AssumeRolePolicyDocument=json.dumps(trust_policy),
                Description="Role for GitHub Actions OIDC integration",
            )
            role_arn = resp["Role"]["Arn"]
            logger.info("Role '%s' created.", name)
            return role_arn
        except ClientError as exc:
            logger.error("Could not create role '%s': %s", name, exc)
            raise

    def attach_policy(self, name: str, pol_arn: str) -> None:
        """Attach a managed policy to the role."""
        try:
            self.iam_client.attach_role_policy(
                RoleName=name, PolicyArn=pol_arn
            )  # noqa: E501
            logger.info("Policy '%s' attached to role '%s'.", pol_arn, name)
        except ClientError as exc:
            logger.error(
                "Could not attach policy '%s' to role '%s': %s",
                pol_arn,
                name,
                exc,  # noqa: E501
            )
            raise


def main() -> None:
    connector = OIDCConnector(region_name)

    if connector.oidc_provider_exists(oidc_url):
        logger.error("OIDC provider already exists. Exiting.")
        sys.exit(1)

    if connector.role_exists(role_name):
        logger.info("Role already exists. Exiting.")
        sys.exit(1)

    oidc_arn = connector.create_oidc_provider(oidc_url, thumbprint, audience)
    role_arn = connector.create_role_with_oidc(role_name, oidc_arn)
    connector.attach_policy(role_name, policy_arn)

    logger.info("OIDC configuration completed. Role ARN: %s", role_arn)


if __name__ == "__main__":
    main()
