echo "Enter your Tableau Cloud username."
read username
if [ -z "$username" ];
then echo "You have not entered your Tableau Cloud username. The installer will now exit."
exit 1
fi

echo "Enter the name of your Personal Access Token."
read patname
if [ -z "$patname" ];
then echo "You have not entered the Personal Access Token name. The installer will now exit."
exit 1
fi

echo "Enter the value of your Personal Access Token. (This field will be hidden)"
read -s patvalue
if [ -z "$patvalue" ];
then echo "You have not entered the Personal Access Token value. The installer will now exit."
exit 1
fi

echo "Enter the Tableau Cloud site (without any spaces or punctuations)."
read sitename
if [ -z "$sitename" ];
then echo "You have not entered the Tableau Cloud site name. The installer will now exit."
exit 1
fi

echo "What do you want to call your Tableau Bridge client? (Default: bridgeclient1)"
read clientname
if [ -z "$clientname" ];
then clientname="bridgeclient1"
fi
echo "The Tableau Bridge client will be called \"$clientname.\""

echo "Provide a download link to the Tableau Bridge RPM file."
read rpmlink
if [ -z "$rpmlink" ];
then 
echo "You have not provided a download link to the Tableau Bridge RPM package. The installer will now exit."
exit 1
fi

mkdir ~/bridge/ && cd ~/bridge/

yum update -y
yum upgrade -y

yum install wget -y

if [ -z "$rpmlink" ];
then 
echo "You have not provided a download link to the Tableau Bridge RPM package. The installer will now exit."
exit 1
fi
wget $rpmlink

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
