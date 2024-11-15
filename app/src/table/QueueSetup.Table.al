table 82560 "BC2ASB Queue Setup"
{
    Access = Internal;
    Caption = 'Azure Service Bus Queue Setup';

    fields
    {
        field(1; PrimaryKey; Code[20])
        {
            Caption = 'Primary Key';
        }
        field(2; ServiceBusNamespace; Text[250])
        {
            Caption = 'Service Bus Namespace';
        }
        field(3; QueueName; Text[250])
        {
            Caption = 'Queue Name';
        }
        field(4; KeyName; Text[250])
        {
            Caption = 'Shared Access Policy Name';
        }
        field(5; KeyStorageId; Guid)
        {
        }
        field(6; IsEnabled; Boolean)
        {
            Caption = 'Is Enabled';
        }
    }

    procedure GetServiceUri(): Text[250];
    var
        DefaultUriTok: Label 'https://%1.servicebus.windows.net/%2', Locked = true;
    begin
        exit(CopyStr(StrSubstNo(DefaultUriTok, ServiceBusNamespace, QueueName), 1, 250));
    end;

    procedure SetSharedAccessKey(SharedAccessKey: Text)
    begin
        if IsNullGuid(KeyStorageId) then
            KeyStorageId := CreateGuid();

        if not EncryptionEnabled() then
            IsolatedStorage.Set(KeyStorageId, SharedAccessKey, Datascope::Module)
        else
            IsolatedStorage.SetEncrypted(KeyStorageId, SharedAccessKey, Datascope::Module);
    end;

    [NonDebuggable]
    internal procedure GetSharedAccessKey(): Text
    var
        Value: Text;
    begin
        if not IsNullGuid(KeyStorageId) then
            IsolatedStorage.Get(KeyStorageId, Datascope::Module, Value);
        exit(Value);
    end;

    [NonDebuggable]
    procedure HasSharedAccessKey(): Boolean
    begin
        exit(GetSharedAccessKey() <> '');
    end;

}