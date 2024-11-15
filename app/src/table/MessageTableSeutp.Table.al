table 82561 "BC2ASB Message Table Seutp"
{
    Caption = 'Message Table Setup';
    DataClassification = CustomerContent;
    DataPerCompany = false;

    fields
    {
        field(1; "Message Code"; Code[20])
        {
            Caption = 'Message';
            DataClassification = CustomerContent;
            TableRelation = "BC2ASB Message".Code;
        }
        field(2; "Table ID"; Integer)
        {
            Caption = 'Table ID';
        }
        field(3; Enabled; Boolean)
        {
            Caption = 'Enabled';
        }
        field(4; "Include System Fields"; Boolean)
        {
            Caption = 'Include System Fields';
        }
    }

    keys
    {
        key(Key1; "Message Code", "Table ID")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        CheckTableOfTypeNormal(Rec."Table ID");
    end;

    trigger OnDelete()
    var
        MessageFieldSetup: Record "BC2ASB Message Field Setup";
    begin
        MessageFieldSetup.SetRange("Table ID", Rec."Table ID");
        MessageFieldSetup.DeleteAll(false);
    end;

    trigger OnRename()
    begin
        Error(RenameNotAllowedErr, TableCaption);
    end;

    var
        TableNotNormalErr: Label 'Table %1 is not a normal table.', Comment = '%1: caption of table';
        TableCannotBeExportedErr: Label 'The table %1 cannot be exported because of the following error. \%2', Comment = '%1: Table ID, %2: error text';
        RenameNotAllowedErr: Label 'Renaming of table %1 is not allowed.', Comment = '%1: caption of table';


    procedure Add(TableID: Integer)
    begin
        if not CheckTableCanBeExportedFrom(TableID) then
            Error(TableCannotBeExportedErr, TableID, GetLastErrorText());
        Rec.Init();
        Rec."Table ID" := TableID;
        Rec.Enabled := true;
        Rec.Insert(true);
    end;

    [TryFunction]
    local procedure CheckTableCanBeExportedFrom(TableID: Integer)
    var
        RecordRef: RecordRef;
    begin
        ClearLastError();
        RecordRef.Open(TableID);
    end;

    local procedure CheckTableOfTypeNormal(TableID: Integer)
    var
        TableMetadata: Record "Table Metadata";
        ADLSEUtil: Codeunit "BC2ASB Util";
        TableCaption: Text;
    begin
        TableCaption := ADLSEUtil.GetTableCaption(TableID);

        TableMetadata.SetRange(ID, TableID);
        TableMetadata.FindFirst();

        if TableMetadata.TableType <> TableMetadata.TableType::Normal then
            Error(TableNotNormalErr, TableCaption);
    end;

    procedure AddAllFields()
    var
        MessageFieldSetup: Record "BC2ASB Message Field Setup";
    begin
        MessageFieldSetup.InsertForTable(Rec);
        MessageFieldSetup.SetRange("Table ID", Rec."Table ID");
        if MessageFieldSetup.FindSet(true) then
            repeat
                if (MessageFieldSetup.CanFieldBeEnabled()) then begin
                    MessageFieldSetup.Enabled := true;
                    MessageFieldSetup.Modify(true);
                end;
            until MessageFieldSetup.Next() = 0;
    end;
}