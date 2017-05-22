unit KVComp_UActivePanel;

interface

uses
  Variants, ComCtrls,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Mask, rxToolEdit;

type
  EAssignedItem    = class(Exception);
  EUnknownItemType = class(Exception);
  EBadValue        = class(Exception);
  EVarToExtended   = class (Exception);

const
  sAssignedItem     = '����������� ���� ����� (%s).';
  sUnknownItemType  = '��� ���� ����� "%s" ����������.';
  sBadValue         = '�������� �������� : "%s".';
  sEVarToExtended   = '������ ��� �������������� ����� %s � ������� ����';

type
 TActiveWinControl = class(TWinControl)
 public
   property OnClick;
   property OnEnter;
   property OnExit;
   property OnKeyDown;
   property OnKeyPress;
   property OnKeyUp;
 end;

{ ������, ��������� � ����������� ����� }
type
 TControlItem = class
 private
   { ��������� � ��������� �������� ���� }
   function  Get_sVal : String;
   procedure Set_sVal (const Value : String);
   function  Get_iVal : LongInt;
   procedure Set_iVal (const Value : LongInt);
   function  Get_fVal : Extended;
   procedure Set_fVal (const Value : Extended);
   function  Get_dVal : TDateTime;
   procedure Set_dVal (const Value : TDateTime);
   function  GetVal : Variant;
   procedure SetVal (const Value : Variant);
 public
   Name      : String;   { ��� ���������� ����� }
   vValue    : Variant;  { ������� �������� ���� }
   Control   : TControl; { �������������� ��������� }
   Index     : LongInt;  { ����� ���� }
   { �������� � ���������� }
   constructor Create (aControl : TControl);
   { ��������� ��� ��������� � ��������� �������� ���� }
   property sVal : String read Get_sVal write Set_sVal;
   property iVal : LongInt read Get_iVal write Set_iVal;
   property fVal : Extended read Get_fVal write Set_fVal;
   property dVal : TDateTime read Get_dVal write Set_dVal;
   property Val  : Variant read GetVal write SetVal;
 end;

{ ������ ����������� ����� }
type
 TFormControlList = class(TList)
 public
   Dummy : TControlItem; { ���������-�������� }
   { �������� � ���������� }
   constructor Create;
   destructor Destroy; override;
   { ������� ������ ��������� }
   procedure ClearAll;
   { �������� ��������� �� ����� }
   function ControlByName  (const aName : String) : TControlItem;
   { �������� ��������� �� ������ }
   function ControlByIndex (aIndex : LongInt) : TControlItem;
 end;

{ ���� ��������������� ������� }
type
 { ������ �������������� ���� }
 TFieldEnterEvent = procedure (Sender : TControlItem; const SenderName : String) of object;
 { ���������� �������������� ���� � �������� ��� �������� }
 TFieldExitEvent = procedure (Sender : TControlItem; const SenderName : String; var Valid : Boolean) of object;
 { ������� ������� �� �������������� ���������� }
 TFieldKeyEvent = procedure (Sender : TControlItem;
                             const SenderName : String;
                             var Key : Word; Shift : TShiftState) of object;
 { ������� ���� "OnClick" }
 TFieldClickEvent = procedure (Sender : TControlItem; const SenderName : String) of object;

 { �������������� �������� ���� }
 TFieldConvEvent = function (Sender : TControlItem;
                             const SenderName : String;
                             Value : Variant) : Variant of object;
{ ����� TActivePanel }
type
  TActivePanelOption  = (apoCheckOnlyModified);
  TActivePanelOptions = set of TActivePanelOption;

