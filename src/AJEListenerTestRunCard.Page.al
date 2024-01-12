page 50108 "AJE Listener Test Run Card"
{
    AdditionalSearchTerms = 'test result run listener card';
    ApplicationArea = All;
    Caption = 'Listener Test Run';
    DataCaptionExpression = Rec.Description;
    Editable = false;
    PageType = Card;
    SourceTable = "AJE Listener Test Run";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'Test Run';
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies an autoincremented number of the test run.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the Description of the run.';
                }
                field("Config. Package Code"; Rec."Config. Package Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the configuration package code that defines tables and fields to be stored.';

                    trigger OnDrillDown()
                    begin
                        Rec.ShowConfigPackage();
                    end;
                }
                field("Start Time"; Rec."Start Time")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the time when the run was started.';
                }
                field("Finish Time"; Rec."Finish Time")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the time when the run was finished.';
                }
                field("Execution Time"; Rec."Execution Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the execution time of the run.';
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the user who created the run.';
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
                group(ErrorInfo)
                {
                    ShowCaption = false;
                    Visible = ShowErrorControls;
                    field("Error Message"; Rec.GetFullErrorMessage())
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
                    field("Error Call Stack"; Rec.GetErrorCallStack())
                    {
                        ApplicationArea = All;
                        Caption = 'Error Call Stack';
                        DrillDown = true;
                        Editable = false;
                        ToolTip = 'Specifies the call stack that led to the error.';

                        trigger OnDrillDown()
                        begin
                            Message(ErrorMessageWithStackTraceTxt);
                        end;
                    }
                }
            }
            part(Records; "AJE Config. Pack Rec. Subform")
            {
                Caption = 'Records';
                Editable = false;
                SubPageLink = "AJE Listener Test Run No." = field("No.");
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        ShowErrorControls := Rec.Result = Rec.Result::Failure;
        ErrorMessageWithStackTraceTxt := Rec.GetErrorMessageWithStackTrace();
        ResultEmphasize := Rec.Result = Rec.Result::Success;
    end;

    var
        ResultEmphasize: Boolean;
        ShowErrorControls: Boolean;
        ErrorMessageWithStackTraceTxt: Text;
}