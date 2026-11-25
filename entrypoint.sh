#!/bin/bash

set -e

./rustserver fu
./rustserver mu
./rustserver start

exec "$@"