type
  TActivePanel = class(TPanel)
  private
    FOnFieldEnter : TFieldEnterEvent;    { ������ �������������� ���� }
    FOnFieldExit  : TFieldExitEvent;     { ���������� �������������� ���� � �������� ��� �������� }
    FOnFieldKey   : TFieldKeyEvent;      { ������� ������� �� �������������� ���������� }
    FOnFieldKeyUp : TFieldKeyEvent;
    FOnFieldClick : TFieldClickEvent;    { ������� ���� "OnClick" }
    FOnFieldConv  : TFieldConvEvent;     { �������������� �������� ���� }
    FOptions      : TActivePanelOptions; { ����� TActivePanel }
    { ����� ����������/����������� ���������� }
    function FindNextControl(CurControl: TWinControl;
      GoForward, CheckTabStop, CheckParent: Boolean): TWinControl;
    { �������� ��������� �� ����� }
    function GetControl (const aName : String) : TControlItem;
    { ������� � ���������� }
    procedure SelectNext(CurControl: TWinControl; GoForward, CheckTabStop: Boolean);
    { ������� �� ������ �������������� ����������� ���������� }
  private
    bRestoreFieldValue : Boolean; { ������� �������������� �������� ���� }
  protected
    FForm : TForm;               { ����������� ����� }
  public
    { ������ ���������� ��� �������� ����� }
    FldVars : TVars;
    { ������ �������������� ����������� }
    ControlList : TFormControlList;
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
    { ��������������� ��������� ����������� ����� }
    procedure Activate; virtual;
    { �������� ��������� �� ������ }
    function ControlByIndex (aIndex : LongInt) : TControlItem;
    { �������� �������� ����� }
    procedure GetFieldValues;
    { ���������� �������� ����� }
    procedure SetFieldValues;
    { �������� �������� ����� }
    function GetFieldAttrs (const FldName,FldAttr : String) : Variant;
    { ���������� ������� ���� }
    procedure SetActiveField(const FldName : String);
    { ���������� �������� ����� }
    procedure SetFieldAttrs (const FldName,FldAttr : String; Value : Variant);
    procedure SetFieldBounds(const FldName : String; aLeft, aTop, aWidth, aHeight: Integer);
    procedure SetFieldAccess(const FldName : String; aEnabled, aVisible : Boolean);
    procedure SetFieldColor (const FldName : String; Value : TColor);
    procedure SetFieldFontProp (const FldName,PropName : String; Value : Variant);
    procedure SetFieldMaskEdit (const FldName, aMaskEdit: String; aDecimalPlaces: Integer = 2);
    { ������ ����� ������ � �������������� ��������� }
    procedure OnControlEnter(Sender: TObject);
    { ������� �� ���������� �������������� ����������� ���������� }
    procedure OnControlExit(Sender: TObject);
    { ������� �� ������� ������� }
    procedure OnControlKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure OnControlKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    { ������� ���� "OnClick" }
    procedure OnControlClick(Sender: TObject);
    { �������� ��������� �� ����� }
    property Control[const aName : String] : TControlItem read GetControl; default;
  published
    { ��������� � ��������������� �������� }
    { ������ �������������� ���� }
    property OnFieldEnter : TFieldEnterEvent read FOnFieldEnter write FOnFieldEnter;
    { ���������� �������������� ���� � �������� ��� �������� }
    property OnFieldExit : TFieldExitEvent read FOnFieldExit write FOnFieldExit;
    { ������� ������� �� �������������� ���������� }
    property OnFieldKey   : TFieldKeyEvent read FOnFieldKey write FOnFieldKey;
    property OnFieldKeyUp : TFieldKeyEvent read FOnFieldKeyUp write FOnFieldKeyUp;
    { ������� ���� "OnClick" }
    property OnFieldClick : TFieldClickEvent read FOnFieldClick write FOnFieldClick;
    { �������������� �������� ���� }
    property OnFieldConv : TFieldConvEvent read FOnFieldConv write FOnFieldConv;
    { ����� TActivePanel }
    property Options : TActivePanelOptions read FOptions write FOptions;
  end;


{ �������� ��������� }
procedure FreeComponents (Form : TForm; Panel : TPanel);

{ �������� ����, ��� "P" �������� ������� (����������) ���������� "C" }
function IsChildrenComponent (P,C : TControl) : Boolean;


{ ����������� }
procedure Register;

implementation

uses
  TypInfo;

{ ����������� }
procedure Register;
begin
  RegisterComponents('SoftClub', [TActivePanel]);
end;

procedure SetControlColor (Control : TControl; Color : TColor);
var
  PropInfo: PPropInfo;
begin
  PropInfo := GetPropInfo(Control.ClassInfo, 'Color');
  SetOrdProp(Control, PropInfo, Color);
end;

procedure SetControlFontProp (Control : TControl; const PropName : String; Value : Variant);
var
  PropInfo : PPropInfo;
  Font : TFont;
  SI : Integer;
  FS : TFontStyles;
begin
  PropInfo := GetPropInfo(Control.ClassInfo, 'Font');
  if (PropInfo = Nil) then exit;
  Font := TFont(GetOrdProp(Control, PropInfo));
  if (Font = Nil) then exit;

  if (PropName = 'NAME') then
    Font.Name := Value
  else if (PropName = 'SIZE') then
    Font.Size := Value
  else if (PropName = 'COLOR') then
    Font.Color := Value
  else if (PropName = 'STYLE') then begin
    SI := Value;
    FS := [];
    if ((SI and 1) <> 0) then FS := FS+[fsBold];
    if ((SI and 2) <> 0) then FS := FS+[fsItalic];
    if ((SI and 4) <> 0) then FS := FS+[fsUnderline];
    if ((SI and 8) <> 0) then FS := FS+[fsStrikeOut];
    Font.Style := FS;
  end;
