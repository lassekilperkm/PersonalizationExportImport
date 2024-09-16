codeunit 90102 "Record Functions"
{
    internal procedure Json2Rec(JsonObjectPar: JsonObject; RecToConvertPar: Variant): Variant
    var
        RecRefLoc: RecordRef;
    begin
        if not RecToConvertPar.IsRecord then
            Error(ErrParameterIsNotRecordGlob);
        RecRefLoc.GetTable(RecToConvertPar);
        exit(Json2Rec(JsonObjectPar, RecRefLoc.Number()));
    end;

    local procedure Json2Rec(JsonObjectPar: JsonObject; TableNoPar: Integer): Variant
    var
        RecRefLoc: RecordRef;
        FieldRefLoc: FieldRef;
        FieldHashLoc: Dictionary of [Text, Integer];
        iLoc: Integer;
        JsonKeyLoc: Text;
        JsonTokenLoc: JsonToken;
        JsonKeyValueLoc: JsonValue;
        RecVariantLoc: Variant;
    begin
        RecRefLoc.OPEN(TableNoPar);
        for iLoc := 1 to RecRefLoc.FieldCount() do begin
            FieldRefLoc := RecRefLoc.FieldIndex(iLoc);
            FieldHashLoc.Add(GetJsonFieldName(FieldRefLoc), FieldRefLoc.Number);
        end;
        RecRefLoc.Init();
        foreach JsonKeyLoc in JsonObjectPar.Keys() do
            if JsonObjectPar.Get(JsonKeyLoc, JsonTokenLoc) then
                if JsonTokenLoc.IsValue() then begin
                    JsonKeyValueLoc := JsonTokenLoc.AsValue();
                    FieldRefLoc := RecRefLoc.Field(FieldHashLoc.Get(JsonKeyLoc));
                    AssignValueToFieldRef(FieldRefLoc, JsonKeyValueLoc);
                end;

        RecVariantLoc := RecRefLoc;
        exit(RecVariantLoc);
    end;

    procedure Rec2Json(Rec2ConvertPar: Variant): JsonObject
    var

        RecRefLoc: RecordRef;
        FieldRefLoc: FieldRef;
        JsonObjectLoc: JsonObject;
        iLoc: Integer;
    begin
        if not Rec2ConvertPar.IsRecord then
            error(ErrParameterIsNotRecordGlob);
        RecRefLoc.GetTable(Rec2ConvertPar);
        for iLoc := 1 to RecRefLoc.FieldCount() do begin
            FieldRefLoc := RecRefLoc.FieldIndex(iLoc);
            case FieldRefLoc.Class of
                FieldRefLoc.Class::Normal:
                    JsonObjectLoc.Add(GetJsonFieldName(FieldRefLoc), FieldRef2JsonValue(FieldRefLoc));
                FieldRefLoc.Class::FlowField:
                    begin
                        FieldRefLoc.CalcField();
                        JsonObjectLoc.Add(GetJsonFieldName(FieldRefLoc), FieldRef2JsonValue(FieldRefLoc));
                    end;
            end;
        end;
        exit(JsonObjectLoc);
    end;

    local procedure FieldRef2JsonValue(FieldRefPar: FieldRef): JsonValue
    var
        Base64ConvertLoc: Codeunit "Base64 Convert";
        TempBlobLoc: Codeunit "Temp Blob";
        InStreamLoc: InStream;
        JsonValueLoc: JsonValue;
        DateLoc: Date;
        DateTimeLoc: DateTime;
        TimeLoc: Time;
    begin
        case FieldRefPar.Type() of
            FieldType::Date:
                begin
                    DateLoc := FieldRefPar.Value;
                    JsonValueLoc.SetValue(DateLoc);
                end;
            FieldType::Time:
                begin
                    TimeLoc := FieldRefPar.Value;
                    JsonValueLoc.SetValue(TimeLoc);
                end;
            FieldType::DateTime:
                begin
                    DateTimeLoc := FieldRefPar.Value;
                    JsonValueLoc.SetValue(DateTimeLoc);
                end;
            FieldType::Blob:
                begin
                    FieldRefPar.CalcField();
                    TempBlobLoc.FromFieldRef(FieldRefPar);
                    TempBlobLoc.CreateInStream(InStreamLoc);
                    JsonValueLoc.SetValue(Base64ConvertLoc.ToBase64(InStreamLoc));
                end;
            FieldType::Media:
                exit;
            else
                JsonValueLoc.SetValue(Format(FieldRefPar.Value, 0, 9));
        end;
        exit(JsonValueLoc);
    end;

    local procedure GetJsonFieldName(FieldRefPar: FieldRef): Text
    var
        NameLoc: Text;
        iLoc: Integer;
    begin
        NameLoc := FieldRefPar.Name();
        for iLoc := 1 to Strlen(NameLoc) do
            if NameLoc[iLoc] < '0' then
                NameLoc[iLoc] := '_';

        exit(NameLoc.Replace('__', '_').TrimEnd('_').TrimStart('_'));
    end;

    local procedure AssignValueToFieldRef(var FieldRefVar: FieldRef; JsonKeyValuePar: JsonValue)
    var
        Base64ConvertLoc: Codeunit "Base64 Convert";
        TempBlobLoc: Codeunit "Temp Blob";
        RecordIdLoc: RecordId;
        OutStreamLoc: OutStream;
        GuidLoc: Guid;
    begin
        case FieldRefVar.Type() of
            FieldType::Code,
            FieldType::Text,
            FieldType::DateFormula:
                FieldRefVar.Value := JsonKeyValuePar.AsText();
            FieldType::Integer:
                FieldRefVar.Value := JsonKeyValuePar.AsInteger();
            FieldType::Date:
                FieldRefVar.Value := JsonKeyValuePar.AsDate();
            FieldType::Time:
                FieldRefVar.Value := JsonKeyValuePar.AsTime();
            FieldType::DateTime:
                FieldRefVar.Value := JsonKeyValuePar.AsDateTime();
            FieldType::Decimal:
                FieldRefVar.Value := JsonKeyValuePar.AsDecimal();
            FieldType::Duration:
                FieldRefVar.Value := JsonKeyValuePar.AsDuration();
            FieldType::Boolean:
                FieldRefVar.Value := JsonKeyValuePar.AsBoolean();
            FieldType::Option:
                FieldRefVar.Value := JsonKeyValuePar.AsOption();
            FieldType::BigInteger:
                FieldRefVar.Value := JsonKeyValuePar.AsBigInteger();
            FieldType::RecordId:
                begin
                    Evaluate(RecordIdLoc, JsonKeyValuePar.AsText());
                    FieldRefVar.Value := RecordIdLoc;
                end;
            FieldType::Guid:
                begin
                    Evaluate(GuidLoc, JsonKeyValuePar.AsText());
                    FieldRefVar.Value := GuidLoc;
                end;
            FieldType::Blob:
                begin
                    FieldRefVar.CalcField();
                    TempBlobLoc.CreateOutStream(OutStreamLoc, TextEncoding::Windows);
                    Base64ConvertLoc.FromBase64(JsonKeyValuePar.AsText(), OutStreamLoc);
                    TempBlobLoc.ToFieldRef(FieldRefVar);
                end;
            FieldType::Media:
                exit;
            else
                error(ErrNotSupportedFieldTypeGlob, FieldRefVar.Type());
        end;
    end;

    var
        ErrNotSupportedFieldTypeGlob: Label '%1 is not a supported field type';
        ErrParameterIsNotRecordGlob: Label 'Parameter Rec is not a record';
}