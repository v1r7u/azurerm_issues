# Terraform AzureRM provider issues

The repository contains steps to reproduce several AzureRM provider issues:

1. [src/dps_import](src/dps_import/README.md) describes problems with importing manually created Device Provisioning Service;
2. [src/iot_eventhub_listener](src/iot_eventhub_listener/README.md) shows how to fail in creating IoT Hub telemetry listener application;
3. [src/policy_recreation](src/policy_recreation/README.md) provides a steps to regenerate IoT Hub policy keys, while they should stay unchanged.
