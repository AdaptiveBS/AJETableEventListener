tableextension 50104 AJEConfigPackRecordRunNo extends "Config. Package Record"
{
    fields
    {
        field(50100; "AJE Listener Test Run No."; Integer)
        {
            Caption = 'Listener Test Run No.';
            Editable = false;
            TableRelation = "AJE Listener Test Run"."No.";
        }
    }
}