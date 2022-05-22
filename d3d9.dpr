library d3d9;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

uses
  System.SysUtils,
  System.Classes,
  WinAPI.Windows,
  DDetours;

{$R *.res}

var
  TrampolineGlobalMemoryStatusEx: function(var lpBuffer: TMEMORYSTATUSEX)
    : BOOL stdcall = nil;
  TrampolineGlobalMemoryStatus: procedure(var lpBuffer: TMemoryStatus)
    stdcall = nil;

procedure InterceptGlobalMemoryStatus(var lpBuffer: TMemoryStatus); stdcall;
begin
TrampolineGlobalMemoryStatus(lpBuffer);
lpBuffer.dwTotalPhys:=2147483647;
lpBuffer.dwTotalPageFile:=0;
lpBuffer.dwAvailPageFile:=0;
lpBuffer.dwAvailPhys:=2147483647;
end;

function InterceptGlobalMemoryStatusEx(var lpBuffer: TMEMORYSTATUSEX)
  : BOOL; stdcall;
begin
  Result := TrampolineGlobalMemoryStatusEx(lpBuffer);
  lpBuffer.ullTotalPhys:=2147483647;
  lpBuffer.ullTotalPageFile:=0;
  lpBuffer.ullAvailPageFile:=0;
  lpBuffer.ullAvailPhys:=2147483647;
end;

procedure ShowMessage(Msg: string; Caption: string = '');
begin
  MessageBox(0, PWideChar(Msg), PWideChar(Caption), MB_OK or MB_TASKMODAL);
end;

function Direct3DCreate9:pointer; external 'd3d9.dll' name 'Direct3DCreate9';
function D3DPERF_BeginEvent:pointer; external 'd3d9.dll' name 'D3DPERF_BeginEvent';
function D3DPERF_EndEvent:pointer; external 'd3d9.dll' name 'D3DPERF_EndEvent';

exports Direct3DCreate9, D3DPERF_BeginEvent, D3DPERF_EndEvent;

begin
Showmessage('DirectX Low Memory Patch'#13#10'by Rudra');
  if not Assigned(TrampolineGlobalMemoryStatusEx) then
    @TrampolineGlobalMemoryStatusEx := InterceptCreate(@GlobalMemoryStatusEx,
      @InterceptGlobalMemoryStatusEx);
  if not Assigned(TrampolineGlobalMemoryStatus) then
    @TrampolineGlobalMemoryStatus := InterceptCreate(@GlobalMemoryStatus,
      @InterceptGlobalMemoryStatus);

end.
