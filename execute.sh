#!/bin/bash
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
#
# Authors:
# - Paul Nilsson, paul.nilsson@cern.ch, 2023

# Note: this file must be executable

echo "Launching PanDA pilot wrapper for user `whoami`"
echo "Python version: `python3 -V`"
date
export PYTHONPATH=/usr/local/lib/python3.6/site-packages/rucio:/usr/local/lib/python3.6/site-packages/dask:/usr/local/lib/python3.6/site-packages/pilot3
env
echo "Executing pilot"
python3 /usr/local/lib/python3.6/site-packages/pilot3/pilot.py --noproxyverification --pod -d -w $PILOT_WORKFLOW -j $PILOT_JOB_LABEL -q $PILOT_QUEUE --workdir $PILOT_WORKDIR --pilot-user $PILOT_USER --url $PILOT_PANDA_SERVER --lifetime $PILOT_LIFETIME
exit $?
