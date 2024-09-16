page 90100 "User Personalized Pages"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "User Page Metadata";
    Caption = 'User Personalized Pages';
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            repeater(Personalizations)
            {
                ShowCaption = false;
                field("User SID"; Rec."User SID")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'User SID';
                    ToolTip = 'Specifies the security identifier (SID) of the user who did the personalization.';
                    Visible = false;
                }
                field("User ID"; CurrentUserName)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'User Name';
                    ToolTip = 'Specifies the user name of the user who performed the personalization.';
                    Editable = false;
                }
                field("Page ID"; Rec."Page ID")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Page ID';
                    ToolTip = 'Specifies the number of the page object that has been personalized.';
                }
                field(PageCaption; PageName)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Page Caption';
                    ToolTip = 'Specifies the caption of the page that has been personalized.';
                }
                field(LastModified; Rec.SystemModifiedAt)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Last Modified';
                    ToolTip = 'Specifies the date of the personalization.';
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Export)
            {
                Caption = 'Export Personalizations';
                Image = ExportContact;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ApplicationArea = All;
                RunObject = codeunit "Export User Personalization";
            }
            action(Import)
            {
                Caption = 'Import Personalizations';
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ApplicationArea = All;
                RunObject = codeunit "Import User Personalization";
            }
            action(ViewContent)
            {
                ApplicationArea = All;
                Caption = 'View Content';
                Image = ViewDescription;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Scope = Repeater;

                trigger OnAction()
                var
                    ContentViewer: Page "User Pers. Content Viewer";
                    Instream: InStream;
                    Content: Text;
                begin
                    Rec.CalcFields("Page AL");
                    Rec."Page AL".CreateInStream(Instream);
                    Instream.Read(Content);
                    ContentViewer.SetContentToShow(Content, false);
                    ContentViewer.Run();
                end;
            }
            action(ViewMetadata)
            {
                ApplicationArea = All;
                Caption = 'View Metadata';
                Image = ViewJob;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Scope = Repeater;

                trigger OnAction()
                var
                    ContentViewer: Page "User Pers. Content Viewer";
                    Instream: InStream;
                    Content: Text;
                begin
                    Rec.CalcFields("Page Metadata");
                    Rec."Page Metadata".CreateInStream(Instream);
                    Instream.Read(Content);
                    ContentViewer.SetContentToShow(Content, true);
                    ContentViewer.Run();
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        PageMetadata: Record "Page Metadata";
    begin
        if PageMetadata.Get(Rec."Page ID") then
            PageName := PageMetadata.Caption
        else
            PageName := '';

        CurrentUserName := UserSidToUserName(Rec."User SID");
    end;

    local procedure UserSidToUserName(UserSid: Guid): Code[50]
    var
        User: Record User;
    begin
        if UserSid = UserSecurityId() then
            exit(CopyStr(UserId(), 1, 50)); // Covers the case of empty user table

        if User.ReadPermission() then
            if User.Get(UserSid) then
                exit(User."User Name");

        exit(UserSid);
    end;

    var
        PageName: Text;
        CurrentUserName: Text;
}