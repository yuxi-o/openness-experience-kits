#!/usr/bin/env bash

# SPDX-License-Identifier: Apache-2.0
# Copyright (c) 2019 Intel Corporation

source scripts/ansible-precheck.sh
source scripts/task_log_file.sh

rm -rf /tmp/yamls
cp -a flex/yamls /tmp

ansible-playbook -vv \
    ./ne_controller.yml \
    --inventory inventory.ini
