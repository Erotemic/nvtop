#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Update Requirments:
    # Requirements are broken down by type in the `requirements` folder, and
    # `requirments.txt` lists them all. Thus we autogenerate via:

    cat requirements/*.txt | sort -u | grep -o '^[^#]*' >  requirements.txt
"""
from setuptools import find_packages
from skbuild import setup

# Scikit-build extension module logic
compile_setup_kw = dict(
    # cmake_languages=('C', 'CXX', 'CUDA'),
    cmake_source_dir='.',
    # cmake_source_dir='kwimage',
)

if __name__ == '__main__':
    setup(
        name='nvtop',
        version='0.0.1',
        # author='Jon Crall',
        # author_email='jon.crall@kitware.com',
        # long_description=parse_description(),
        # long_description_content_type='text/x-rst',
        packages=find_packages(include='kwimage.*'),
        classifiers=[
            # List of classifiers available at:
            # https://pypi.python.org/pypi?%3Aaction=list_classifiers
            'Development Status :: 4 - Beta',
        ],
        **compile_setup_kw
    )
