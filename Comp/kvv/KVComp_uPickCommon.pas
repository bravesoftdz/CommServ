unit KVComp_uPickCommon;

//==============================================================================
interface//=====================================================================
//==============================================================================

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Mask, rxToolEdit, DB;

type
  //////////////////////////////////////////////////////////////////////////////
  //������� ����� ��� ��������� �� ������ TCustomComboEdit
  //////////////////////////////////////////////////////////////////////////////
  TComboEditBase = class(TCustomComboEdit)
  protected
    FFormCaption: String;                                                       //�������� �����
    FReadOnly: Boolean;
    FControlList: array of TWinControl;                                         //������ �������������� ��������
  protected
    function GetControlCount: Integer;
    procedure SetReadOnly(const Value: Boolean);                                //������ ������ = ����� ���������� ��� TabStop � ����������� ��� ��������������
  public
    property ControlCount read GetControlCount;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure AddControl(const Control: TWinControl);                           //�������� ��������� � ������ �������� ���������
    procedure DeleteControl(const Control: TWinControl);                        //������� ��������� �� ������ �������� ���������
  public
    procedure DblClick; override;
  published
    property FormCaption: String read FFormCaption write FFormCaption;          //������������ �����
    property ReadOnly: Boolean read FReadOnly write SetReadOnly default false;  //������ ������ = ����� ���������� ��� TabStop � ����������� ��� ��������������
    property Alignment;
    property Anchors;
    property AutoSelect;
    property CharCase;
    property Enabled;
    property Font;
{$IFDEF RX_D4}
    property Anchors;
    property Constraints;
{$ENDIF}
    property MaxLength;
    property ParentFont;
    property ParentShowHint;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Text;
    property Visible;
    property OnButtonClick;
    property OnChange;
    property OnClick;
    property OnDblClick;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
  end;

  //////////////////////////////////////////////////////////////////////////////
  //������� ����� ��� ��������� �� ������ TCustomEdit
  //////////////////////////////////////////////////////////////////////////////
  TEditBase = class(TCustomEdit)
  protected
    FReadOnly: Boolean;
  protected
    procedure SetReadOnly(const Value: Boolean);
  protected
    property ReadOnly: Boolean read FReadOnly write SetReadOnly default true;
  published
    property Anchors;
    property AutoSelect;
    property AutoSize;
    property CharCase;
    property Constraints;
    property Enabled;
    property Font;
    property MaxLength;
    property ParentFont;
    property ParentShowHint;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Text;
    property Visible;
    property OnChange;
    property OnClick;
    property OnDblClick;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
  end;

//==============================================================================
implementation//================================================================
//==============================================================================

////////////////////////////////////////////////////////////////////////////////
//������� ����� ��� ��������� �� ������ TCustomComboEdit
////////////////////////////////////////////////////////////////////////////////

constructor TComboEditBase.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlState := ControlState + [csCreating];
  try
    GlyphKind := gkDropDown;
    ClickKey := VK_F2;
  finally
    ControlState := ControlState - [csCreating];
  end;
  SetLength(FControlList, 0);
end;

//------------------------------------------------------------------------------
destructor TComboEditBase.Destroy;
begin
  SetLength(FControlList, 0);
  inherited Destroy;
end;

//------------------------------------------------------------------------------
procedure TComboEditBase.SetReadOnly(const Value: Boolean);
begin
  FReadOnly := Value;
  if not FReadOnly then begin
    inherited ReadOnly := false;
    Color := clWindow;
    TabStop := true;
  end else begin
    inherited ReadOnly := true;
    Color := clBtnFace;
    TabStop := false;
  end;
end;

//------------------------------------------------------------------------------
function TComboEditBase.GetControlCount: Integer;
begin
  Result := Length(FControlList);
end;

//------------------------------------------------------------------------------
procedure TComboEditBase.AddControl(const Control: TWinControl);
begin
  if Assigned(Control) then begin
    SetLength(FControlList, ControlCount + 1);
    FControlList[ControlCount - 1] := Control;
  end;
end;

//------------------------------------------------------------------------------
procedure TComboEditBase.DeleteControl(const Control: TWinControl);
var
  i: Integer;
begin
  for i := 0 to ControlCount - 1 do begin
    if FControlList[i] = Control then begin
      FControlList[i] := nil;
      break;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TComboEditBase.DblClick;
begin
  if not (csDesigning in ComponentState) and not Assigned(OnDblClick) then begin
    ButtonClick;
  end;
  inherited;
end;

////////////////////////////////////////////////////////////////////////////////
//������� ����� ��� ��������� �� ������ TCustomEdit
////////////////////////////////////////////////////////////////////////////////
procedure TEditBase.SetReadOnly(const Value: Boolean);
begin
  FReadOnly := Value;
  if not FReadOnly then begin
    inherited ReadOnly := false;
    Color := clWindow;
    TabStop := true;
  end else begin
    inherited ReadOnly := true;
    Color := clBtnFace;
    TabStop := false;
  end;
end;

end.

