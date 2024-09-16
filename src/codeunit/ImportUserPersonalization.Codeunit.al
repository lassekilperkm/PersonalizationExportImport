codeunit 90101 "Import User Personalization"
{
    trigger OnRun()
    var
        UserPageMetadata: Record "User Page Metadata";
        TempUserPageMetadata: Record "User Page Metadata" temporary;
        FromFilter: Text;
        Instream: InStream;
        ImportJson: JsonObject;
        PersonalizationsToken: JsonToken;
        Personalizations: JsonArray;
        PersonalizationToken: JsonToken;
        Personalization: JsonObject;
    begin
        FromFilter := 'All Files (*.*)|*.*';
        UploadIntoStream(FromFilter, Instream);
        ImportJson.ReadFrom(Instream);
        ImportJson.Get('Personalizations', PersonalizationsToken);
        Personalizations := PersonalizationsToken.AsArray();
        foreach PersonalizationToken in Personalizations do begin
            Personalization := PersonalizationToken.AsObject();
            TempUserPageMetadata := RecordFunctions.Json2Rec(Personalization, UserPageMetadata);
            UserPageMetadata.Init();
            UserPageMetadata.TransferFields(TempUserPageMetadata);
            UserPageMetadata.Insert();
        end;
    end;

    var
        RecordFunctions: Codeunit "Record Functions";
}