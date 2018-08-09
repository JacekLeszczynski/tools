program ToolGenConf;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, SysUtils, CustApp, ExtParams;

type

  { TToolsGenerateConf }

  TToolGenConf = class(TCustomApplication)
  private
    param: TExtParams;
    plik: TStringList;
  protected
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  Application: TToolGenConf;
  TextSeparator: char;

function GetLineToStr(s: string; l: integer; separator: char; wynik: string = ''): string;
var
  i,ll,dl: integer;
  b: boolean;
begin
  b:=false;
  dl:=length(s);
  ll:=1;
  s:=s+separator;
  for i:=1 to length(s) do
  begin
    if s[i]=textseparator then b:=not b;
    if (not b) and (s[i]=separator) then inc(ll);
    if ll=l then break;
  end;
  if ll=1 then dec(i);
  delete(s,1,i);
  b:=false;
  for i:=1 to length(s) do
  begin
    if s[i]=textseparator then b:=not b;
    if (not b) and (s[i]=separator) then break;
  end;
  delete(s,i,dl);
  if (s<>'') and (s[1]=textseparator) then
  begin
    delete(s,1,1);
    delete(s,length(s),1);
  end;
  if s='' then s:=wynik;
  result:=s;
end;

{ TToolsGenerateConf }

procedure TToolGenConf.DoRun;
var
  zrodlo,cel,v: string;
  i,j: integer;
  s,s1,s2,pom: string;
  dt: TDateTime;
begin
  dt:=now;
  param.Execute;
  zrodlo:=param.GetValue('in');
  cel:=param.GetValue('out');
  v:=param.GetValue('values');
  if FileExists(zrodlo) then
  begin
    writeln('Konwersja '+zrodlo+' -> '+cel);
    plik.LoadFromFile(zrodlo);
    i:=0;
    while true do
    begin
      inc(i);
      s:=GetLineToStr(v,i,' ');
      if s='' then break;
      s1:=GetLineToStr(s,1,'=');
      s2:=GetLineToStr(s,2,'=');
      for j:=0 to plik.Count-1 do
      begin
        if s1='?DATE?' then s2:=FormatDateTime('ddd',dt)+', '+FormatDateTime('dd',dt)+' '+FormatDateTime('mmm',dt)+' '+FormatDateTime('yyyy',dt)+' '+FormatDateTime('hh:nn:ss',dt)+' +0200';
        pom:=plik[j];
        pom:=StringReplace(pom,s1,s2,[rfReplaceAll]);
        plik.Delete(j);
        plik.Insert(j,pom);
      end;
    end;
    plik.SaveToFile(cel);
  end else writeln('Plik nie znaleziony - wychodzę.');
  Terminate;
end;

constructor TToolGenConf.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  TextSeparator:='"';
  param:=TExtParams.Create(nil);
  param.ParamsForValues.Add('in');
  param.ParamsForValues.Add('out');
  param.ParamsForValues.Add('values');
  plik:=TStringList.Create;
end;

destructor TToolGenConf.Destroy;
begin
  param.Free;
  plik.Free;
  inherited Destroy;
end;

begin
  Application:=TToolGenConf.Create(nil);
  Application.Title:='ToolsGenerateConf';
  Application.Run;
  Application.Free;
end.

