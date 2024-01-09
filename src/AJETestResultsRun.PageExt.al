pageextension 50106 AJETestResultsRun extends "CAL Test Results"
{
    layout
    {
        addafter(Result)
        {
            field(AJEListenerTestRun; Rec."AJE Listener Test Run No.")
            {
                ApplicationArea = All;
            }
        }
    }
}