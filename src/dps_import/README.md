# How to reproduce DPS import issue

## Abstract

Importing existing Device Provisioning Service (DPS) resources to the correct terraform configuration should not cause any changes to real components.

In our product we had an existing DPS, which we started managing by terraform. The component at Azure Portal is shown with `apply_allocation_policy = true` and `allocation_weight = 1`. When we described the resource with the same properties as we see at portal and import it to the configuration, the next `terraform apply` command _says_ it's going to change DPS resource:

![changes_to_apply](/src/dps_import/01_changes_to_apply.png)

## Steps to reproduce

1. Navigate to `src/dps_import` directory
2. Create variable `AZ_SUBSCRIPTION_ID=...` with identifier of your azure subscription to apply template to
3. Apply provided configuration sample:
    - `terraform init`
    - `terraform apply`

4. Remove `dps` resource from state file: `terraform state rm azurerm_iothub_dps.dps`
5. Relink IoT Hub to the DPS resource:
    - open DPS component in Azure Portal;
    - navigate to `Linked IoT hubs`;
    - select `iot-dps-v1r7u-issue.azure-devices.net` in the list and press `Delete` button;
    - add the same Iot Hub with `Add` button (ensure, you've choosen the same `dps-v1r7u-issue` Iot Hub with the same `dps` policy).
6. Import the DPS back to the state back: `terraform import azurerm_iothub_dps.dps /subscriptions/$AZ_SUBSCRIPTION_ID/resourceGroups/rg-dps-v1r7u-issue/providers/Microsoft.Devices/provisioningServices/dps-v1r7u-issue`
7. Run `terraform plan`. The proposed plan should contain changes to linked Iot Hub:

    ![changes_to_apply](/src/dps_import/02_changes_to_apply.png)
