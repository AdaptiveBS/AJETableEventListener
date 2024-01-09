tableextension 50101 AJETestLinePackCode extends "CAL Test Line"
{
    fields
    {
        field(50100; "AJE Config. Pack Code"; Code[20])
        {
            Caption = 'Config. Pack Code';
            TableRelation = "Config. Package";// where ();
        }
    }
}