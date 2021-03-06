unit HlpRotating;

{$I HashLib.inc}

interface

uses
  HlpHashLibTypes,
  HlpBits,
  HlpHash,
  HlpIHashInfo,
  HlpHashResult,
  HlpIHashResult;

type
  TRotating = class sealed(THash, IHash32, IBlockHash, ITransformBlock)
  strict private

    Fm_hash: UInt32;

  public
    constructor Create();
    procedure Initialize(); override;
    procedure TransformBytes(const a_data: THashLibByteArray;
      a_index, a_length: Int32); override;
    function TransformFinal(): IHashResult; override;
  end;

implementation

{ TRotating }

constructor TRotating.Create;
begin
  Inherited Create(4, 1);
end;

procedure TRotating.Initialize;
begin
  Fm_hash := 0;
end;

procedure TRotating.TransformBytes(const a_data: THashLibByteArray;
  a_index, a_length: Int32);
var
  i: Int32;
begin
{$IFDEF DEBUG}
  System.Assert(a_index >= 0);
  System.Assert(a_length >= 0);
  System.Assert(a_index + a_length <= System.Length(a_data));
{$ENDIF DEBUG}
  i := a_index;
  while a_length > 0 do
  begin

    Fm_hash := TBits.RotateLeft32(Fm_hash, 4) xor a_data[i];
    System.Inc(i);
    System.Dec(a_length);
  end;

end;

function TRotating.TransformFinal: IHashResult;
begin
  result := THashResult.Create(Fm_hash);
  Initialize();
end;

end.