end;


{ �������� ��������� }
procedure FreeComponents (Form : TForm; Panel : TPanel);
var
 i : Integer;
 bRemove : Boolean;
 Item    : TComponent;
begin
 repeat
   bRemove := False;
   with Form do
   for i:=0 to ComponentCount-1 do begin
     if (not (Components[i] is TControl)) then continue;
     if (IsChildrenComponent(Panel,TControl(Components[i]))) then begin
      Item := Components[i];
      RemoveComponent(Item);
      Item.Free;
      bRemove := True;
      break;
     end;
   end;
 until (not bRemove);
end;

{ ��������� ������ ���� �� ��� ����� }
function GetFieldIndex (S : String) : LongInt;
var
 i,L : Integer;
begin
 Result := 0;
 L := Length(S);
 i := 1;
 while (i <= L) and (not (CharInSet(S[i], ['0'..'9']))) do Inc(i);
 if (i > L) then exit;
 try
  Result := StrToInt(Copy(S,i,L));
 except
 end;
end;

{ �������� ����, ��� "P" �������� ������� (����������) ���������� "C" }
function IsChildrenComponent (P,C : TControl) : Boolean;
begin
  Result := True;
  C := C.Parent;
  while (Assigned(C)) do begin
    if (C = P) then exit;
    C := C.Parent;
  end;
  Result := False;
end;


{---------------------------------------------------------------------------}
{ ��������� �����                                                           }
{---------------------------------------------------------------------------}

{ �������� � ���������� }
constructor TControlItem.Create (aControl : TControl);
begin
  Name      := '';
  vValue    := 0;
  Index     := 0;
  Control   := aControl;
  if (Assigned(Control)) then begin
    Name  := Control.Name;
    Index := GetFieldIndex(Control.Name);
    if (Control is TMaskEdit) then
      vValue := (Control as TMaskEdit).Text
    else if (Control is TCurrencyEdit) then
      vValue := (Control as TCurrencyEdit).Value
    else if (Control is TDateEdit) then
      vValue := (Control as TDateEdit).Date
    else if (Control is TMemo) then
      vValue := (Control as TMemo).Lines.Text
    else if (Control is TStaticText) then
      vValue := (Control as TStaticText).Caption
    else if (Control is TButton) then
      vValue := (Control as TButton).Caption
  end;
end;

{ �������� �������� ���� "String" }
function TControlItem.Get_sVal : String;
begin
  Result := VarAsType(GetVal,varUString);
end;

{ ���������� �������� ���� "String" }
procedure TControlItem.Set_sVal (const Value : String);
begin
  SetVal(Value);
end;

{ �������� �������� ���� "LongInt" }
function TControlItem.Get_iVal : LongInt;
begin
  Result := VarAsType(GetVal,varInteger);
end;

{ ���������� �������� ���� "LongInt" }
procedure TControlItem.Set_iVal (const Value : LongInt);
begin
  SetVal(Value);
end;

{ �������� �������� ���� "Extended" }
function TControlItem.Get_fVal : Extended;
begin
  Result := VarAsType(GetVal,varDouble);
end;

{ ���������� �������� ���� "Extended" }
procedure TControlItem.Set_fVal (const Value : Extended);
begin
  SetVal(Value);
end;

{ �������� �������� ���� "TDateTime" }
function TControlItem.Get_dVal : TDateTime;
begin
  Result := VarAsType(GetVal,varDate);
end;

{ ���������� �������� ���� "TDateTime" }
procedure TControlItem.Set_dVal (const Value : TDateTime);
begin
  SetVal(Value);
end;

{ �������� �������� ���� "Variant" }
function TControlItem.GetVal : Variant;
begin
  Result := vValue;
  if (not Assigned(Control)) then
    raise EAssignedItem.CreateFmt(sAssignedItem,[Name]);
  if (Control is TMaskEdit) then
    Result := (Control as TMaskEdit).Text
  else if (Control is TCurrencyEdit) then
    Result := (Control as TCurrencyEdit).Value
  else if (Control is TDateEdit) then
    Result := (Control as TDateEdit).Date
  else if (Control is TMemo) then
    Result := (Control as TMemo).Lines.Text
  else if (Control is TStaticText) then
    Result := (Control as TStaticText).Caption
  else if (Control is TButton) then
    Result := (Control as TButton).Caption
  else if (Control is TComboBox) then
    Result := (Control as TComboBox).ItemIndex
  else if (Control is TRadioGroup) then
    Result := (Control as TRadioGroup).ItemIndex
  else if (Control is TCheckBox) then
    Result := (Control as TCheckBox).Checked
  else
    raise EUnknownItemType.CreateFmt(sUnknownItemType,[Control.Name]);
