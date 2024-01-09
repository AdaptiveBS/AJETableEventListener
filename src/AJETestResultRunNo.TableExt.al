tableextension 50102 AJETestResultRunNo extends "CAL Test Result"
{
    fields
    {
        field(50100; "AJE Test Run No."; Integer)
        {
            Caption = 'Test Run No.';
            Editable = false;
            TableRelation = "AJE Test Run"."No.";
        }
    }
}