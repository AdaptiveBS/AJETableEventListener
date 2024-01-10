pageextension 50101 AJETestLinePackCode extends "AL Test Tool"
{
    layout
    {
        addafter(CodeCoverageTrackAllSesssions)
        {
            field(AJECollectResult; CollectResult)
            {
                ApplicationArea = All;
                Caption = 'Collect Results';
                ToolTip = 'Specifies that results of each run of the test will be stored according to the structure of the configuration package which code defined for the test line.';

                trigger OnValidate()
                begin
                    AJETableEventListener.Activate(CollectResult);
                    CurrPage.Update();
                end;
            }
        }
        addafter(Run)
        {
            field("AJE Config. Pack Code"; Rec."AJE Config. Pack Code")
            {
                ApplicationArea = All;
                LookupPageId = "AJE Test Result Packages";
                ToolTip = 'Specifies the configuration package that defines tables and fields which data will be stored as test run results.';
                Visible = CollectResult;

                trigger OnValidate()
                begin
                    CurrPage.Update(true);
                end;
            }
        }
        addafter(Result)
        {
            field("AJE Test Run No."; Rec."AJE Test Run No.")
            {
                ApplicationArea = All;
                DrillDown = true;
                Editable = false;
                ToolTip = 'Specifies the number of the latest test run.';
                Visible = CollectResult;

                trigger OnDrillDown()
                begin
                    Rec.AJEShowTestResults();
                end;
            }
        }
    }

    var
        AJETableEventListener: codeunit "AJE Table Event Listener";
        CollectResult: Boolean;

    trigger OnAfterGetCurrRecord()
    begin
        CollectResult := AJETableEventListener.IsActive();
    end;

    trigger OnOpenPage()
    begin
        CollectResult := AJETableEventListener.IsActive();
    end;
}