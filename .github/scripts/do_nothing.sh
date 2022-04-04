#!/bin/bash
set -euxo pipefail

cat <<MSG
do nothing.

See:
- https://github.com/sensuikan1973/pedax/issues/415
- https://docs.github.com/ja/repositories/configuring-branches-and-merges-in-your-repository/defining-the-mergeability-of-pull-requests/troubleshooting-required-status-checks#handling-skipped-but-required-checks
- https://docs.github.com/ja/pull-requests/collaborating-with-pull-requests/incorporating-changes-from-a-pull-request/automatically-merging-a-pull-request

why do you use reusable workflow ?
https://docs.github.com/ja/actions/using-workflows/reusing-workflows#limitations at 2022/04/05 says
"The strategy property is not supported in any job that calls a reusable workflow."
MSG
