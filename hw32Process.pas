unit hw32Process;

{
    Esta Unit fue elaborada combinando Información de Sitios como "stackoverflow.com"
}

interface

uses
   Winapi.Windows, System.SysUtils, System.Classes, TLHelp32, psAPI, Vcl.ComCtrls;

type
   TQueryFullProcessImageNameW = function(AProcess: THANDLE; AFlags: DWORD; AFileName: PWideChar; var ASize: DWORD): BOOL; stdcall;
   TGetModuleFileNameExW = function(AProcess: THANDLE; AModule: HMODULE; AFilename: PWideChar; ASize: DWORD): DWORD; stdcall;

   tprocesswin= record
      tpwHND: THandle;
      tpwCAP: string[128];
      tpwNAM: string[128];
   end;

   tprocessdata= record
      tpdPID: DWORD;
      tpdEXE: string[128];
      tpdDIR: UnicodeString;
      tpdWIN: array[0..127] of tprocesswin;
      tpdWCOUNT: byte;
   end;

   tprocesslist= array[0..512] of tprocessdata;

var
   PsapiLib: HMODULE;
   GetModuleFileNameExW: TGetModuleFileNameExW;
   proclist: tprocesslist;
   proccant: dword;

   procedure EnumAllw32Processes();
   procedure ShowProcess(tvprocess: TTreeView);

implementation

procedure ShowProcess(tvprocess: TTreeView);
var
   i, j: integer;
   PNode: TTreeNode;
begin
   tvprocess.Items.Clear();
   for i:=0 to proccant-1 do
   begin
      PNode:= tvprocess.Items.AddChildObject(nil,'['+IntToStr(i)+'] ['+IntToStr(proclist[i].tpdWCOUNT)+'] ['+IntToStr(proclist[i].tpdPID)+'] ['+proclist[i].tpdEXE+'] ['+proclist[i].tpdDIR+']',nil);
      for j:=0 to proclist[i].tpdWCOUNT-1 do
      begin
         tvprocess.Items.AddChildObject(PNode,'['+IntToStr(proclist[i].tpdWIN[j].tpwHND)+'] ['+proclist[i].tpdWIN[j].tpwNAM+'] ['+proclist[i].tpdWIN[j].tpwCAP+']',nil);
      end;
   end;
end;

procedure UpdateProcessWinList(wdata: tprocesswin; wPID: DWORD);
var
   i: dword;
begin
   try
      for i:=0 to proccant-1 do
      begin
         if (proclist[i].tpdPID=wPID) and (wPID<>0) and  (proclist[i].tpdWCOUNT<127) then
         begin
            proclist[i].tpdWIN[proclist[i].tpdWCOUNT]:= wdata;
            inc(proclist[i].tpdWCOUNT);
            Break;
         end;
      end;
      except
      on exception do
      begin
      end;
   end;
end;

function EnumChildWindowsProc(Wnd: HWnd): BOOL; export; {$ifdef Win32} stdcall; {$endif}
var
   windata: tprocesswin;
   ProcID: DWORD;
   auxtext: array[0..127] of char;
begin
   windata.tpwHND:= Wnd;
   GetWindowText(Wnd,auxtext,128);
   windata.tpwCAP:= StrPas(auxtext);
   GetClassName(Wnd,auxtext,128);
   windata.tpwNAM:= StrPas(auxtext);
   GetWindowThreadProcessId(Wnd,ProcID);
   if windata.tpwCAP='' then
   begin
      windata.tpwCAP:= 'NOCAPTION';
   end;
   if GetWindow(Wnd,GW_CHILD)=0 then
   begin
      Enumchildwindows(Wnd,@EnumChildWindowsProc,0);
   end;
   UpdateProcessWinList(windata,ProcID);
   Result := True;
end;

function EnumWindowsProc(Wnd: HWnd): BOOL; export; {$ifdef Win32} stdcall; {$endif}
var
   windata: tprocesswin;
   ProcID: DWORD;
   auxtext: array[0..127] of char;
begin
   try
      windata.tpwHND:= Wnd;
      GetWindowText(Wnd,auxtext,128);
      windata.tpwCAP:= StrPas(auxtext);
      GetClassName(Wnd,auxtext,128);
      windata.tpwNAM:= StrPas(auxtext);
      GetWindowThreadProcessId(Wnd,ProcID);
      if windata.tpwCAP='' then
      begin
         windata.tpwCAP:= 'NOCAPTION';
      end;
      EnumChildWindows(Wnd,@EnumChildWindowsProc,0);
      UpdateProcessWinList(windata,ProcID);
      Result:= True;
      except
      on exception do
      begin
      end;
   end;
end;

function IsWindows200OrLater(): Boolean;
begin
   Result:= Win32MajorVersion>=5;
end;

