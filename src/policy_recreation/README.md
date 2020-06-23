# How to reproduce Iot Hub policy changes

## Abstract

Changes in existing policy permissions should not change associated secrets/connection_strings. For example, at Azure Portal you can add/remove permissions to the existing policy without keys regeneration. But if the policy object managed by terraform, it leads to changed connection string.

## Steps to reproduce

1. Navigate to `src/policy_recreation` directory
2. Apply provided configuration sample:
    - `terraform init`
    - `terraform apply`

3. Note policy secrets/connection_strings:

    ![before_changes](/src/policy_recreation/01_before_changes.png)

4. Change `policy` resource, for example, set `device_connect  = false`.
5. Run `terraform apply`.
6. Reload IotHub page at Azure Portal and note policy secrets/connection_strings:

    ![after_changes](/src/policy_recreation/02_after_changes.png)
