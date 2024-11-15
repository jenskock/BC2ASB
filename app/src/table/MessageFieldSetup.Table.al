table 82562 "BC2ASB Message Field Setup"
{
    Caption = 'Message Field Setup';
    DataClassification = CustomerContent;

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
            DataClassification = CustomerContent;
            TableRelation = "BC2ASB Message Table Seutp"."Table ID" where("Message Code" = field("Message Code"));
        }
        field(3; "Field ID"; Integer)
        {
            Editable = false;
            Caption = 'Field ID';
        }
        field(4; Enabled; Boolean)
        {
            Caption = 'Enabled';
        }
        field(5; "Export Enum as Integer"; Boolean)
        {
            Caption = 'Export Enum as Integer';
        }
        field(100; "FieldCaption"; Text[80])
        {
            Caption = 'Field';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup(Field."Field Caption" where("No." = field("Field ID"), TableNo = field("Table ID")));
        }
    }

    keys
    {
        key(Key1; "Message Code", "Table ID", "Field ID")
        {
            Clustered = true;
        }
    }

    procedure InsertForTable(MessageTableSeutp: Record "BC2ASB Message Table Seutp")
    var
        Field: Record Field;
        MessageFieldSeutp: Record "BC2ASB Message Field Setup";
    begin
        Field.SetRange(TableNo, MessageTableSeutp."Table ID");
        Field.SetFilter("No.", '<%1', 2000000000);

        if Field.FindSet() then
            repeat
                if not MessageFieldSeutp.Get(MessageTableSeutp."Message Code", MessageTableSeutp."Table ID", Field."No.") then begin
                    Rec."Message Code" := MessageTableSeutp."Message Code";
                    Rec."Table ID" := Field.TableNo;
                    Rec."Field ID" := Field."No.";
                    Rec.Enabled := false;
                    Rec.Insert(true);
                end;
            until Field.Next() = 0;
    end;

    procedure CheckFieldToBeEnabled()
    var
        Field: Record Field;
        ADLSEUtil: Codeunit "BC2ASB Util";
    begin
        Field.Get(Rec."Table ID", Rec."Field ID");
        ADLSEUtil.CheckFieldTypeForExport(Field);
    end;

    [TryFunction]
    procedure CanFieldBeEnabled()
    begin
        CheckFieldToBeEnabled();
    end;
}