end;
{ ���������� �������� ���� "Variant" }
procedure TControlItem.SetVal (const Value : Variant);
  //............................................................................
  function VarToExtend(aValue: Variant): Extended;
  var
    s  : String;
    ch : Char;
    i  : Integer;
  begin
    try
      result := aValue;
    except
      s:= FloatToStr(0.1);
      ch := s[2];
      s := format('%s', [aValue]);
      for i := 1 to length(s) do
        if CharInSet(s[i], ['.', ',']) then s[i] := ch;
      try
        result := strToFloat(s);
      except
        raise EVarToExtended.CreateFmt(sEVarToExtended, [aValue]);
      end;
    end;
  end;

begin
  vValue := Value;
  if (not Assigned(Control)) then
    raise EAssignedItem.CreateFmt(sAssignedItem,[Name]);

  if (Control is TMaskEdit) then
    (Control as TMaskEdit).Text := VarToStr(Value)
  else if (Control is TCurrencyEdit) then
    (Control as TCurrencyEdit).Value := VarToExtend(Value)
  else if (Control is TDateEdit) then
    (Control as TDateEdit).Date := VarToDateTime(Value)
  else if (Control is TMemo) then
    (Control as TMemo).Lines.Text := VarToStr(Value)
  else if (Control is TStaticText) then
    (Control as TStaticText).Caption := VarToStr(Value)
  else if (Control is TButton) then
    (Control as TButton).Caption := VarToStr(Value)
  else if (Control is TComboBox) then
    (Control as TComboBox).ItemIndex := Value
  else if (Control is TRadioGroup) then
    (Control as TRadioGroup).ItemIndex := Value
  else if (Control is TCheckBox) then
    (Control as TCheckBox).Checked := Value
  else
    raise EUnknownItemType.CreateFmt(sUnknownItemType,[Control.Name]);

end;


{---------------------------------------------------------------------------}
{ ������ ��������� �����                                                    }
{---------------------------------------------------------------------------}

{ �������� � ���������� }
constructor TFormControlList.Create;
begin
 inherited Create;
 { �������� �������� }
 Dummy := TControlItem.Create(Nil);
end;

destructor TFormControlList.Destroy;
begin
 ClearAll;
 Dummy.Free;
 inherited Destroy;
end;

{ ������� ������ ��������� }
procedure TFormControlList.ClearAll;
var
 i : Integer;
begin
 for i:=0 to Count-1 do
  TControlItem(Items[i]).Free;
 Clear;
end;

{ �������� ��������� �� ����� }
function TFormControlList.ControlByName (const aName : String) : TControlItem;
var
 S : String;
 i : Integer;
 C : TControlItem;
begin
  S := AnsiUpperCase(aName);
  for i:=0 to Count-1 do begin
   C := TControlItem(Items[i]);
   if (AnsiUpperCase(C.Control.Name) = S) then begin
    Result := C;
    exit;
   end;
  end;
  Result := Dummy;
end;

{ �������� ��������� �� ������ }
function TFormControlList.ControlByIndex (aIndex : LongInt) : TControlItem;
var
 i : Integer;
 C : TControlItem;
begin
 Result := Dummy;
 for i:=0 to Count-1 do begin
  C := TControlItem(Items[i]);
  if (C.Index = aIndex) then begin
   Result := C;
   exit;
  end;
 end;
end;

{----------------------------------------------------------------------------}
{ TActivePanel                                                               }
{----------------------------------------------------------------------------}
constructor TActivePanel.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);

  { ����������� ����� }
  if (Owner is TForm) then FForm := (Owner as TForm)
                      else FForm := Nil;

  { ������ ����������� }
  ControlList := TFormControlList.Create;

  { ��������������� ������� }
  FOnFieldEnter := Nil; { ������ �������������� ���� }
  FOnFieldExit  := Nil; { ���������� �������������� ���� � �������� ��� �������� }
  FOnFieldKey   := Nil; { ������� ������� �� �������������� ���������� }
  FOnFieldKeyUp := Nil; 
  FOnFieldClick := Nil; { ������� ���� "OnClick" }

  { ����� TActivePanel }
  FOptions := [apoCheckOnlyModified];

  { ������ ���������� ��� �������� ����� }
  FldVars := Nil;

  { ��������� �������� �������������� �������� ���� }
  bRestoreFieldValue := False;
end;

//------------------------------------------------------------------------------
destructor TActivePanel.Destroy;
begin
  ControlList.Free;
  inherited Destroy;
end;

