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
        }
        area(Factboxes)
        {

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

    var
        CodeCoverage: Record "Code Coverage";

    procedure Set(CallStack: Text)
    begin
        Rec.Initialize(CallStack);
    end;
}