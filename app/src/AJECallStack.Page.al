page 50107 "AJE Call Stack"
{
    ApplicationArea = All;
    Caption = 'Call Stack';
    Editable = false;
    PageType = List;
    SourceTable = "AJE Call Stack Line";
    SourceTableView = sorting("Entry No.") where("Is Test Framework" = const(false));
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(General)
            {
                ShowCaption = false;
                repeater(Group)
                {
                    field("Entry No."; Rec."Entry No.")
                    {
                        ApplicationArea = All;
                        Visible = false;
                    }
                    field("Object Type"; Rec."Object Type")
                    {
                        ApplicationArea = All;
                    }
                    field("Object ID"; Rec."Object ID")
                    {
                        ApplicationArea = All;
                    }
                    field("Object Name"; Rec."Object Name")
                    {
                        ApplicationArea = All;
                    }
                    field(Method; Rec.Method)
                    {
                        ApplicationArea = All;
                    }
                    field("CC Line No."; Rec."CC Line No.")
                    {
                        ApplicationArea = All;
                        Style = Unfavorable;
                        StyleExpr = UnfavorableCCLineStyle;
                        Visible = CodeCoverageExists;
                    }
                    field("Line No."; Rec."Line No.")
                    {
                        ApplicationArea = All;
                    }
                    field("App Name"; Rec."App Name")
                    {
                        ApplicationArea = All;
                    }
                    field(Publisher; Rec.Publisher)
                    {
                        ApplicationArea = All;
                    }
                }
                part(CodeCoverage; "AJE Code Coverage Subform")
                {
                    Caption = 'Code';
                    SubPageLink = "Object Type" = field("Object Type"), "Object ID" = field("Object ID");
                    Visible = CodeCoverageExists;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ShowAll)
            {
                ApplicationArea = All;
                Caption = 'Show All';
                Image = ShowList;

                trigger OnAction()
                begin
                    Rec.FilterGroup(2);
                    Rec.SetRange("Is Test Framework");
                    Rec.FilterGroup(0);
                end;
            }
            action(HideTestFramework)
            {
                ApplicationArea = All;
                Caption = 'Hide Test Framework';
                Image = CancelLine;

                trigger OnAction()
                begin
                    Rec.FilterGroup(2);
                    Rec.SetRange("Is Test Framework", false);
                    Rec.FilterGroup(1);
                end;
            }
        }

        area(Promoted)
        {
            group(Split)
            {
                ShowAs = SplitButton;
                actionref(Show; ShowAll)
                { }
                actionref(Hide; HideTestFramework)
                { }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        if (CurrObject."Object ID" <> Rec."Object ID") or (CurrObject."Object Type" <> Rec."Object Type") then
            if CurrObject.Get(Rec."Object Type", Rec."Object ID") then begin
                CurrObject.SetRecFilter();
                //CodeCoverageMgt.Start(false);
                //CodeCoverageMgt.Include(CurrObject);
                //CodeCoverageMgt.Stop();
                CodeCoverage.SetRange("Object Type", Rec."Object Type");
                CodeCoverage.SetRange("Object ID", Rec."Object ID");
            end;
    end;

    trigger OnAfterGetRecord()
    begin
        UnfavorableCCLineStyle := Rec."CC Line No." = 0;
    end;

    var
        CurrObject: Record AllObj;
        CodeCoverage: Record "Code Coverage";
        CodeCoverageMgt: Codeunit "Code Coverage Mgt.";
        CodeCoverageExists: Boolean;
        UnfavorableCCLineStyle: Boolean;


    procedure Set(CallStack: Text)
    begin
        CodeCoverage.Reset();
        CodeCoverageExists := not CodeCoverage.IsEmpty();
        Rec.Initialize(CallStack, CodeCoverageExists);
    end;
}