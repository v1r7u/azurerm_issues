# How to reproduce Iot Hub Events Listener changes

## Abstract

Azure IoT Hub supports built-in event-hub endpoint, where device-telemetry messages are routed by default. Terraform supports adding Consumer Groups to this endpoint. Other parts of terraform configuration should be able to use Consumer Group resource as reference.

We use a setup, when Azure Function reads telemetry data from IoT Hub, using a dedicated consumer group and IoT Hub policy. When this infrastructure is created the first time, terraform throws an exception like:

```text
Error: Error retrieving Consumer Group "normalizer" (Endpoint "events" / IoTHub "iothub-name" / Resource Group "rg-name"): devices.IotHubResourceClient#GetEventHubConsumerGroup: Failure sending request:
StatusCode=409 -- Original Error: autorest/azure: Service returned an error. Status=<nil> <nil>
```

The problem appears if IoT Hub and Consumer Group resources are created in the same `apply` step with the dependent component.

## Steps to reproduce

1. Navigate to `src/iot_eventhub_listener` directory
2. Apply provided configuration sample:
    - `terraform init`
    - `terraform apply`

3. Apply command fails with error, while the Consumer Group was properly created:

    ![error](/src/iot_eventhub_listener/01_error.png)

4. Manually delete `normalizer` Consumer Group from Azure portal.
5. Run `terraform apply` one more time and check successful deployment:

    ![success](/src/iot_eventhub_listener/02_success.png)
