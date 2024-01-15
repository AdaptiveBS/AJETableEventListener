page 50101 "AJE Listener Test Run Card"
{
    AdditionalSearchTerms = 'test result run listener card';
    ApplicationArea = All;
    Caption = 'Listener Test Run';
    DataCaptionExpression = Rec.Description;
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
                    Editable = false;
                    Importance = Additional;
                    ToolTip = 'Specifies an autoincremented number of the test run.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Editable = Rec.Manual and (Rec.Status = Rec.Status::Created);
                    ToolTip = 'Specifies the Description of the run.';
                }
                group(StatusVisibility)
                {
                    ShowCaption = false;
                    Visible = Rec.Manual;
                    field(Status; Rec.Status)
                    {
                        ApplicationArea = All;
                        Tooltip = 'Specifies the status of the manual test run: created, started, or finished.';
                    }
                }
                field("All Tables"; Rec."All Tables")
                {
                    ApplicationArea = All;
                    Editable = Rec.Manual and (Rec.Status = Rec.Status::Created);
                    ToolTip = 'Specifies if all table events will be collected';
                }
                field("Config. Package Code"; Rec."Config. Package Code")
                {
                    ApplicationArea = All;
                    Editable = Rec.Manual and (Rec.Status = Rec.Status::Created);
                    Enabled = not Rec."All Tables";
                    LookupPageId = "AJE Test Result Packages";
                    ToolTip = 'Specifies the configuration package code that defines tables and fields to be stored.';

                    trigger OnDrillDown()
                    begin
                        Rec.ShowConfigPackage();
                    end;
                }
                group(Time)
                {
                    ShowCaption = false;
                    field("Start Time"; Rec."Start Time")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        Importance = Additional;
                        ToolTip = 'Specifies the time when the run was started.';
                    }
                    field("Finish Time"; Rec."Finish Time")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        Importance = Additional;
                        ToolTip = 'Specifies the time when the run was finished.';
                    }
                    field("Execution Time"; Rec."Execution Time")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ToolTip = 'Specifies the execution time of the run.';
                    }
                }
                group(ResultVisibility)
                {
                    ShowCaption = false;
                    Visible = not Rec.Manual;
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
                }
                group(ErrorInfo)
                {
                    Editable = false;
                    ShowCaption = false;
                    Visible = ShowErrorControls;
                    field("Error Message"; Rec.GetFullErrorMessage())
                    {
                        ApplicationArea = All;
                        Caption = 'Error Message';
                        DrillDown = true;
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
                        ToolTip = 'Specifies the call stack that led to the error.';

                        trigger OnDrillDown()
                        begin
                            Message(ErrorMessageWithStackTraceTxt);
                        end;
                    }
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Importance = Additional;
                    ToolTip = 'Specifies the user who created the run.';
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

    actions
    {
        area(Processing)
        {
            action(Start)
            {
                ApplicationArea = All;
                Caption = 'Start';
                Image = Start;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Visible = Rec.Status = Rec.Status::Created;
                trigger OnAction()
                begin
                    Rec.StartManualRun();
                end;
            }
            action(Finish)
            {
                ApplicationArea = All;
                Caption = 'Finish';
                Image = Start;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Visible = Rec.Status = Rec.Status::Started;
                trigger OnAction()
                begin
                    Rec.FinishManualRun();
                end;
            }
        }
    }


    trigger OnAfterGetRecord()
    begin
        ShowErrorControls := Rec.Result = Rec.Result::Failure;
        ErrorMessageWithStackTraceTxt := Rec.GetErrorMessageWithStackTrace();
        ResultEmphasize := Rec.Result = Rec.Result::Success;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.Validate(Manual, true);
    end;

    var
        ResultEmphasize: Boolean;
        ShowErrorControls: Boolean;
        ErrorMessageWithStackTraceTxt: Text;
}