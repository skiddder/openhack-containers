#!/bin/bash
# set variables
PROJECT_NAME='oh-container'
SA_PASSWORD='localtestpw123@'

# build the docker containers for local use
cd ../user-java
docker build --no-cache -f ../../dockerfiles/Dockerfile_0 -t "user-java:1.0" .

cd ../tripviewer
docker build --no-cache -f ../../dockerfiles/Dockerfile_1 -t "tripviewer:1.0" .

cd ../userprofile
docker build --no-cache -f ../../dockerfiles/Dockerfile_2 -t "userprofile:1.0" .

cd ../poi
docker build --no-cache -f ../../dockerfiles/Dockerfile_3 -t "poi:1.0" .

cd ../trips
docker build --no-cache -f ../../dockerfiles/Dockerfile_4 -t "trips:1.0" .


# run containers locally
docker network create $PROJECT_NAME

docker run -d \
    --network $PROJECT_NAME \
    -e 'ACCEPT_EULA=Y' \
    -e "SA_PASSWORD=$SA_PASSWORD" \
    --name 'sqltestdb' \
    -p 1433:1433 \
    mcr.microsoft.com/mssql/server:2017-latest

sleep 20
docker ps
docker logs sqltestdb

docker exec sqltestdb /opt/mssql-tools/bin/sqlcmd \
    -S localhost -U SA -P "$SA_PASSWORD" \
    -Q "CREATE DATABASE mydrivingDB"

docker run -d \
    --network $PROJECT_NAME \
    --name dataload \x
    -e "SQLFQDN=sqltestdb" \
    -e "SQLUSER=sa" \
    -e "SQLPASS=$SA_PASSWORD" \
    -e "SQLDB=mydrivingDB" \
    openhack/data-load:v1

# give some time for data to load
sleep 20
docker logs dataload

docker run -d \
    --network $PROJECT_NAME \
    -p 8080:80 \
    --name poi \
    -e "SQL_PASSWORD=$SA_PASSWORD" \
    -e "SQL_SERVER=sqltestdb" \
    -e "SQL_USER=sa" \
    -e "ASPNETCORE_ENVIRONMENT=Local" \
    tripinsights/poi:1.0

docker run -d \
    --network $PROJECT_NAME \
    -p 8081:80 \
    --name trips \
    -e "SQL_PASSWORD=$SA_PASSWORD" \
    -e "SQL_SERVER=sqltestdb" \
    -e "SQL_USER=sa" \
    -e "OPENAPI_DOCS_URI=http://temp" \
    tripinsights/trips:1.0

docker run -d \
    --network $PROJECT_NAME \
    -p 8082:80 \
    --name user-java \
    -e "SQL_PASSWORD=$SA_PASSWORD" \
    -e "SQL_SERVER=sqltestdb" \
    -e "SQL_USER=sa" \
    tripinsights/user-java:1.0 

docker run -d \
    --network $PROJECT_NAME \
    -p 8083:80 \
    --name userprofile \
    -e "SQL_PASSWORD=$SA_PASSWORD" \
    -e "SQL_SERVER=sqltestdb" \
    -e "SQL_USER=sa" \
    tripinsights/userprofile:1.0

docker run -d \
    --network $PROJECT_NAME \
    -p 80:80 \
    --name tripviewer \
    -e "USERPROFILE_API_ENDPOINT=http://172.18.0.6" \
    -e "TRIPS_API_ENDPOINT=http://172.18.0.4" \
    -e "BING_MAPS_KEY=Ak8jy2wtOSzTX2ZIMowc6b0_SAFfTNXwCP9cl3hVNWy1xJN2CBR6i5k_9mftdQWA" \
    tripinsights/tripviewer:1.0

docker ps

printf "call poi\n"
curl -X GET 'http://localhost:8080/api/poi'
