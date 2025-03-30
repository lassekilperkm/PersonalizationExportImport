codeunit 90102 "Record Functions"
{
    internal procedure Json2Rec(JsonObject: JsonObject; RecToConvert: Variant): Variant
    var
        RecRef: RecordRef;
    begin
        if not RecToConvert.IsRecord then
            Error(ErrParameterIsNotRecord);
        RecRef.GetTable(RecToConvert);
        exit(Json2Rec(JsonObject, RecRef.Number()));
    end;

    local procedure Json2Rec(JsonObject: JsonObject; TableNo: Integer): Variant
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
        FieldHash: Dictionary of [Text, Integer];
        i: Integer;
        JsonKey: Text;
        JsonToken: JsonToken;
        JsonKeyValue: JsonValue;
        RecVariant: Variant;
    begin
        RecRef.OPEN(TableNo);
        for i := 1 to RecRef.FieldCount() do begin
            FieldRef := RecRef.FieldIndex(i);
            FieldHash.Add(GetJsonFieldName(FieldRef), FieldRef.Number);
        end;
        RecRef.Init();
        foreach JsonKey in JsonObject.Keys() do
            if JsonObject.Get(JsonKey, JsonToken) then
                if JsonToken.IsValue() then begin
                    JsonKeyValue := JsonToken.AsValue();
                    FieldRef := RecRef.Field(FieldHash.Get(JsonKey));
                    AssignValueToFieldRef(FieldRef, JsonKeyValue);
                end;

        RecVariant := RecRef;
        exit(RecVariant);
    end;

    procedure Rec2Json(Rec2Convert: Variant): JsonObject
    var

        RecRef: RecordRef;
        FieldRef: FieldRef;
        JsonObject: JsonObject;
        i: Integer;
    begin
        if not Rec2Convert.IsRecord then
            error(ErrParameterIsNotRecord);
        RecRef.GetTable(Rec2Convert);
        for i := 1 to RecRef.FieldCount() do begin
            FieldRef := RecRef.FieldIndex(i);
            case FieldRef.Class of
                FieldRef.Class::Normal:
                    JsonObject.Add(GetJsonFieldName(FieldRef), FieldRef2JsonValue(FieldRef));
                FieldRef.Class::FlowField:
                    begin
                        FieldRef.CalcField();
                        JsonObject.Add(GetJsonFieldName(FieldRef), FieldRef2JsonValue(FieldRef));
                    end;
            end;
        end;
        exit(JsonObject);
    end;

    local procedure FieldRef2JsonValue(FieldRef: FieldRef): JsonValue
    var
        Base64Convert: Codeunit "Base64 Convert";
        TempBlob: Codeunit "Temp Blob";
        InStream: InStream;
        JsonValue: JsonValue;
        Date: Date;
        DateTime: DateTime;
        Time: Time;
    begin
        case FieldRef.Type() of
            FieldType::Date:
                begin
                    Date := FieldRef.Value;
                    JsonValue.SetValue(Date);
                end;
            FieldType::Time:
                begin
                    Time := FieldRef.Value;
                    JsonValue.SetValue(Time);
                end;
            FieldType::DateTime:
                begin
                    DateTime := FieldRef.Value;
                    JsonValue.SetValue(DateTime);
                end;
            FieldType::Blob:
                begin
                    FieldRef.CalcField();
                    TempBlob.FromFieldRef(FieldRef);
                    TempBlob.CreateInStream(InStream);
                    JsonValue.SetValue(Base64Convert.ToBase64(InStream));
                end;
            FieldType::Media:
                exit;
            else
                JsonValue.SetValue(Format(FieldRef.Value, 0, 9));
        end;
        exit(JsonValue);
    end;

    local procedure GetJsonFieldName(FieldRef: FieldRef): Text
    var
        Name: Text;
        i: Integer;
    begin
        Name := FieldRef.Name();
        for i := 1 to Strlen(Name) do
            if Name[i] < '0' then
                Name[i] := '_';

        exit(Name.Replace('__', '_').TrimEnd('_').TrimStart('_'));
    end;

    local procedure AssignValueToFieldRef(var FieldRef: FieldRef; JsonKeyValue: JsonValue)
    var
        Base64Convert: Codeunit "Base64 Convert";
        TempBlob: Codeunit "Temp Blob";
        RecordId: RecordId;
        OutStream: OutStream;
        Guid: Guid;
    begin
        case FieldRef.Type() of
            FieldType::Code,
            FieldType::Text,
            FieldType::DateFormula:
                FieldRef.Value := JsonKeyValue.AsText();
            FieldType::Integer:
                FieldRef.Value := JsonKeyValue.AsInteger();
            FieldType::Date:
                FieldRef.Value := JsonKeyValue.AsDate();
            FieldType::Time:
                FieldRef.Value := JsonKeyValue.AsTime();
            FieldType::DateTime:
                FieldRef.Value := JsonKeyValue.AsDateTime();
            FieldType::Decimal:
                FieldRef.Value := JsonKeyValue.AsDecimal();
            FieldType::Duration:
                FieldRef.Value := JsonKeyValue.AsDuration();
            FieldType::Boolean:
                FieldRef.Value := JsonKeyValue.AsBoolean();
            FieldType::Option:
                FieldRef.Value := JsonKeyValue.AsOption();
            FieldType::BigInteger:
                FieldRef.Value := JsonKeyValue.AsBigInteger();
            FieldType::RecordId:
                begin
                    Evaluate(RecordId, JsonKeyValue.AsText());
                    FieldRef.Value := RecordId;
                end;
            FieldType::Guid:
                begin
                    Evaluate(Guid, JsonKeyValue.AsText());
                    FieldRef.Value := Guid;
                end;
            FieldType::Blob:
                begin
                    FieldRef.CalcField();
                    TempBlob.CreateOutStream(OutStream, TextEncoding::Windows);
                    Base64Convert.FromBase64(JsonKeyValue.AsText(), OutStream);
                    TempBlob.ToFieldRef(FieldRef);
                end;
            FieldType::Media:
                exit;
            else
                error(ErrNotSupportedFieldType, FieldRef.Type());
        end;
    end;

    var
        ErrNotSupportedFieldType: Label '%1 is not a supported field type';
        ErrParameterIsNotRecord: Label 'Parameter Rec is not a record';
}
