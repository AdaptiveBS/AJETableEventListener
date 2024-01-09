pageextension 50106 AJETestResultsRun extends "CAL Test Results"
{
    layout
    {
        addafter(Result)
        {
            field(AJEStoredRecords; Rec."AJE Test Run No.")
            {
                ApplicationArea = All;
                Caption = 'Test Run No.';
            }
        }
    }
}