tableextension 50102 AJETestResultPackCode extends "CAL Test Result"
{
    fields
    {
        field(50100; "AJE Config. Pack Code"; Code[20])
        {
            Caption = 'Config. Pack Code';
            Editable = false;
            TableRelation = "Config. Package" where("AJE Test Result" = const(true));
        }
    }
}