FROM debian

RUN apt-get update && apt-get install -y \
	wget \
	curl \
	awscli \
	openssh-server \
	jq
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
RUN chmod +x ./kubectl
RUN mv ./kubectl /usr/local/bin/kubectl
RUN wget -O kops https://github.com/kubernetes/kops/releases/download/1.5.1/kops-linux-amd64
RUN chmod +x kops
RUN mv kops /usr/local/bin/
RUN mkdir /root/.ssh
RUN ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
