tableextension 50101 AJETestLinePackCode extends "CAL Test Line"
{
    fields
    {
        field(50100; "AJE Config. Pack Code"; Code[20])
        {
            Caption = 'Config. Pack Code';
            TableRelation = "Config. Package" where("AJE Test Result" = const(true));

            trigger OnValidate()
            begin
                if Rec."Line Type" = Rec."Line Type"::Codeunit then
                    UpdateChildrenPackCode(Rec);
            end;
        }
    }

    local procedure UpdateChildrenPackCode(CodCALTestLine: Record "CAL Test Line")
    var
        CALTestLine: Record "CAL Test Line";
    begin
        CALTestLine.Copy(CodCALTestLine);
        CALTestLine.SetRange("Test Suite", CodCALTestLine."Test Suite");
        while (CALTestLine.Next() <> 0) and (CALTestLine."Line Type" = CALTestLine."Line Type"::Function) do begin
            CALTestLine."AJE Config. Pack Code" := CodCALTestLine."AJE Config. Pack Code";
            CALTestLine.Modify();
        end;
    end;
}