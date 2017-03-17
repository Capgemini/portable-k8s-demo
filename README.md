# portable-k8s-demo

Not all of the code has been fully parameterised given the time constraints, so this should be checked if you intend to use this.  Where used the domain names have been changed to example.com, and all Docker and git repositories referenced have been replaced with example.com based names (other than the git repositories which reference infrastructure code - which points to this repository for clarity).  Running:

	grep -rl 'example.com' .
	
at the top level of the repository should give you an idea of any names that need changing.

Environment variables are often passed to scripts via Concourse tasks, so the files in ci/tasks should be checked (generally for the cluster name set as TEAMID and the kops S3 state store location).

# Credentials

Concourse requires a credentials file which should be set per user (if they will be uploading pipelines to Concourse) and should be stored as ci/credentials.yml.  The format we have used is:

	email: user-email
	aws-access-key-id: user-aws-akid
	aws-secret-access-key: user-aws-sak
	git-key: |
			-----BEGIN RSA PRIVATE KEY-----
			...
			-----END RSA PRIVATE KEY-----

The Dockerfile that we use to spin up our cluster also requires AWS credentials (ideally and given time we would pull these in in a different way).  These are currently brught into the Dockerfile via ci/docker/credentials and follow the standard aws cli format:

	[default]
	aws_access_key_id=AKIAI7DEIP5IYS5ZCNLQ
	aws_secret_access_key=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
