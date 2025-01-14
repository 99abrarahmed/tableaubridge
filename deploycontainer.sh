echo "Enter your Tableau Cloud username."
read username
if [ -z "$username" ];
then echo "A valid Tableau Cloud username is required to proceed."
exit 1
fi

echo "Enter the name of your Personal Access Token."
read patname
if [ -z "$patname" ];
then echo "A valid Personal Access Token name is required to proceed."
exit 1
fi

echo "Enter the value of your Personal Access Token. (This field will be hidden)"
read -s patvalue
if [ -z "$patvalue" ];
then echo "A valid Personal Access Token value is required to proceed."
exit 1
fi

echo "Enter the Tableau Cloud site (without any spaces or punctuations)."
read sitename
if [ -z "$sitename" ];
then echo "A valid Tableau Cloud site is required to proceed."
exit 1
fi

echo "What do you want to call your Tableau Bridge client? (Default: bridgeclient1)"
read clientname
if [ -z "$clientname" ];
then clientname="bridgeclient1"
fi
echo "The Tableau Bridge client will be called $clientname."

echo "Optional: Provide link to the Tableau Bridge RPM file. Hit return to skip."
read rpmlink

mkdir ~/bridge/ && cd ~/bridge/

yum update -y
yum upgrade -y

yum install wget -y

if [ "$rpmlink" == "" ];
then wget https://downloads.tableau.com/tssoftware/TableauBridge-20243.24.1211.0901.x86_64.rpm
else wget $rpmlink
fi

touch pat.txt
echo "{\"$patname\" : \"$patvalue\"}" > pat.txt

touch Dockerfile

cat<<EOT > Dockerfile
FROM registry.access.redhat.com/ubi8/ubi:latest
RUN mkdir /bridge
WORKDIR /bridge

COPY TableauBridge*.rpm /bridge/
COPY pat.txt /bridge/
RUN chmod 600 /bridge/pat.txt

RUN yum update -y && \
    yum upgrade -y

RUN echo 'export LANG="en_US.utf8"' >> /etc/profile && \
    echo 'export LANGUAGE="en_US.utf8"' >> /etc/profile && \
    echo 'export LC_ALL="en_US.utf8"' >> /etc/profile

RUN ACCEPT_EULA=y yum install -y /bridge/TableauBridge*.rpm

CMD /opt/tableau/tableau_bridge/bin/run-bridge.sh -e --patTokenId="$patname" --userEmail="$username" --client="$clientname" --site="$sitename" --patTokenFile="/bridge/pat.txt"
EOT

docker build . --platform=linux/amd64 -t tableaubridgeimage:latest
docker run -d --name tableaubridgeclient tableaubridgeimage:latest

rm -rf ~/bridge/