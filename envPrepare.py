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

import boto3
import json
import logging
import os
import sys
from botocore.exceptions import ClientError
from dotenv import load_dotenv

# Load environment variables
load_dotenv("/Users/cupertino/Documents/.env")

region_name = os.getenv("AWS_REGION")
policy_arn = os.getenv("AWS_POLICY_ARN")
thumbprint = os.getenv("THUMBPRINT")
audience = os.getenv("AUDIENCE")
role_name = os.getenv("ROLE_NAME")
oidc_url = os.getenv("OIDC_URL")

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
)
logger = logging.getLogger(__name__)


class OIDCConnector:
    """
    Class to manage AWS IAM resources for OpenID Connect (OIDC) integration.
    """

    def __init__(self, region_name=region_name):
        self.iam_client = boto3.client("iam", region_name=region_name)

    def check_oidc_provider_exists(self, url):
        """
        Checks if an OIDC provider with the given URL exists.
        """
        try:
            existing_providers = (
                self.iam_client.list_open_id_connect_providers()
            )  # noqa: E501
            for provider in existing_providers["OpenIDConnectProviderList"]:
                provider_arn = provider["Arn"]
                details = self.iam_client.get_open_id_connect_provider(
                    OpenIDConnectProviderArn=provider_arn,
                )
                if details.get("Url") == url:
                    logger.info(
                        "OIDC provider '%s' already exists: %s",
                        url,
                        provider_arn,
                    )
                    return True
            return False
        except ClientError as e:
            logger.error("Error checking the OIDC provider: %s", e)
            raise

    def check_role_exists(self, role_name):
        """
        Checks if a role with the given name exists.
        """
        try:
            self.iam_client.get_role(RoleName=role_name)
            logger.info("The role '%s' already exists.", role_name)
            return True
        except self.iam_client.exceptions.NoSuchEntityException:
            return False
        except ClientError as e:
            logger.error("Error checking the role '%s': %s", role_name, e)
            raise

    def create_oidc_provider(self, url, thumbprint, audience):
        """
        Creates an OIDC identity provider in AWS.
        """
        try:
            response = self.iam_client.create_open_id_connect_provider(
                Url=url,
                ThumbprintList=[thumbprint],
                ClientIDList=[audience],
            )
            oidc_arn = response["OpenIDConnectProviderArn"]
            logger.info("OIDC provider successfully created: %s", oidc_arn)
            return oidc_arn
        except ClientError as e:
            logger.error("Could not create the OIDC provider: %s", e)
            raise

    def create_role_with_oidc(self, role_name, oidc_provider_arn, audience):
        """
        Creates an IAM role with a trust policy for the OIDC provider.
        """
        trust_policy = {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Effect": "Allow",
                    "Principal": {"Federated": oidc_provider_arn},
                    "Action": "sts:AssumeRoleWithWebIdentity",
                    "Condition": {
                        "StringLike": {
                            "token.actions.githubusercontent.com:sub": (
                                f"repo:{audience}:*"
                            )
                        }
                    },
                }
            ],
        }

        try:
            response = self.iam_client.create_role(
                RoleName=role_name,
                AssumeRolePolicyDocument=json.dumps(trust_policy),
                Description="Role for GitHub Actions OIDC integration",
            )
            role_arn = response["Role"]["Arn"]
            logger.info("Role '%s' successfully created.", role_name)
            return role_arn
        except ClientError as e:
            logger.error("Could not create the role '%s': %s", role_name, e)
            raise

    def attach_policy_to_role(self, role_name, policy_arn=policy_arn):
        """
        Attaches a managed policy to the IAM role.
        """
        try:
            self.iam_client.attach_role_policy(
                RoleName=role_name,
                PolicyArn=policy_arn,
            )
            logger.info(
                "Policy '%s' successfully attached to role '%s'.",
                policy_arn,
                role_name,
            )
        except ClientError as e:
            logger.error(
                "Could not attach the policy '%s' to role '%s': %s",
                policy_arn,
                role_name,
                e,
            )
            raise


def main():
    """
    Orchestrates the creation of OIDC provider and IAM role.
    """
    connector = OIDCConnector()

    if connector.check_oidc_provider_exists(oidc_url):
        logger.error("The OIDC provider already exists. Exiting the script.")
        sys.exit(1)

    if connector.check_role_exists(role_name):
        logger.info("The role already exists. Exiting the script.")
        sys.exit(1)

    oidc_provider_arn = connector.create_oidc_provider(
        oidc_url,
        thumbprint,
        audience,
    )
    role_arn = connector.create_role_with_oidc(
        role_name,
        oidc_provider_arn,
        audience,
    )
    connector.attach_policy_to_role(role_name, policy_arn)

    logger.info("OIDC configuration completed. Role ARN: %s", role_arn)


if __name__ == "__main__":
    main()
