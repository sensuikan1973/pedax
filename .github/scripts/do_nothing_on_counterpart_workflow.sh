#!/bin/bash
set -euxo pipefail

cat <<MSG
do nothing on counterpart workflow for protected branch.

[FAQ]
Q. What is the purpose of this script ?
A. I want to enable auto-merge with keeping code quality and path trigger logic.
  See:
  - https://docs.github.com/ja/repositories/configuring-branches-and-merges-in-your-repository/defining-the-mergeability-of-pull-requests/troubleshooting-required-status-checks#handling-skipped-but-required-checks
  - https://github.com/sensuikan1973/pedax/issues/415
  - https://github.com/sensuikan1973/pedax/settings/branch_protection_rules/19119198
  - https://docs.github.com/ja/pull-requests/collaborating-with-pull-requests/incorporating-changes-from-a-pull-request/automatically-merging-a-pull-request


Q. Can I use reusable workflow ?
A. No.
  https://docs.github.com/ja/actions/using-workflows/reusing-workflows#limitations at 2022/04/05 says
  "The strategy property is not supported in any job that calls a reusable workflow."

Q. What is the origin of "counterpart" ?
A. See: https://docs.github.com/ja/repositories/configuring-branches-and-merges-in-your-repository/defining-the-mergeability-of-pull-requests/troubleshooting-required-status-checks#handling-skipped-but-required-checks
MSG
