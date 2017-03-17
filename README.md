# portable-k8s-demo

This is demo infrastructure code for a portable Kubernetes cluster

# Microservices

The code for our Microservices is not included

# Code Status

Not all of the code has been fully parameterised given the time constraints, so this should be checked if you intend to use this.  Where used the domain names have been changed to example.com, and all Docker and git repositories referenced have been replaced with example.com based names (other than the git repositories which reference infrastructure code - which points to this repository for clarity).  Running:

	grep -rl 'example.com' .
	
at the top level of the repository should give you an idea of any names that need changing.

Environment variables are often passed to scripts via Concourse tasks, so the files in ci/tasks should be checked (generally for the cluster name set as TEAMID and the kops S3 state store location).

# Concourse

Concourse is used as our CI/CD server and all files related to the Concourse pipelines are stored in the ci folder.  The [Concourse](https://concourse.ci) website should be visited to learn about deploying Concourse, there is a Vagrant based distribution for testing and in AWS Pivotal Labs provide a ready-configured AMI to quickly build a Concourse server.  The fly command should be used to submit jobs, our process used four pipelines used for various tasks (you may not want to use all):

*  pipeline.yml - Test and build the microservices then build them into a Docker image and upload to our Docker repo.
*  pipeline_kops.yml - Build a Docker image with kops, kubectl, jq and wget installed - this Docker image is required for the pipeline_spin.yml and pipeline_deploy.yml pipelines.  Automated on changes to the ci/docker folder in the infrastructure (i.e. this) repository.
*  pipeline_spin.yml - Builds the cluster using the Docker image created by pipeline_kops.yml and the spin.sh script.  Manually triggered.
*  pipeline_deploy.yml - Test and build the microservices, build them into a Docker image and upload, then force a rolling deployment into our cluster (again this uses the Docker image created by pipeline_kops.yml).


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
