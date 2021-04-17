#!/bin/bash

# Either this or the similarly named yaml file will work

kubectl create secret generic sql \
    --from-literal=SQL_USER=<sql username> \
    --from-literal=SQL_PASSWORD=<sql password> \
    --from-literal=SQL_SERVER=<sql server> \
    --from-literal=SQL_DBNAME=<sql dbname>
