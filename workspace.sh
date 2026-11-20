#!/bin/bash

USERID=$(id -u)
if [ $USERID -ne 0 ]
then
    echo "Please run this script with root access."
    exit 1 # manually exit if error comes.
else
    echo "You are super user."
fi

#------------------------------------------------------------------------------------------------------

# docker installation
dnf -y install dnf-plugins-core
dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
systemctl start docker
systemctl enable docker
usermod -aG docker ec2-user
echo "Logout and Login again"

#------------------------------------------------------------------------------------------------------

# kubectl installation
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.31.0/2024-09-12/bin/linux/amd64/kubectl
chmod +x ./kubectl
mv kubectl /usr/local/bin/kubectl
kubectl version

#------------------------------------------------------------------------------------------------------

# eksctl installation
# for ARM systems, set ARCH to: `arm64`, `armv6` or `armv7`
ARCH=amd64
PLATFORM=$(uname -s)_$ARCH
curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz"
# (Optional) Verify checksum
# curl -sL "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_checksums.txt" | grep $PLATFORM | sha256sum --check
tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && rm eksctl_$PLATFORM.tar.gz
mv /tmp/eksctl /usr/local/bin
eksctl version

#------------------------------------------------------------------------------------------------------

# kubens
git clone https://github.com/ahmetb/kubectx /opt/kubectx
ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
ln -s /opt/kubectx/kubens /usr/local/bin/kubens

#------------------------------------------------------------------------------------------------------

# Run aws configure
# Give credentials
aws configure

#------------------------------------------------------------------------------------------------------

# EBS-CSI-Drivers installation
kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=release-1.36"

# EFS-CSI-Drivers installation
# Replace release-X.X with your desired branch
kubectl kustomize \
    "github.com/kubernetes-sigs/aws-efs-csi-driver/deploy/kubernetes/overlays/stable/ecr/?ref=release-3.6" > private-ecr-driver.yaml
kubectl apply -f private-ecr-driver.yaml

#------------------------------------------------------------------------------------------------------

# k9s installation
curl -sS https://webinstall.dev/k9s | bash

#------------------------------------------------------------------------------------------------------

# Apache Benchmark
sudo dnf install -y httpd-tools

#------------------------------------------------------------------------------------------------------

# Helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4
chmod 700 get_helm.sh
./get_helm.sh

#------------------------------------------------------------------------------------------------------