function IsWindowsVistaOrLater(): Boolean;
begin
   Result:= Win32MajorVersion>=6;
end;

procedure DonePsapiLib();
begin
   if PsapiLib=0 then
   begin
      Exit;
   end;
   FreeLibrary(PsapiLib);
   PsapiLib:= 0;
   @GetModuleFileNameExW:= nil;
end;

procedure InitPsapiLib();
begin
   if PsapiLib<>0 then
   begin
      Exit;
   end;
   PsapiLib:= LoadLibrary('psapi.dll');
   if PsapiLib=0 then
   begin
      RaiseLastOSError;
   end;
   @GetModuleFileNameExW:= GetProcAddress(PsapiLib,'GetModuleFileNameExW');
   if not Assigned(GetModuleFileNameExW) then
   begin
      try
         RaiseLastOSError;
         except
            DonePsapiLib;
         raise;
      end;
   end;
end;

function GetFileNameByProcessID(AProcessID: DWORD): UnicodeString;
const
   PROCESS_QUERY_LIMITED_INFORMATION = $00001000; //Vista and above
var
   HProcess: THandle;
   Lib: HMODULE;
   QueryFullProcessImageNameW: TQueryFullProcessImageNameW;
   S: DWORD;
begin
   if IsWindowsVistaOrLater then
   begin
      Lib:= GetModuleHandle('kernel32.dll');
      if Lib=0 then
      begin
         RaiseLastOSError;
      end;
      @QueryFullProcessImageNameW:= GetProcAddress(Lib,'QueryFullProcessImageNameW');
      if not Assigned(QueryFullProcessImageNameW) then
      begin
         RaiseLastOSError;
      end;
      HProcess:= OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION,False,AProcessID);
      if HProcess=0 then
      begin
         RaiseLastOSError;
      end;
      try
         S:= MAX_PATH;
         SetLength(Result,S+1);
         while not QueryFullProcessImageNameW(HProcess,0,PWideChar(Result),S) and (GetLastError=ERROR_INSUFFICIENT_BUFFER) do
         begin
            S:= S*2;
            SetLength(Result,S+1);
         end;
         SetLength(Result,S);
         Inc(S);
         if not QueryFullProcessImageNameW(HProcess,0,PWideChar(Result),S) then
         begin
            RaiseLastOSError();
         end;
      finally
         CloseHandle(HProcess);
      end;
   end else
   begin
      if IsWindows200OrLater then
      begin
         InitPsapiLib;
         HProcess:= OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ, False, AProcessID);
         if HProcess=0 then
         begin
            RaiseLastOSError;
         end;
         try
            S:= MAX_PATH;
            SetLength(Result,S+1);
            if GetModuleFileNameExW(HProcess,0,PWideChar(Result),S)=0 then
            begin
               RaiseLastOSError;
            end;
            Result:= PWideChar(Result);
         finally
            CloseHandle(HProcess);
         end;
      end;
   end;
end;

procedure EnumProcesses();
var
   Snapshot: THandle;
   Entry: TProcessEntry32;
   Found: Boolean;
   Count: Integer;
begin
    proccant:= 0;
    Snapshot:= CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
    if (Snapshot=INVALID_HANDLE_VALUE) or (Snapshot=0) then
    begin
       Exit;
    end;
    try
       ZeroMemory(@Entry,SizeOf(Entry));
       Entry.dwSize:= SizeOf(Entry);
       if Process32First(Snapshot,Entry) then
       begin
          repeat
             try
                proclist[proccant].tpdPID:= Entry.th32ProcessID;
                proclist[proccant].tpdEXE:= strPas(Entry.szExeFile);
                proclist[proccant].tpdDIR:= GetFileNameByProcessID(Entry.th32ProcessID);
                proclist[proccant].tpdWCOUNT:= 0;
                //AStrings.Add('['+IntToStr(Entry.th32ProcessID)+'] ['+strPas(Entry.szExeFile)+'] ['+GetFileNameByProcessID(Entry.th32ProcessID)+']');
             except
                proclist[proccant].tpdPID:= Entry.th32ProcessID;
                proclist[proccant].tpdEXE:= strPas(Entry.szExeFile);
                proclist[proccant].tpdWCOUNT:= 0;
                //AStrings.Add('['+IntToStr(Entry.th32ProcessID)+'] ['+strPas(Entry.szExeFile)+']');
             end;
             ZeroMemory(@Entry, SizeOf(Entry));
             Entry.dwSize:= SizeOf(Entry);
             inc(proccant);
          until not Process32Next(Snapshot,Entry);
       end;
    finally
       CloseHandle(Snapshot)
    end;
end;

procedure EnumAllw32Processes();
begin
   EnumProcesses();
   EnumWindows(@EnumWindowsProc,0);
end;

initialization
   PsapiLib := 0;

finalization
   DonePsapiLib();

end.


