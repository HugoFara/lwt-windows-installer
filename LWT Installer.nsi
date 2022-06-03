; -------------------------------
; NSIS Installation program for 
; the community fork of LWT.

; License: MIT
; Author: HugoFara
; Link: https://github.com/hugofara/lwt-windows-installer

; The downloaded files can be found at 
; https://github.com/hugofara/lwt
; -------------------------------
!include MUI2.nsh
!include "StrFunc.nsh"

!define VERSION "0.0.0"
VIFileVersion 0.0.0.0

 
Name "LWT Standalone ${VERSION}"
# set the name of the installer
Outfile "LWT Installer.exe"
ShowInstDetails show

!define MUI_COMPONENTSPAGE_SMALLDESC
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_INSTFILES

!insertmacro MUI_LANGUAGE English

!addplugindir /x86-ansi .\Plugins\x86-ansi 
!addplugindir /x86-unicode .\Plugins\x86-unicode 
!addplugindir /amd64-unicode .\Plugins\amd64-unicode

;AddBrandingImage left 100
;SetBrandingImage favicon.bmp

${StrRep}


;Function customPage
;  GetTempFileName $R0
;  File /oname=$R0 README.md
;  InstallOptions::dialog $R0
;  Pop $R1
;  StrCmp $R1 "cancel" done
;  StrCmp $R1 "back" done
;  StrCmp $R1 "success" done
;  done:
;FunctionEnd

; Replace empty array by empty string in JSON file
Function replace_empty_array
  ; Sqve file content to var
  FileOpen $0 "$TEMP\LWT_Versionn.json" r
  FileRead $0 $R1
  FileRead $0 $R2
  FileRead $0 $R3
  FileRead $0 $R4
  ${StrRep} $R5 $R1 "[]" '[""]'
  ${StrRep} $R6 $R2 "[]" '[""]'
  ${StrRep} $R7 $R3 "[]" '[""]'
  ${StrRep} $R8 $R4 "[]" '[""]'
  FileClose $0
  ; Write the content of $1
  FileOpen $0 "$TEMP\LWT_Version.json" w
  FileWrite $0 $R5
  FileWrite $0 $R6
  FileWrite $0 $R7
  FileWrite $0 $R8
  FileClose $0
FunctionEnd


Function get_lwt_latest_link
  DetailPrint "Getting package metadata from: https://api.github.com/repos/hugofara/lwt/releases/latest..."
  ; Get latest release metadata
  inetc::get \
  "https://api.github.com/repos/hugofara/lwt/releases/latest" \
  "$TEMP\LWT_Versionn.json" /END
  Pop $0 # return value = exit code, "OK" if OK
  StrCmp $0 "OK" dlok
  MessageBox MB_OK|MB_ICONEXCLAMATION "Cannot find the latest version of LWT! Click OK to abort installation" /SD IDOK
  Push ""
  Abort
  dlok:
    ; Check for empty arrays (not supported by nsJSON)
    DetailPrint "Pre-formatting answer..."
    Call replace_empty_array 
    ; Extract the latest version
    ClearErrors
    nsJSON::Set /file "$TEMP\LWT_Version.json"
    
    nsJSON::Get `zipball_url` /END
    ${IfNot} ${Errors}
      Pop $R0
      DetailPrint `Download URL: "$R0"`
      nsJSON::Get `tag_name` /END
      Pop $R1
      DetailPrint `Found LWT version: "$R1"`
      Push $R0
    ${Else}
      ; Don't know how to make more informative nessages
      Abort "Cannot parse the JSON file, aborting..."
      Push ""
    ${EndIf}
FunctionEnd

# create a default section.
Section "LWT from GitHub" LWT_GITHUB
  AddSize 10560
  SetOutPath "./"
  Call get_lwt_latest_link
  Pop $R0
  
  DetailPrint "Downloading LWT..."
  inetc::get \
  $R0 \
  "lwt.zip" /END
    Pop $0 # return value = exit code, "OK" if OK
    MessageBox MB_OK "LWT Download: $0" 
    StrCmp $0 "OK" dlok
    MessageBox MB_OK|MB_ICONEXCLAMATION "Cannot download LWT, click OK to abort installation" /SD IDOK
    Abort
    dlok:
      MessageBox MB_OK "LWT download success!"

SectionEnd

Section /o "MeCab (Japanese Parser)" MECAB
  AddSize 11060
  DetailPrint "Downloading MeCab..."
  ; Try also https://sourceforge.net/projects/mecab/files/latest/download
  inetc::get \
  "https://sourceforge.net/projects/mecab/files/mecab-win32/0.98/mecab-0.98.exe" \
  "mecab.txt" /END
    Pop $0 # return value = exit code, "OK" if OK
    DetailPrint "Status $0"
    StrCmp $0 "OK" dlok
    Abort
    dlok:
      DetailPrint "MeCab download success"

SectionEnd

Section "XAMPP" XAMPP

SectionEnd

; Add translations
LangString LWT_GITHUBDesc ${LANG_ENGLISH} "Download the latest release of LWT from GitHub"
LangString MECABDesc ${LANG_ENGLISH} "An open-source Japanese parser. Highly recommended to learn Japanese"
LangString XAMPPDesc ${LANG_ENGLISH} "A XAMPP server for Windows"

; Link descriptions to translations
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${LWT_GITHUB} $(LWT_GITHUBDesc)
  !insertmacro MUI_DESCRIPTION_TEXT ${MECAB} $(MECABDesc)
  !insertmacro MUI_DESCRIPTION_TEXT ${XAMPP} $(XAMPPDesc)
!insertmacro MUI_FUNCTION_DESCRIPTION_END

;Page custom customPage "" ": custom page"

;PageEx license
;  LicenseText "Readme"
;  LicenseData README.md
;PageExEnd

;PageEx license
;  LicenseData UNLICENSE.md
;  LicenseForceSelection checkbox
;PageExEnd
 
; Install components
Page components
Page instfiles /ENABLECANCEL