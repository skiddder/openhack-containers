
docker run -d \
    --name dataload-azure \
    -e "SQLFQDN=ohcontainer.database.windows.net" \
    -e "SQLUSER=$SQLUSER" \
    -e "SQLPASS=$SA_PASSWORD" \
    -e "SQLDB=mydrivingDB" \
    openhack/data-load:v1