{ ��������������� ��������� ����������� ����� }
procedure TActivePanel.Activate;
var
  i : Integer;
  C : TComponent;
  W : TActiveWinControl;
begin
  if (FForm = Nil) then exit;
  ControlList.ClearAll;

  { ������� ����������� ����� }
  with FForm do
  for i:=0 to ComponentCount-1 do begin
    C := Components[i];
    if (not (C is TWinControl)) then continue;
    W := TActiveWinControl(C);
    if (not IsChildrenComponent(Self,W)) then continue;
    W.OnKeyDown := Self.OnControlKeyDown;
    W.OnKeyUp   := Self.OnControlKeyUp;
    W.OnEnter   := Self.OnControlEnter;
    W.OnExit    := Self.OnControlExit;
    W.OnClick   := Self.OnControlClick;
    if C is TScrollBox then
    begin
      W.OnMouseWheelDown := (C as TScrollBox).OnMouseWheelDown;
      W.OnMouseWheelUp   := (C as TScrollBox).OnMouseWheelUp;
    end;

    ControlList.Add(TControlItem.Create(W));
  end;

end;

{------------------------------------------------------------------------------------}
{ ����� �����������                                                                  }
{------------------------------------------------------------------------------------}
{ �������� ��������� �� ����� }
function TActivePanel.GetControl (const aName : String) : TControlItem;
begin
  Result := ControlList.ControlByName(aName);
end;

{ �������� ��������� �� ������ }
function TActivePanel.ControlByIndex (aIndex : LongInt) : TControlItem;
begin
 Result := ControlList.ControlByIndex (aIndex);
end;

{------------------------------------------------------------------------------------}
{ ��������/���������� �������� �����                                                 }
{------------------------------------------------------------------------------------}
procedure TActivePanel.GetFieldValues;
var
  C : TControlItem;
  i : Integer;
begin
  if (not Assigned(FldVars)) then exit;
  for i:=0 to ControlList.Count-1 do begin
    C := ControlList[i];
    FldVars.PutVal([C.Name],C.Val);
  end;
end;

procedure TActivePanel.SetFieldValues;
var
  V : TVars;
  C : TControlItem;
  i : Integer;
begin
  if (not (Assigned(FldVars) and Assigned(FldVars.Items))) then exit;
  for i:=0 to FldVars.Items.Count-1 do begin
    V := FldVars.Items[i];
    C := GetControl(V.Name);
    if (not (Assigned(C) and Assigned(C.Control))) then continue;
    try
      C.Val := V.Val;
    except
    end;
  end;
end;

{------------------------------------------------------------------------------------}
{ ��������/���������� �������� �����                                                 }
{------------------------------------------------------------------------------------}
procedure TActivePanel.SetActiveField(const FldName : String);
var
  C : TControlItem;
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  procedure SetActivePage ;
  var
    W : TWinControl;
  begin
    W := C.Control.Parent;
    while not (W is TForm) do
    begin
      if (W is TTabSheet)  then
      begin
        TPageControl(W.Parent).ActivePage := TTabSheet(W);
        Break;
      end
      else
        W := W.Parent;
    end;
  end;
begin
  C := GetControl (FldName);
  if (Assigned(C) and Assigned(C.Control)) then
  begin
    SetActivePage;
    TWinControl(C.Control).SetFocus;
  end;
end;

function TActivePanel.GetFieldAttrs (const FldName,FldAttr : String) : Variant;
var
  C : TControlItem;
  W : TControl;
begin
  Result := 0;
  C := GetControl (FldName);
  if (not Assigned(C)) then exit;
  W := C.Control;
  if (AnsiUpperCase(FldAttr) = 'LEFT') then Result := W.Left
  else
  if (AnsiUpperCase(FldAttr) = 'TOP') then Result := W.Top
  else
  if (AnsiUpperCase(FldAttr) = 'WIDTH') then Result := W.Width
  else
  if (AnsiUpperCase(FldAttr) = 'HEIGHT') then Result := W.Height
  else
  if (AnsiUpperCase(FldAttr) = 'ENABLED') then Result := W.Enabled
  else
  if (AnsiUpperCase(FldAttr) = 'VISIBLE') then Result := W.Visible
end;

//------------------------------------------------------------------------------
procedure TActivePanel.SetFieldAttrs (const FldName,FldAttr : String; Value : Variant);
var
  C : TControlItem;
  W : TControl;
  W2 : TControl;
