page 50107 "AJE Listener Test Runs"
{
    AdditionalSearchTerms = 'test result run listener';
    ApplicationArea = All;
    Caption = 'Listener Test Runs';
    CardPageID = "AJE Listener Test Run Card";
    Editable = false;
    PageType = List;
    SourceTable = "AJE Listener Test Run";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control2)
            {
                ShowCaption = false;
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies an autoincremented number of the test run.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Description of the run.';
                }
                field("Config. Package Code"; Rec."Config. Package Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the confiuration package code that defines tables and fields to be stored.';
                }
                field(Result; Rec.Result)
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    Caption = 'Result';
                    Editable = false;
                    Style = Favorable;
                    StyleExpr = ResultEmphasize;
                    Tooltip = 'Specifies whether the test run passed, failed or were skipped.';
                }
                field("Error Message"; ErrorMessageWithStackTraceTxt)
                {
                    ApplicationArea = All;
                    Caption = 'Error Message';
                    DrillDown = true;
                    Editable = false;
                    Style = Unfavorable;
                    StyleExpr = true;
                    ToolTip = 'Specifies full error message with stack trace';

                    trigger OnDrillDown()
                    begin
                        Message(ErrorMessageWithStackTraceTxt);
                    end;
                }

                field("Start Time"; Rec."Start Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the time when the run was started.';
                }
                field("Finish Time"; Rec."Finish Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the time when the run was finished.';
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the user who created the run.';
                }

            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        ErrorMessageWithStackTraceTxt := Rec.GetErrorMessageWithStackTrace();
        ResultEmphasize := Rec.Result = Rec.Result::Success;
    end;

    var
        ResultEmphasize: Boolean;
        ErrorMessageWithStackTraceTxt: Text;
}