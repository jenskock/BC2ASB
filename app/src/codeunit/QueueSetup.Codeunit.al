codeunit 82562 "BC2ASB Queue Setup"
{
    [EventSubscriber(ObjectType::Table, Database::"Service Connection", 'OnRegisterServiceConnection', '', false, false)]
    procedure OnRegisterServiceConnection(var ServiceConnection: Record "Service Connection");
    var
        QueueSetup: Record "BC2ASB Queue Setup";
        RecRef: RecordRef;
    begin
        if not QueueSetup.Get() then begin
            if not QueueSetup.WritePermission() then
                exit;
            QueueSetup.Init();
            QueueSetup.Insert();
        end;

        RecRef.GetTable(QueueSetup);
        if QueueSetup.IsEnabled then
            ServiceConnection.Status := ServiceConnection.Status::Enabled
        else
            ServiceConnection.Status := ServiceConnection.Status::Disabled;

        ServiceConnection.InsertServiceConnection(
            ServiceConnection, RecRef.RecordId(), QueueSetup.TableCaption(),
            QueueSetup.GetServiceUri(),
            PAGE::"BC2ASB Queue Setup");

    end;

}