#!/bin/sh
echo "
2c2
< host=PLACEHOLDER
---
> host=$DEPLOY_HOST
" | patch etc/foo.conf
