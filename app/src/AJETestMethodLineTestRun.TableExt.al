tableextension 50103 AJETestMethodLineTestRun extends "Test Method Line"
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
        field(50101; "AJE Test Run No."; Integer)
        {
            Caption = 'Latest Test Run No.';
            TableRelation = "AJE Listener Test Run";
        }
        field(50102; "AJE All Tables"; Boolean)
        {
            Caption = 'All Tables';

            trigger OnValidate()
            begin
                if "AJE All Tables" then
                    "AJE Config. Pack Code" := '';
            end;
        }
    }

    procedure AJEShowTestResults()
    var
        AJEListenerTestRun: Record "AJE Listener Test Run";
    begin
        AJEListenerTestRun.SetRange("Codeunit ID", "Test Codeunit");
        if "Function" <> '' then
            AJEListenerTestRun.SetRange("Function Name", "Function");
        if AJEListenerTestRun.FindLast() then;
        PAGE.Run(PAGE::"AJE Listener Test Runs", AJEListenerTestRun);
    end;

    local procedure UpdateChildrenPackCode(CodTestMethodLine: Record "Test Method Line")
    var
        TestMethodLine: Record "Test Method Line";
    begin
        TestMethodLine.Copy(CodTestMethodLine);
        TestMethodLine.SetRange("Test Suite", CodTestMethodLine."Test Suite");
        while (TestMethodLine.Next() <> 0) and (TestMethodLine."Line Type" = TestMethodLine."Line Type"::Function) do begin
            TestMethodLine."AJE Config. Pack Code" := CodTestMethodLine."AJE Config. Pack Code";
            TestMethodLine.Modify();
        end;
    end;

}