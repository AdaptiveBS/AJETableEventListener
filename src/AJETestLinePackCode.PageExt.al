pageextension 50101 AJETestLinePackCode extends "CAL Test Tool"
{
    layout
    {
        addafter(RunColumn)
        {
            field(AJEConfigPackCode; Rec."AJE Config. Pack Code")
            {
                ApplicationArea = All;
                LookupPageId = 50105;

                trigger OnValidate()
                begin
                    CurrPage.Update(true);
                end;
            }
        }
    }
}