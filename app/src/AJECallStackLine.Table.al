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
        field(10; "CC Line No."; Integer)
        {
            Caption = 'CC Line No.';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }

    var
        Regex: Codeunit Regex;
        FunctionLineNumbers: Dictionary of [Text, Dictionary of [Text, Integer]]; // ['Table_36', [('OnRun',5),('OnValidate',24)]]

    procedure Add(CallStackLine: text; CodeCoverageExists: Boolean)
    var
        Groups: Record Groups;
        Matches: Record Matches;
        CallStackLineLbl: Label '^(.*)\((.*) (\d*)\)\.(.*) line (\d*) - (.*) by (.*)$', Locked = true;
        Value: Text;
    begin
        if FindLast() then;
        Regex.Match(CallStackLine, CallStackLineLbl, Matches);
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
                if CodeCoverageExists then
                    CalcCodeCoverageLineNo();
                Insert();
            end;
        end;
    end;

    procedure Initialize(CallStack: Text; CodeCoverageExists: Boolean)
    var
        Lines: List of [Text];
        Line: Text;
    begin
        Regex.Split(CallStack, '\\', Lines);
        foreach Line in Lines do
            Add(Line, CodeCoverageExists);
    end;

    local procedure CalcCodeCoverageLineNo()
    var
        LineNumbers: Dictionary of [Text, Integer];
        ObjectKeyLbl: Label '%1_%2', Locked = true;
        FunctionName: Text;
        ObjectKey: Text;
    begin
        ObjectKey := StrSubstNo(ObjectKeyLbl, "Object Type", "Object Id");
        if not FunctionLineNumbers.ContainsKey(ObjectKey) then
            CollectFunctionLineNumbers(ObjectKey);

        LineNumbers := FunctionLineNumbers.Get(ObjectKey);

        FunctionName := Method;
        if FunctionName.Contains('(') then
            FunctionName := FunctionName.Split('(').Get(1);
        if LineNumbers.ContainsKey(FunctionName) then
            "CC Line No." := LineNumbers.Get(FunctionName) + "Line No.";
    end;

    local procedure CollectFunctionLineNumbers(ObjectKey: Text)
    var
        CodeCoverage: Record "Code Coverage";
        LineNumbers: Dictionary of [Text, Integer];
        FunctionName: Text;
    begin
        CodeCoverage.SetRange("Object Type", "Object Type");
        CodeCoverage.SetRange("Object Id", "Object Id");
        CodeCoverage.SetRange("Line Type", CodeCoverage."Line Type"::"Trigger/Function");
        if CodeCoverage.FindSet() then
            repeat
                FunctionName := GetFunctionName(CodeCoverage.Line);
                if not LineNumbers.ContainsKey(FunctionName) then
                    LineNumbers.Add(FunctionName, CodeCoverage."Line No.");
            until CodeCoverage.Next() = 0;

        FunctionLineNumbers.Add(ObjectKey, LineNumbers);
    end;

    local procedure GetFunctionName(Line: Text[250]) Name: Text
    var
        Groups: Record Groups;
        Matches: Record Matches;
        FunctionNameLbl: Label '\s([^\s-]*)\(', Locked = true;
    begin
        Regex.Match(Line, FunctionNameLbl, Matches);
        if Matches.FindFirst() then begin
            Regex.Groups(Matches, Groups);
            if Groups.Get(1) then
                Name := Groups.ReadValue();
        end;
    end;
}