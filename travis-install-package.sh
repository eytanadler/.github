#!/bin/bash
set -ev

# Copy over the correct config file and modify as needed
docker exec -it app /bin/bash -c ". $BASHRC && cd $DOCKER_WORKING_DIR && cp $CONFIG_MK config/config.mk";
# compile real build
docker exec -it app /bin/bash -c ". $BASHRC && cd $DOCKER_WORKING_DIR && make"
# compile complex build
# check that the complex make file exists (in the Travis VM, no need to check in Docker)
if [ -f "Makefile_CS" ]; then
    docker exec -it app /bin/bash -c ". $BASHRC && cd $DOCKER_WORKING_DIR && make -f Makefile_CS PETSC_ARCH=complex-opt-\$COMPILERS-\$PETSCVERSION";
fi
# Install Python interface
docker exec -it app /bin/bash -c ". $BASHRC && cd $DOCKER_WORKING_DIR && pip install ."