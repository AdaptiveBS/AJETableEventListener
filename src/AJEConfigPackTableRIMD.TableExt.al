tableextension 50100 AJEConfigPackTableRIMD extends "Config. Package Table"
{
    fields
    {
        field(50100; "AJE Rename"; Boolean)
        {
            Caption = 'Rename';
        }
        field(50101; "AJE Insert"; Boolean)
        {
            Caption = 'Insert';
        }
        field(50102; "AJE Modify"; Boolean)
        {
            Caption = 'Modify';
        }
        field(50103; "AJE Delete"; Boolean)
        {
            Caption = 'Delete';
        }
    }

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