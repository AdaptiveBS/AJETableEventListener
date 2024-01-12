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
            OptionCaption = ' ,Failure,Success,Skipped';
            OptionMembers = " ",Failure,Success,Skipped;
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
        field(9; "Error Message"; Blob)
        {
            Caption = 'Error Message';
        }
        field(10; "Error Call Stack"; Blob)
        {
            Caption = 'Error Call Stack';
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

    trigger OnModify()
    begin
        "Finish Time" := CurrentDateTime();
        "Execution Time" := "Finish Time" - "Start Time";
    end;

    var
        ErrorMessageWithCallStackErr: Label 'Error Message:\%1\\Error Call Stack:\%2', Locked = true;

    procedure GetErrorCallStack(): Text
    var
        ErrorCallStackInStream: InStream;
        ErrorCallStack: Text;
    begin
        CalcFields("Error Call Stack");
        if not "Error Call Stack".HasValue() then
            exit('');

        "Error Call Stack".CreateInStream(ErrorCallStackInStream, TEXTENCODING::UTF16);
        ErrorCallStackInStream.ReadText(ErrorCallStack);
        exit(ErrorCallStack);
    end;

    procedure GetErrorMessageWithStackTrace(): Text
    var
        FullErrorMessage: Text;
    begin
        FullErrorMessage := GetFullErrorMessage();

        if FullErrorMessage = '' then
            exit('');

        FullErrorMessage := StrSubstNo(ErrorMessageWithCallStackErr, FullErrorMessage, GetErrorCallStack());
        exit(FullErrorMessage);
    end;

    procedure GetFullErrorMessage(): Text
    var
        ErrorMessageInStream: InStream;
        ErrorMessage: Text;
    begin
        CalcFields("Error Message");
        if not "Error Message".HasValue() then
            exit('');

        "Error Message".CreateInStream(ErrorMessageInStream, TextEncoding::UTF16);
        ErrorMessageInStream.ReadText(ErrorMessage);
        exit(ErrorMessage);
    end;

    procedure Initialize(var TestMethodLine: Record "Test Method Line"): Integer
    var
        TestDescrLbl: Label '%1.%2', Locked = true;
    begin
        Init();
        "No." := 0; // autoincrement
        Validate("Config. Package Code", TestMethodLine."AJE Config. Pack Code");
        Validate("Codeunit ID", TestMethodLine."Test Codeunit");
        "Function Name" := TestMethodLine.Function;
        Description := StrSubstNo(TestDescrLbl, "Codeunit ID", "Function Name");
        Insert(true);

        exit("No.");
    end;

    procedure Update(var CurrentTestMethodLine: Record "Test Method Line")
    var
        TestSuiteMgt: Codeunit "Test Suite Mgt.";
    begin
        Result := CurrentTestMethodLine.Result;
        if CurrentTestMethodLine.Result = CurrentTestMethodLine.Result::Failure then begin
            SetErrorCallStack(TestSuiteMgt.GetErrorCallStack(CurrentTestMethodLine));
            SetFullErrorMessage(TestSuiteMgt.GetFullErrorMessage(CurrentTestMethodLine));
        end;
        Modify(true);
    end;

    internal procedure ShowConfigPackage()
    var
        ConfigPackage: Record "Config. Package";
    begin
        ConfigPackage.Get("Config. Package Code");
        ConfigPackage.SetRecFilter();
        Page.Run(Page::"AJE Test Result Pack Card", ConfigPackage);
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

    local procedure SetErrorCallStack(ErrorCallStack: Text)
    var
        ErrorCallStackOutStream: OutStream;
    begin
        "Error Call Stack".CreateOutStream(ErrorCallStackOutStream, TEXTENCODING::UTF16);
        ErrorCallStackOutStream.WriteText(ErrorCallStack);
    end;

    local procedure SetFullErrorMessage(ErrorMessage: Text)
    var
        ErrorMessageOutStream: OutStream;
    begin
        "Error Message".CreateOutStream(ErrorMessageOutStream, TextEncoding::UTF16);
        ErrorMessageOutStream.WriteText(ErrorMessage);
        Modify(true);
    end;

}