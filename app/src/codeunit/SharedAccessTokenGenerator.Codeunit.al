codeunit 82563 SharedAccessTokenGenerator
{
    Access = Internal;

    [NonDebuggable]
    procedure GetSasToken(ResourceUri: Text; SharedKeyName: Text; SharedKeyValue: Text): Text;
    var
        TypeHelper: codeunit "Type Helper";
        EncryptionManagement: codeunit "Cryptography Management";
        EncodedResourceUri: Text;
        expiry: Text;
        stringToSign: Text;
        signature: Text;
        Cr: Text[1];
        TimeToLive: Integer;
        SigTok: Label 'SharedAccessSignature sr=%1&sig=%2&se=%3&skn=%4', Locked = true;
    begin
        EncodedResourceUri := TypeHelper.UrlEncode(resourceUri);
        TimeToLive := 10000;

        Cr[1] := 10;

        expiry := GetExpiry(TimeToLive);
        stringToSign := EncodedResourceUri + Cr + expiry;
        signature := EncryptionManagement.GenerateHashAsBase64String(stringToSign, SharedKeyValue, 2 /* HMACSHA256 */);

        exit(StrSubstNo(SigTok,
            EncodedResourceUri,
            TypeHelper.UrlEncode(signature),
            expiry,
            SharedKeyName));
    end;

    local procedure GetExpiry(ttl: Integer): Text;
    var
        expirySinceEpoch: BigInteger;
    begin
        expirySinceEpoch := (CurrentDateTime() - CreateDateTime(19700101D, 0T)) div 1000 + ttl;
        exit(Format(expirySinceEpoch));
    end;
}

