#!/bin/bash
SOURCE="$0"
while [ -h "$SOURCE"  ]; do # resolve $SOURCE until the file is no longer a symlink
    DIR="$( cd -P "$( dirname "$SOURCE"  )" && pwd  )"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /*  ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE"  )" && pwd  )"

curl -s http://localhost:12345/dolphinscheduler/v3/api-docs | jq -M > $DIR/openapi-v3.json


java -jar modules/swagger-codegen-cli/target/swagger-codegen-cli.jar generate \
--lang java \
--input-spec$DIR/openapi-v3.json \
--output generated \
--api-package com.ververica.platform.gateway.client.api \
--model-package com.ververica.platform.gateway.client.model \
--invoker-package com.ververica.platform.gateway.client \
-Djava8,dateLibrary=java8,library=okhttp-gson,modelDocs=false,modelTests=false,apiTests=false,apiDocs=false,models,apis,supportingFiles,hideGenerationTimestamp=true
