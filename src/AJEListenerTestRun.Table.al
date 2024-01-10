table 50105 "AJE Listener Test Run"
{
    fields
    {
        field(1; "No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'No.';
        }
        field(2; "Config. Package Code"; Code[20])
        {
            Caption = 'Config. Package Code';
            TableRelation = "Config. Package".Code where("AJE Test Result" = const(true));
        }
        field(3; Description; Text[50])
        {
            Caption = 'Description';
        }
        field(4; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
        }
        field(5; Result; Option)
        {
            Caption = 'Result';
            InitValue = Incomplete;
            OptionCaption = 'Passed,Failed,Inconclusive,Incomplete';
            OptionMembers = Passed,Failed,Inconclusive,Incomplete;
        }
        field(6; "Codeunit ID"; Integer)
        {
            Caption = 'Codeunit ID';

            trigger OnValidate()
            begin
                "Codeunit Name" := GetCodeunitName("Codeunit ID");
            end;
        }
        field(7; "Codeunit Name"; Text[30])
        {
            Caption = 'Codeunit Name';
        }
        field(8; "Function Name"; Text[128])
        {
            Caption = 'Function Name';
        }
        field(9; "Error Message"; Text[250])
        {
            Caption = 'Error Message';
        }
        field(10; "Call Stack"; BLOB)
        {
            Caption = 'Call Stack';
            Compressed = false;
        }
        field(11; "Execution Time"; Duration)
        {
            Caption = 'Execution Time';
        }
        field(12; "Start Time"; DateTime)
        {
            Caption = 'Start Time';
            Editable = false;
        }
        field(13; "Finish Time"; DateTime)
        {
            Caption = 'Finish Time';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
        key(Test; "Codeunit ID", "Function Name")
        { }
    }

    trigger OnInsert()
    begin
        "Start Time" := CurrentDateTime();
        "User ID" := CopyStr(UserId(), 1, MaxStrLen("User ID"));
    end;

    procedure Initialize(CodeunitId: Integer; FunctionName: Text[128]): Boolean
    begin
        Init();
        "No." := 0; // autoincrement
        Validate("Codeunit ID", CodeunitId);
        "Function Name" := FunctionName;
        Insert(true);
    end;

    procedure Update(Success: Boolean; FinishTime: DateTime)
    var
        Out: OutStream;
    begin
        if Success then begin
            Result := Result::Passed;
            ClearLastError();
        end else begin
            "Error Message" := CopyStr(GetLastErrorText(), 1, 250);
            "Call Stack".CreateOutStream(Out);
            Out.WriteText(GetLastErrorCallstack);
            if StrPos("Error Message", 'Known failure:') = 1 then
                Result := Result::Inconclusive
            else
                Result := Result::Failed;
        end;

        "Finish Time" := FinishTime;
        "Execution Time" := "Finish Time" - "Start Time";
        Modify();
    end;

    local procedure GetCodeunitName(ID: Integer): Text[30]
    var
        AllObjWithCaption: Record AllObjWithCaption;
    begin
        AllObjWithCaption.SetRange("Object Type", AllObjWithCaption."Object Type"::Codeunit);
        AllObjWithCaption.SetRange("Object ID", ID);
        if AllObjWithCaption.FindFirst() then
            exit(AllObjWithCaption."Object Name");
    end;

}