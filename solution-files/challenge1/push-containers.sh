# build the docker containers for use in ACR
ACR_FQDN="registryvnb0999.azurecr.io"
docker login $ACR_FQDN

IMAGES=("user-java:Dockerfile_0" "tripviewer:Dockerfile_1" "userprofile:Dockerfile_2" "poi:Dockerfile_3" "trips:Dockerfile_4")

for i in "${IMAGES[@]}"
do
    echo '#####################################'
    KEY="${i%%:*}"
    VALUE="${i##*:}"
    echo $KEY
    echo $VALUE
    cd ../$KEY
    docker build --no-cache \
        --build-arg IMAGE_VERSION="1.0" \
        --build-arg IMAGE_CREATE_DATE="`date -u +"%Y-%m-%dT%H:%M:%SZ"`" \
        --build-arg IMAGE_SOURCE_REVISION="`git rev-parse HEAD`" \
        -f ../../dockerfiles/$VALUE -t "$ACR_FQDN/$KEY:1.0" .
    docker push $ACR_FQDN/$KEY:1.0
done

