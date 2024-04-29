tableextension 50101 AJETableTriggerSetup extends "Config. Package Table"
{
    fields
    {
        field(50100; "AJE Rename"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Rename';
        }
        field(50101; "AJE Insert"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Insert';
        }
        field(50102; "AJE Modify"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Modify';
        }
        field(50103; "AJE Delete"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Delete';
        }
    }

    trigger OnInsert()
    begin
        "AJE Insert" := true;
        "AJE Modify" := true;
        "AJE Delete" := true;
        "AJE Rename" := false;
    end;

    procedure AJEGetTriggerSetup() TriggerSetup: List of [Boolean]
    begin
        TriggerSetup.Add("AJE Insert");
        TriggerSetup.Add("AJE Modify");
        TriggerSetup.Add("AJE Delete");
        TriggerSetup.Add("AJE Rename");
    end;

    procedure AJEIsAnyTriggerSet(): Boolean
    begin
        exit("AJE Insert" or "AJE Modify" or "AJE Delete" or "AJE Rename");
    end;


}