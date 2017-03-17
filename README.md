# portable-k8s-demo

Not all of the code has been fully parameterised given the time constraints, so this should be checked if you intend to use this.

# Credentials

Concourse requires a credentials file which should be set per user (if they will be uploading pipelines to Concourse) and should be stored as ci/credentials.yml.  The format we have used is:

	email: user-email
	aws-access-key-id: user-aws-akid
	aws-secret-access-key: user-aws-sak
	git-key: |
			-----BEGIN RSA PRIVATE KEY-----
						...
			-----END RSA PRIVATE KEY-----
