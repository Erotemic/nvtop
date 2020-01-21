#!/bin/bash
__heredoc__="""

MB_PYTHON_TAG=cp37-cp37m ./run_manylinux_build.sh

MB_PYTHON_TAG=cp36-cp36m ./run_manylinux_build.sh

MB_PYTHON_TAG=cp35-cp35m ./run_manylinux_build.sh

MB_PYTHON_TAG=cp27-cp27m ./run_manylinux_build.sh

# MB_PYTHON_TAG=cp27-cp27mu ./run_nmultibuild.sh

"""


#DOCKER_IMAGE=${DOCKER_IMAGE:="quay.io/pypa/manylinux2010_x86_64"}
DOCKER_IMAGE=${DOCKER_IMAGE:="pytorch/manylinux-cuda101"}
#PARENT_USER=${PARENT_USER:="$USER"}

# Valid multibuild python versions are:
# cp27-cp27m  cp27-cp27mu  cp34-cp34m  cp35-cp35m  cp36-cp36m  cp37-cp37m
#MB_PYTHON_TAG=${MB_PYTHON_TAG:="py2.py3-none"}
MB_PYTHON_TAG=${MB_PYTHON_TAG:="cp37-cp37m"}


if [ "$_INSIDE_DOCKER" != "YES" ]; then

    set -e
    docker run --runtime=nvidia --rm \
        -v $PWD:/io \
        -e _INSIDE_DOCKER="YES" \
        -e MB_PYTHON_TAG="$MB_PYTHON_TAG" \
        -e NAME="$NAME" \
        -e VERSION="$VERSION" \
        $DOCKER_IMAGE bash -c 'cd /io && ./run_manylinux_build.sh'

    __interactive__='''
    docker run --runtime=nvidia --rm \
        -v $PWD:/io \
        -e _INSIDE_DOCKER="YES" \
        -e MB_PYTHON_TAG="$MB_PYTHON_TAG" \
        -e NAME="$NAME" \
        -e VERSION="$VERSION" \
        -it $DOCKER_IMAGE bash

    set +e
    set +x
    '''

    exit 0;
else
    set -x
    set -e

    yum install ncurses-devel

    MB_PYTHON_TAG=cp37-cp37m

    VENV_DIR=/root/venv-$MB_PYTHON_TAG
    # Setup a virtual environment for the target python version
    /opt/python/$MB_PYTHON_TAG/bin/python -m pip install pip
    /opt/python/$MB_PYTHON_TAG/bin/python -m pip install setuptools pip virtualenv
    /opt/python/$MB_PYTHON_TAG/bin/python -m virtualenv $VENV_DIR

    source $VENV_DIR/bin/activate 

    cd /io
    pip install scikit-build
    pip install cmake ninja wheel

    # Reasons that this might fail sometimes involve an existing _skbuild
    # directory with a bad configuration.
    python setup.py bdist_wheel

    chmod -R o+rw _skbuild
    chmod -R o+rw dist

    /opt/python/cp37-cp37m/bin/python -m pip install auditwheel
    /opt/python/cp37-cp37m/bin/python -m auditwheel show dist/$NAME-*.whl
    /opt/python/cp37-cp37m/bin/python -m auditwheel repair --plat=manylinux2014_x86_64 dist/$NAME-*.whl
    #/opt/python/cp37-cp37m/bin/python -m auditwheel show dist/$NAME-$VERSION-$MB_PYTHON_TAG*.whl
    #/opt/python/cp37-cp37m/bin/python -m auditwheel repair dist/$NAME-$VERSION-$MB_PYTHON_TAG*.whl
    chmod -R o+rw wheelhouse
    chmod -R o+rw $NAME.egg-info
fi