begin
  C := GetControl (FldName);
  if (not Assigned(C)) then exit;
  W := C.Control;
  if (AnsiUpperCase(FldAttr) = 'LEFT') then W.Left := Value
  else
  if (AnsiUpperCase(FldAttr) = 'TOP') then W.Top := Value
  else
  if (AnsiUpperCase(FldAttr) = 'WIDTH') then W.Width := Value
  else
  if (AnsiUpperCase(FldAttr) = 'HEIGHT') then W.Height := Value
  else
  if (AnsiUpperCase(FldAttr) = 'ENABLED') then W.Enabled := Value
  else
  if (AnsiUpperCase(FldAttr) = 'VISIBLE') then W.Visible := Value
  else
  if AnsiUpperCase(FldAttr) = 'ACTIVEPAGE' then
  begin
    C := GetControl (Value);
    if (not Assigned(C)) then exit;
    W2 := C.Control;
    (W as TPageControl).ActivePage := (W2 as TTabSheet);
  end;
end;

//------------------------------------------------------------------------------
procedure TActivePanel.SetFieldBounds(const FldName : String; aLeft, aTop, aWidth, aHeight: Integer);
var
  C : TControlItem;
  W : TControl;
begin
  C := GetControl (FldName);
  if (not Assigned(C)) then exit;
  W := C.Control;
  W.SetBounds(aLeft, aTop, aWidth, aHeight);
end;

//------------------------------------------------------------------------------
procedure TActivePanel.SetFieldAccess(const FldName : String; aEnabled, aVisible : Boolean);
var
  C : TControlItem;
  W : TControl;
begin
  C := GetControl(FldName);
  if assigned(C.Control) then begin
    W := C.Control;
    W.Enabled := aEnabled;
    W.Visible := aVisible;
  end;
end;

//------------------------------------------------------------------------------
procedure TActivePanel.SetFieldColor (const FldName : String; Value : TColor);
var
  C : TControlItem;
begin
  C := GetControl(FldName);
  if assigned(C.Control) then begin
    SetControlColor(C.Control, Value);
  end;
end;

//------------------------------------------------------------------------------
procedure TActivePanel.SetFieldFontProp (const FldName,PropName : String; Value : Variant);
var
  C : TControlItem;
begin
  C := GetControl (FldName);
  if (not Assigned(C)) then exit;
  SetControlFontProp (C.Control, PropName, Value);
end;

//------------------------------------------------------------------------------
procedure TActivePanel.SetFieldMaskEdit(const FldName, aMaskEdit: String;
  aDecimalPlaces: Integer);
var
  C : TControlItem;
  W : TWinControl;
begin
  C := GetControl(FldName);
  if assigned(C.Control) then
  begin
    W := TWinControl(C.Control);
    if (W is TMaskEdit)then
      (W as TMaskEdit).EditMask := aMaskEdit;
    if (W is TCurrencyEdit) then
    begin
      (W as TCurrencyEdit).DisplayFormat := aMaskEdit;
      (W as TCurrencyEdit).DecimalPlaces := aDecimalPlaces
    end;
  end;
end;

{------------------------------------------------------------------------------------}
{ ������ ����� ������ � �������������� ���������                                     }
{------------------------------------------------------------------------------------}
procedure TActivePanel.OnControlEnter(Sender: TObject);
var
 WinControl : TWinControl;
begin
 if (not (Sender is TWinControl)) then exit;
 if (not Assigned(FOnFieldEnter)) then exit;
 WinControl := (Sender as TWinControl);
 FOnFieldEnter (ControlList.ControlByName(WinControl.Name),AnsiUpperCase(WinControl.Name));
end;

{------------------------------------------------------------------------------------}
{ ������� ���� "OnClick"                                                             }
{------------------------------------------------------------------------------------}
procedure TActivePanel.OnControlClick(Sender: TObject);
var
 WinControl  : TWinControl;
 ControlItem : TControlItem;
 V : Variant;
begin
  WinControl  := (Sender as TWinControl);
  ControlItem := ControlList.ControlByName(WinControl.Name);
  if (Assigned(FldVars)) then
  try
    V := ControlItem.Val;
    FldVars.PutVal([WinControl.Name],V);
  except
  end;
  if (Assigned(FOnFieldClick)) then
    FOnFieldClick (ControlItem, AnsiUpperCase(WinControl.Name));
end;

{------------------------------------------------------------------------------------}
{ ���������� ����� ������ � �������������� ���������                                 }
{------------------------------------------------------------------------------------}
function EquVar (v1,v2 : Variant) : Boolean;
begin
  try
    Result := VarAsType(v1,varString) = VarAsType(v2,varString);
  except
    Result := False;
  end;
end;

