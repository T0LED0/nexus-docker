#!/usr/bin/env bash

# env fixed
TOKEN_OLD=0

# check var
variables=("BEAREN" "REGISTRY" "REPOSITORY_SOURCE" "REPOSITORY_DOCKER" "NEXUS_PASS" "NEXUS_USER" "S3" "AWS_ACCESS_KEY_ID" "AWS_SECRET_ACCESS_KEY" "AWS_DEFAULT_REGION")

for var in "${variables[@]}"; do
    if [ -z "${!var+x}" ];
    then
        echo "The variables are not definied!"
        exit 1
    fi
done

aws configure set region $AWS_DEFAULT_REGION
aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY

# Check requirements
if which curl &> /dev/null && \
    which jq &> /dev/null && \
    which aws &> /dev/null && \
    which docker &> /dev/null;    
then
    echo "All requirements are installed. Continuing the script..."
    echo "Get path docker"

    curl -X 'GET' "$REPOSITORY_SOURCE/service/rest/v1/search?sort=name&repository=$REPOSITORY_DOCKER&format=docker" \
    --header "Authorization: Basic $BEAREN" -H 'accept: application/json' > nexus.json
    
    TOKEN=$(cat nexus.json | grep continuationToken | cut -d ":" -f 2 | sed 's/"//g' | sed 's/ //g')

    cat nexus.json | jq -r '.items[] | .name + ":" + .version' | grep -E "((stable|multi-tenancy|arm)$)|(devops)" > list.txt

    echo "$NEXUS_PASS" | docker login --username "$NEXUS_USER" --password-stdin $REGISTRY

    while true
    do
        echo "Step 2"
        echo "Loop get list docker pages with token"
        if [ "$TOKEN" != "$TOKEN_OLD" ];
        then
            TOKEN_OLD=$TOKEN

            curl -X 'GET' "$REPOSITORY_SOURCE/service/rest/v1/search?continuationToken=$TOKEN&sort=name&repository=$REPOSITORY_DOCKER&format=docker" \
            --header "Authorization: Basic $BEAREN" -H 'accept: application/json' > nexus.json

            TOKEN=$(cat nexus.json | grep continuationToken | cut -d ":" -f 2 | sed 's/"//g' | sed 's/ //g')

            cat nexus.json | jq -r '.items[] | .name + ":" + .version' | grep -E "((stable|multi-tenancy|arm)$)|(devops)" >> list.txt
        else
            echo "Step 3"
            echo "Docker pull and push"
            mkdir -p ./images ./log
            
            process_line() {
                echo "Processando linha: $1"
                docker pull $REGISTRY/$line
                if [ $? -eq 0 ]
                then
                    docker save $REGISTRY/$line | gzip > "./images/$(echo $line | sed 's/\//_/g').tar.gz"

                    echo "copy tar for aws s3"
                    aws s3 sync ./images $S3/docker/ --size-only

                    docker rmi $REGISTRY/$line
                    cat ./list.txt >> ./log/image_list.txt
                    cat ./nexus.json >> ./log/nexus.json
                    rm -rf ./images/*
                else
                    echo "$line failure layer" >> ./log/image_error.txt
                fi
            }
            count=0
            while IFS= read -r line || [[ -n "$line" ]]; do
                process_line "$line" &

                ((count++))

                if ((count >= 10)); then
                    wait
                    count=0
                fi

            done < list.txt
            rm -rf ./list.txt 2>/dev/null
            wait
        fi
    done

    aws s3 cp ./log $S3/docker/$(date +"%Y-%m-%d")
    docker system prune -af
else
    echo "Some requirements are not installed. Please install them before continuing."
    exit 1
fi
