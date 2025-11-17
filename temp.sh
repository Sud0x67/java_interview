java -jar modules/swagger-codegen-cli/target/swagger-codegen-cli.jar generate -i ./swagger-v2.json -l java -o samples/client/java                             


#!/bin/bash

# get client dir
SOURCE="$0"
while [ -h "$SOURCE"  ]; do # resolve $SOURCE until the file is no longer a symlink
    DIR="$( cd -P "$( dirname "$SOURCE"  )" && pwd  )"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /*  ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE"  )" && pwd  )"

# get first parameter as port, 8280 by default


PORT="8280"
if [ "" != "$1" ]; then
  PORT="$1"
fi

echo "curl -s 'localhost:$PORT/gateway/swagger.json' --header 'workspace: default' | jq -M > $DIR/swagger-gateway.json"
curl -s "localhost:$PORT/gateway/swagger.json" --header "workspace: default" | jq -M > $DIR/swagger-gateway.json

# generate code for swagger API
echo "generate swagger API code"
# shellcheck disable=SC2164
cd $DIR
pwd
make

# publish to maven local
echo "publish to maven local"
# shellcheck disable=SC2103
cd ..
pwd
./gradlew vvp-gateway-client:publishToMavenLocal

CODEGEN ?= swagger-codegen

.PHONY: swagger-codegen
swagger-codegen: swagger-codegen-gateway

.PHONY: swagger-codegen-gateway
swagger-codegen-gateway:
@$(CODEGEN) version | grep '^2\.' > /dev/null || (echo >&2 "swagger-codegen 2.x required"; exit 1)
rm -rf generated
$(CODEGEN) generate \
--lang java \
--input-spec swagger-gateway.json \
--output generated \
--api-package com.ververica.platform.gateway.client.api \
--model-package com.ververica.platform.gateway.client.model \
--invoker-package com.ververica.platform.gateway.client \
-Djava8,dateLibrary=java8,library=okhttp-gson,modelDocs=false,modelTests=false,apiTests=false,apiDocs=false,models,apis,supportingFiles,hideGenerationTimestamp=true



