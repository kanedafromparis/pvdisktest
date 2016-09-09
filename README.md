# Docker Image to test disk performamce 

In order to test you docker image you can execute 

tmpDocId=`docker build disktest/ | grep "Successfully built" | awk '{print $3}'` && \
docker run --rm -t -i -e AUTHUSER="YOURGMAILAUTH" -e AUTHPASS="YOURGMAILPASS" -e DESTMAIL="YOURGMAILDEST" $tmpDocId
