#!/bin/bash

# Grant full read/write access to files
chmod 777 \
    run-services.sh

# make files executable
chmod +x \
    run-services.sh

echo 'Done'