page 82560 "BC2ASB Queue Setup"
{
    Caption = 'Azure Service Bus Queue Setup';
    SourceTable = "BC2ASB Queue Setup";
    UsageCategory = Administration;
    ApplicationArea = All;
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ShowFilter = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field(AzureRelayNamespace; Rec.ServiceBusNamespace)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the namespace of the Azure Service Bus';
                }
                field(HybridConnectionName; Rec.QueueName)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the Queue';
                }
                field(KeyName; Rec.KeyName)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the Shared Access Policy to for authentication';
                }
                field(SharedAccessKey; SharedAccessKeyValue)
                {
                    ApplicationArea = All;
                    ExtendedDatatype = Masked;
                    Caption = 'Shared Access Key';
                    ToolTip = 'Specifies the key used for authentication';

                    trigger OnValidate()
                    begin
                        if (SharedAccessKeyValue <> '') and (not EncryptionEnabled()) then
                            if Confirm(EncryptionIsNotActivatedQst) then
                                PAGE.RunModal(PAGE::"Data Encryption Management");
                        Rec.SetSharedAccessKey(SharedAccessKeyValue);
                    end;
                }

                field(IsEnabled; Rec.IsEnabled)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the Azure Service Bus Queue integration is enabled';
                }
            }

        }
    }

    var
        SharedAccessKeyValue: Text;
        EncryptionIsNotActivatedQst: Label 'Data encryption is currently not enabled. We recommend that you encrypt data. \Do you want to open the Data Encryption Management window?';

    trigger OnAfterGetRecord()
    begin
        if Rec.HasSharedAccessKey() then
            SharedAccessKeyValue := '*';
    end;
}