//------------------------------------------------------------------------------
procedure TActivePanel.OnControlExit(Sender: TObject);
var
  Valid : Boolean;
  WinControl  : TWinControl;
  ControlItem : TControlItem;

  function PutValue : Boolean;
  var
    V : Variant;
  begin
    Result := False;
    if (not Assigned(ControlItem)) then exit;

    { TCustomEdit }
    if (WinControl is TCustomEdit) then begin

      if (apoCheckOnlyModified in FOptions) then begin
        V := ControlItem.vValue;
        if (WinControl is TMaskEdit) then begin
          if (EquVar(V,(WinControl as TMaskEdit).Text)) then exit;
        end
        else if (WinControl is TCurrencyEdit) then begin
          if (EquVar(V,(WinControl as TCurrencyEdit).Value)) then exit;
        end
        else begin
          if (EquVar(V, (WinControl as TCustomEdit).Text)) then exit;
        end;
      end;

      if (Assigned(FldVars)) then begin
        V := ControlItem.Val;
        if (Assigned(FOnFieldConv)) then
          V := FOnFieldConv(ControlItem, WinControl.Name, V);
        FldVars.PutVal([WinControl.Name],V);
      end;
    end

    { TComboBox }
    else if (WinControl is TComboBox) then begin
      if (Assigned(FldVars)) then
        FldVars.PutVal([WinControl.Name],(WinControl as TComboBox).ItemIndex);
      if (EquVar(ControlItem.vValue, (WinControl as TComboBox).ItemIndex)) and
         (apoCheckOnlyModified in FOptions) then
        exit;
    end
    { TRadioGroup }
    else if (WinControl is TRadioGroup) then begin
      if (Assigned(FldVars)) then
        FldVars.PutVal([WinControl.Name],(WinControl as TRadioGroup).ItemIndex);
      if (EquVar(ControlItem.vValue, (WinControl as TRadioGroup).ItemIndex)) and
         (apoCheckOnlyModified in FOptions) then
        exit;
    end
    { TCheckBox }
    else if (WinControl is TCheckBox) then begin
      if (Assigned(FldVars)) then
        FldVars.PutVal([WinControl.Name],(WinControl as TCheckBox).Checked);
      if (EquVar(ControlItem.vValue, (WinControl as TCheckBox).Checked)) and
         (apoCheckOnlyModified in FOptions) then
        exit;
    end;

    Result := True;
  end;

begin
  if (not (Sender is TWinControl)) then exit;

  WinControl  := (Sender as TWinControl);
  ControlItem := ControlList.ControlByName(WinControl.Name);

  if (not PutValue) then exit;

  if (not Assigned(FOnFieldExit)) then exit;
  Valid := True;
  FOnFieldExit (ControlItem, AnsiUpperCase(WinControl.Name), Valid);

  if (not Valid) then
    WinControl.SetFocus
  else if (Assigned(ControlItem)) then begin
    if (WinControl is TMaskEdit) then
      ControlItem.vValue := (WinControl as TMaskEdit).Text
    else if (WinControl is TCurrencyEdit) then
      ControlItem.vValue := (WinControl as TCurrencyEdit).Value
    else if (WinControl is TDateEdit) then
      ControlItem.vValue := (WinControl as TDateEdit).Date
    else if (WinControl is TMemo) then
      ControlItem.vValue := (WinControl as TMemo).Lines.Text
    else if (WinControl is TStaticText) then
      ControlItem.vValue := (WinControl as TStaticText).Caption
    else if (WinControl is TButton) then
      ControlItem.vValue := (WinControl as TButton).Caption
    else if (WinControl is TComboBox) then
      ControlItem.vValue := (WinControl as TComboBox).ItemIndex
    else if (WinControl is TRadioGroup) then
      ControlItem.vValue := (WinControl as TRadioGroup).ItemIndex
    else if (WinControl is TCheckBox) then
      ControlItem.vValue := (WinControl as TCheckBox).Checked
  end;
end;

{------------------------------------------------------------------------------------}
{ ������� ������� �� �������������� ����������                                       }
{------------------------------------------------------------------------------------}
function Crossing (WinControl : TWinControl) : Boolean;
begin
  Result :=
             (WinControl is TCustomEdit)
//             ((WinControl is TCustomEdit) and (not (WinControl is TCustomMemo)))
           or
             (WinControl is TCustomComboBox)
           or
             (WinControl is TCustomRadioGroup)
           or
             (WinControl is TRadioButton)
           or
             (WinControl is TCustomCheckBox)
end;

//------------------------------------------------------------------------------
procedure NexComboBoxItem (ComboBox : TComboBox);
var
  N : Integer;
begin
  if (ComboBox.Items.Count < 0) then exit;
  N := ComboBox.ItemIndex+1;
  if (N >= ComboBox.Items.Count) or (N < 0) then N := 0;
  ComboBox.ItemIndex := N;
end;

