table 50107 "AJE Call Stack Line"
{
    TableType = Temporary;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
        }
        field(2; "Object Type"; Option)
        {
            Caption = 'Object Type';
            OptionCaption = ',Table,,Report,,Codeunit,XMLport,,Page,Query,,,,,PageExtension,TableExtension,Enum,EnumExtension,Profile,ProfileExtension,PermissionSet,PermissionSetExtension,ReportExtension';
            OptionMembers = ,"Table",,"Report",,"Codeunit","XMLport",,"Page","Query",,,,,"PageExtension","TableExtension","Enum","EnumExtension","Profile","ProfileExtension","PermissionSet","PermissionSetExtension","ReportExtension";
        }
        field(3; "Object ID"; Integer)
        {
            Caption = 'Object ID';
        }
        field(4; "Object Name"; Text[30])
        {
            Caption = 'Object Name';
        }
        field(5; Method; Text[250])
        {
            Caption = 'Method';
        }
        field(6; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(7; "App Name"; Text[250])
        {
            Caption = 'App Name';
        }
        field(8; Publisher; Text[250])
        {
            Caption = 'Publisher';
        }
        field(9; "Is Test Framework"; Boolean)
        {
            Caption = 'Is Test Framework';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }

    procedure Add(CallStackLine: text)
    var
        Groups: Record Groups;
        Matches: Record Matches;
        Regex: Codeunit Regex;
        CallStackLineLbl: Label '^(.*)\((.*) (\d*)\)\.(.*) line (\d*) - (.*) by (.*)$', Locked = true;
        Value: Text;
    begin
        if FindLast() then;
        Regex.Regex(CallStackLineLbl);
        Regex.Match(CallStackLine, Matches);
        if Matches.FindFirst() then begin
            Regex.Groups(Matches, Groups);
            if Groups.FindSet() then begin
                Init();
                "Entry No." += 1;
                repeat
                    Value := Groups.ReadValue();
                    case Groups.GroupIndex of
                        1:
                            "Object Name" := CopyStr(Value, 1, 30);
                        2:
                            Evaluate("Object Type", Value);
                        3:
                            Evaluate("Object ID", Value);
                        4:
                            Method := CopyStr(Value, 1, 250);
                        5:
                            Evaluate("Line No.", Value);
                        6:
                            "App Name" := CopyStr(Value, 1, 250);
                        7:
                            Publisher := CopyStr(Value, 1, 250);
                    end;
                until Groups.Next() = 0;
                "Is Test Framework" := "Object ID" in [130450 .. 130480];
                Insert();
            end;
        end;
    end;

    procedure Initialize(CallStack: Text)
    var
        Regex: Codeunit Regex;
        Lines: List of [Text];
        Line: Text;
    begin
        Regex.Split(CallStack, '\\', Lines);
        foreach Line in Lines do
            Add(Line);
    end;
}