unit IEEE754unit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls,
  ExtCtrls, RichView, RVStyle, RichMemo;

type
  TDoubleUnion =  packed record
  case integer of
  1: ( i64: int64;  );
  2: ( i32: array[0..1] of Longint;  );
  3: ( d: double; );
  4: ( b: array[0..7] of Byte; );
  end;

  { TMainForm }

  TMainForm = class(TForm)
    AcceptFloatButton: TButton;
    LittleEndianHex: TEdit;
    EnterBinaryValue: TComboBox;
    DecimalFloatingPointValue: TComboBox;
    HexadecimalEdit: TEdit;
    EnterBinaryDoubleButton: TButton;
    EnterHexadecimalValueButton: TButton;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    RichMemo: TRichMemo;
    procedure AcceptFloatButtonClick(Sender: TObject);
    procedure EnterHexadecimalValueButtonClick(Sender: TObject);
    procedure EnterBinaryDoubleButtonClick(Sender: TObject);
  private
    procedure DrawIEEE754value(u:TDoubleUnion; skip:Integer);
    function BinaryInt64toString(v:Int64):string;
    function LittleEndianHexString(u:TDoubleUnion):string;
  public

  end;


var
  MainForm: TMainForm;

implementation

{$R *.lfm}

{ TMainForm }

procedure TMainForm.AcceptFloatButtonClick(Sender: TObject);
var
  u:TDoubleUnion;
  s,entireText,src:String;

  i,one:int64;
  v,m,mv:int64;
  entireTextLength,srcLength,base:Longint;

  fontParams:TFontParams;
  ok:boolean;
begin
  s:='';
  one:=1;
  Try
     ok:=true;
     src:=DecimalFloatingPointValue.Text;
     u.d:=StrToFloat(src);
     DrawIEEE754value(u,1);
     EnterBinaryValue.Text:=BinaryInt64toString(u.i64);
     HexadecimalEdit.Text:=HexStr(QWord(u.i64),16);
     LittleEndianHex.Text:=LittleEndianHexString(u);
  except
     On E : Exception do begin
     s:='error';
     ok:=false;
     RichMemo.Lines.Add(s);
     exit;
     end;
  end;
end;

function TMainForm.LittleEndianHexString(u:TDoubleUnion):string;
var
    i:integer;
    s:string;
begin
  s:='';
  for i:=0 to 7 do begin
     s:=s+HexStr(u.b[i],2)+' ';
  end;
  result:=s;
end;

procedure TMainForm.EnterHexadecimalValueButtonClick(Sender: TObject);
var
    u:TDoubleUnion;
    a:array[0..7] of byte;
    len,i:Integer;
    input:string;
begin
    u.i64:=0;
    input:=HexadecimalEdit.Text;
    len:=Length(input);
    if (len>16) then len:=16;
    HexToBin(PChar(input),PChar(@a),len);
    for i:=0 to 7 do u.b[i]:=a[7-i];
    DrawIEEE754value(u,3);

    EnterBinaryValue.Text:=BinaryInt64toString(u.i64);
    //HexadecimalEdit.Text:=HexStr(QWord(u.i64),16);
    DecimalFloatingPointValue.Text:=FloatToStrF(u.d, ffGeneral, 17,17);
    LittleEndianHex.Text:=LittleEndianHexString(u);
end;

function TMainForm.BinaryInt64toString(v:Int64):string;
var
  i,one:int64;
  m,mv:int64;
  s:string;
begin
    s:='';
    one:=1;
    for i:=63 downto 0 do begin
        m:= one shl i;
        mv:= v and m;
     	if ((mv)<>0) then s:=s+'1' else s:=s+'0';
     	if ((i mod 4)=0) then s:=s+' ';
    end;
    result:=s;
end;

procedure TMainForm.DrawIEEE754value(u:TDoubleUnion; skip:Integer);
var
  s,entireText,tgt:String;

  i,one:int64;
  v,m,mv:int64;
  entireTextLength,tgtLength,base:Longint;

  fontParams:TFontParams;
  ok:boolean;
begin
    s:='';
    one:=1;
    v:=u.i64;
    for i:=63 downto 0 do begin
        m:= one shl i;
        v:=u.i64;
        mv:= v and m;
     	if ((mv)<>0) then s:=s+'1' else s:=s+'0';
     	if ((i mod 4)=0) then s:=s+' ';
    end;

    tgt:='value='+FloatToStr(u.d);

    s:=s+tgt;

    fontParams.Name:='Consolas';
    fontParams.Size:=10;
    fontParams.Color:=clBlue;
    fontParams.Style:=[fsBold];
    fontParams.HasBkClr:=false;
    fontParams.BkColor:=clWhite;
    fontParams.VScriptPos:=vpNormal;

    RichMemo.Lines.Add(s);
    entireText:=RichMemo.Lines.Text;
    entireTextLength:=Length(entireText);
    tgtLength:=Length(tgt);

    base:=entireTextLength-tgtLength-1-64-16;

    fontParams.Color:=clBlue;
    RichMemo.SetTextAttributes(base,   1,fontParams);

    fontParams.Color:=clGreen;
    RichMemo.SetTextAttributes(base+1, 13,fontParams);

    fontParams.Color:=$006800CC;
    RichMemo.SetTextAttributes(base+14, 66,fontParams);

    fontParams.Color:=clBlack;
    RichMemo.SetTextAttributes(base+80, tgtLength,fontParams);

end;


procedure TMainForm.EnterBinaryDoubleButtonClick(Sender: TObject);
var
    u:TDoubleUnion;
    i,idx,one:int64;
    v,m,mv:int64;
    s,entireText,tgt:string;
    c:char;

    entireTextLength,srcLength,base:Longint;
    fontParams:TFontParams;
    ok:boolean;

begin
  s:=EnterBinaryValue.Text;

  srcLength:=Length(s);

  idx:=1;
  i:=0;
  one:=1;
  v:=0;

  while (idx<=srcLength) do begin
    c:=s[idx];
    if (c='1') then begin
        v:= v shl 1;
        v:= v or 1;
        //inc(i);
    end else
    if (c='0') then begin
        v:= v shl 1;
        //inc(i);
    end else
    if (c<>' ') then begin
        RichMemo.Lines.Add('Error at character: '+IntToStr(i));
        Exit;
        //break;
    end;
    inc(idx);
  end;

  u.i64:= v;

  DrawIEEE754value(u, 2);

  HexadecimalEdit.Text:=HexStr(QWord(u.i64),16);
  DecimalFloatingPointValue.Text:=FloatToStrF(u.d, ffGeneral, 17,17);
  LittleEndianHex.Text:=LittleEndianHexString(u);
end;

end.