//------------------------------------------------------------------------------
procedure TActivePanel.OnControlKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  WinControl : TWinControl;
begin
 if (FForm = Nil) then exit;
 WinControl := FForm.ActiveControl as TWinControl;

 { ����� ����������������� ����������� ������� }
 if (Assigned(FOnFieldKey)) then
  FOnFieldKey (ControlList.ControlByName(WinControl.Name), AnsiUpperCase(WinControl.Name), Key, Shift);

 { ��������� Memo-���� }
 if (WinControl is TCustomMemo) then begin
   if (Key = VK_RETURN) and (ssCtrl in Shift) then
     Key := 10
   else if (Key = VK_RETURN) then begin
     SelectNext(WinControl, True, True );
     Key := 0;
   end;
   exit;
 end;

 { ��������� ������ <Enter> � <Down> }
 if (Key = VK_DOWN) then begin
   if (not Crossing(WinControl)) then exit;
   SelectNext(WinControl, True, True );
   Key := 0;
 end

 { ��������� ������� <Up> }
 else if (Key = VK_UP) then begin
   if (not Crossing(WinControl)) then exit;
   SelectNext(WinControl, False, True);
   Key := 0;
 end

 else if (Key = VK_RETURN) then begin
   if (ssCtrl in Shift) and (not bRestoreFieldValue) then exit;
   bRestoreFieldValue := False;
   if (not Crossing(WinControl)) then exit;
   SelectNext(WinControl, True, True );
   Key := 0;
 end

 { ��������� ������� <Up> }
 else if (Key = VK_SPACE) and (WinControl is TComboBox) then begin
   NexComboBoxItem (WinControl as TComboBox);
 end;

end;

//------------------------------------------------------------------------------
procedure TActivePanel.OnControlKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  function CanRestoreField : Boolean;
  var
    ScanCode : Integer;
  begin
    Result := False;
    if (Key = VK_NEXT) then begin
      Result := True;
      exit
    end;
    if (Key = VK_RETURN) then begin
      ScanCode := GetKeyState(VK_CONTROL);
      if (ScanCode >= 0) then exit;
      Result := True;
    end;
  end;


var
  WinControl : TWinControl;
  ControlItem : TControlItem;
  V : Variant;
begin
 if (FForm = Nil) then exit;
 WinControl := FForm.ActiveControl as TWinControl;

 { ����� ����������������� ����������� ������� }
 if (Assigned(FOnFieldKeyUp)) then
  FOnFieldKeyUp (ControlList.ControlByName(WinControl.Name), AnsiUpperCase(WinControl.Name), Key, Shift);

 { ��������� ������ <Ctrl>+<Enter> � <PgDn> }
 if (CanRestoreField) then begin
   try
     V := FldVars.GetVal(['OLD',WinControl.Name]);
     ControlItem := ControlList.ControlByName(WinControl.Name);
     ControlItem.Val := V;
     bRestoreFieldValue := True;
     Keybd_Event(VK_RETURN, 0, 0,0);
     exit;
   except
   end;
 end
end;

{------------------------------------------------------------------------------------}
{ ������� ����� ������������                                                         }
{------------------------------------------------------------------------------------}
function TActivePanel.FindNextControl(CurControl: TWinControl;
  GoForward, CheckTabStop, CheckParent: Boolean): TWinControl;
var
  StartControl : TWinControl;
  I, StartIndex: Integer;
  List: TList;
begin
  Result := Nil;
  StartControl := CurControl;
  List := TList.Create;
  try
    FForm.GetTabOrderList(List);
    if (List.Count > 0) then begin
      StartIndex := List.IndexOf(CurControl);
      if StartIndex = -1 then
        if GoForward then StartIndex := List.Count - 1 else StartIndex := 0;
      I := StartIndex;
      repeat
        if GoForward then begin
          Inc(I);
          if I = List.Count then I := 0;
        end
        else begin
          if (i = 0) then i := List.Count;
          Dec(i);
        end;
        CurControl := List[i];
        if CurControl.CanFocus and
          ((not CheckTabStop) or (CurControl.TabStop)) and
          ((not CheckParent)  or (CurControl.Parent = StartControl.Parent)) then
            Result := CurControl;
      until (Result <> Nil) or (i = StartIndex);
    end;
  finally
    List.Destroy;
  end;
end;

//------------------------------------------------------------------------------
procedure TActivePanel.SelectNext(CurControl: TWinControl;
  GoForward, CheckTabStop: Boolean);
begin
  CurControl := FindNextControl(CurControl, GoForward,
    CheckTabStop, not CheckTabStop);
  if (CurControl <> Nil) then CurControl.SetFocus;
end;


end.
