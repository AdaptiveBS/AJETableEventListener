/// <summary>
/// Table AJE Table Event Listener Entry (ID 50100).
/// </summary>
table 50100 "AJE Table Event Listener Setup"
{
    Caption = 'Table Event Listener Entry';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Table ID"; Integer)
        {
            Caption = 'Table ID';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = CONST(Table));
        }
        field(2; Name; Text[30])
        {
            Caption = 'Name';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup(AllObjWithCaption."Object Name" where("Object Type" = CONST(Table), "Object ID" = field("Table ID")));
        }
        field(3; OnInsert; Boolean)
        {
            Caption = 'Insert';
        }
        field(4; OnModify; Boolean)
        {
            Caption = 'Modify';
        }
        field(5; OnDelete; Boolean)
        {
            Caption = 'Delete';
        }
        field(6; OnRename; Boolean)
        {
            Caption = 'Rename';
        }
    }
    keys
    {
        key(PK; "Table ID")
        {
            Clustered = true;
        }
    }
}
