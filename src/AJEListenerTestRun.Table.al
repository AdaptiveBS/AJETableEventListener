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
        field(5; "Created DateTime"; DateTime)
        {
            Caption = 'Created DateTime';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        "Created DateTime" := CurrentDateTime();
        "User ID" := CopyStr(UserId(), 1, MaxStrLen("User ID"));
    end;
}