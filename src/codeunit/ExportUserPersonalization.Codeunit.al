codeunit 90100 "Export User Personalization"
{
    trigger OnRun()
    var
        UserPageMetadata: Record "User Page Metadata";
        Personalizations: JsonObject;
        Personalization: JsonArray;
        UserPersonalization: JsonObject;
        ExportData: Text;
        FileName: Text;
        Instream: InStream;
        Outstream: OutStream;
    begin
        ExportData := '';
        if UserPageMetadata.FindSet() then begin
            repeat
                UserPersonalization := RecordFunctions.Rec2Json(UserPageMetadata);
                Personalization.Add(UserPersonalization);
            until UserPageMetadata.Next() = 0;
            Personalizations.Add('Personalizations', Personalization);
            Personalizations.WriteTo(ExportData);
        end;

        if ExportData <> '' then begin
            TempBlob.CreateOutStream(Outstream);
            Outstream.WriteText(ExportData);
            TempBlob.CreateInStream(Instream);
            FileName := 'Personalizations.json';
            DownloadFromStream(Instream, '', '', '', FileName);
        end;
    end;

    var
        RecordFunctions: Codeunit "Record Functions";
        TempBlob: Codeunit "Temp Blob";
}