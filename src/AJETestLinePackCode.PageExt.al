pageextension 50101 AJETestLinePackCode extends "CAL Test Tool"
{
    layout
    {
        addafter(CurrentSuiteName)
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
        addafter(RunColumn)
        {
            field(AJEConfigPackCode; Rec."AJE Config. Pack Code")
            {
                ApplicationArea = All;
                LookupPageId = 50105;
                ToolTip = 'Specifies the configuration package that defines tables and fields which data will be stored as test run results.';
                Visible = CollectResult;

                trigger OnValidate()
                begin
                    CurrPage.Update(true);
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