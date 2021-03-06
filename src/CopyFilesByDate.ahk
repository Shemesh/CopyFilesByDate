﻿#SingleInstance force
#NoEnv
#Warn
SendMode Input 
SetWorkingDir %A_ScriptDir%

sourceFolder = ""
destinationFolder = ""
folderFormat = ""
notExistArr = []
extensions = ""
includeSub = ""
LVArray = []

IfNotExist, %A_Temp%\Next_arrow_1559.ico
  FileInstall, Next_arrow_1559.ico, %A_Temp%\Next_arrow_1559.ico, 1
  
IniRead, sourceFolder, %A_Temp%\CopyFilesByDate.ini, data, sourceFolder, % A_Desktop
IniRead, destinationFolder, %A_Temp%\CopyFilesByDate.ini, data, destinationFolder,  % A_Desktop
IniRead, folderFormat, %A_Temp%\CopyFilesByDate.ini, data, folderFormat, yyyy-MM-dd
IniRead, extensions, %A_Temp%\CopyFilesByDate.ini, data, extensions, ALL
IniRead, includeSub, %A_Temp%\CopyFilesByDate.ini, data, includeSub, "R"

subCheck = 1
if includeSub =
    subCheck = 0

Menu, Tray, Icon, %A_Temp%\Next_arrow_1559.ico
Menu, Tray, Tip, Copy files by date
Menu, Tray, NoStandard
Menu, tray, add, Exit, MenuExit
Gui, -MaximizeBox
Gui Add, Text, x40 y20 h20 +0x200, From folder
Gui Add, Edit, x120 y20 w250 h20 vSourceFolderEdit, %sourceFolder%
Gui Add, Button, x380 y20 w80 h20 gDoBrowseSource vButBrowseSource, browse
Gui Add, Text, x40 y50 h20 +0x200, Extensions
Gui Add, Edit, x120 y50 w90 h20 vExtensionsEdit, %extensions%
Gui, Add, Link, x215 y52 vExtensionsHelp, ?
Gui, Add, Checkbox, x260 y50 h20 Checked%subCheck% vSubFoldersChekbox, Include sub folders
Gui Add, Text, x40 y80 h20 +0x200, To folder
Gui Add, Edit, x120 y80 w250 h20 vDestinationFolderEdit, %destinationFolder%
Gui Add, Button, x380 y80 w80 h20 gDoBrowseDest vButBrowseDest, browse
Gui Add, Text, x40 y110 w120 h20 +0x200, Folder format
Gui Add, Edit, x120 y110 w100 h20 vFolderFormatEdit, %folderFormat%
Gui, Add, Link, x225 y113, <a href="https://autohotkey.com/docs/commands/FormatTime.htm#Date_Formats_case_sensitive">?</a>
Gui Add, Button, x40 y150 w80 h30 gDoGo vGoButton, Check
Gui, Add, Link, x530 y5, <a href="https://github.com/Shemesh/CopyFilesByDate">@</a>
Gui Add, Text, x40 y210 h20 +0x200, Find
Gui Add, Edit, x65 y210 w95 h20 vSearchLv gSearchList
Gui, Add, Checkbox, x200 y210 h20 Checked0 vCheckboxLv gSearchList, Show existing
Gui Add, ListView, x40 y235 w469 h141 +LV0x4000 vLV, file name|target folder name|result
Gui, Font, s14
Gui,Add, Text, x40 y400 w470 h50 vTextMessage, Jah Bless
Gui, Add, Button, x40 y480 gDoCopy vYeSButton, Yes
LV_ModifyCol(1, 120)
LV_ModifyCol(2, 120)
LV_ModifyCol(3, 150)
GuiControl, Focus, GoButton
GuiControl, Hide, YeSButton
Gui Show, w550 h540, Copy files by date
OnMessage(0x200, "WM_MOUSEMOVE")
Return

GuiEscape:
GuiClose:
    ExitApp
    
MenuExit:
    ExitApp
return

SearchList:
    GuiControlGet, SearchTerm,, SearchLv
    GuiControlGet, ShowExisting,, CheckboxLv
    GuiControl, -Redraw, LV
    LV_Delete()
    For Each, item In LVArray
    {
       if (ShowExisting > 0 && InStr(item.name, SearchTerm))
       {
            LV_Add("", item.name, item.time, item.message)
       }
       Else if not InStr(item.message, "file exist") && InStr(item.name, SearchTerm)
          LV_Add("", item.name, item.time, item.message)
    }
    GuiControl, +Redraw, LV
Return

DoBrowseSource:
    FileSelectFolder, res, *%sourceFolder%, 0, Select source folder
    if res != 
        GuiControl,,SourceFolderEdit,%res%
return

DoBrowseDest:
    FileSelectFolder, res, *%destinationFolder%, 0, Select destination folder
    if res != 
        GuiControl,,DestinationFolderEdit,%res%
return

DoGo:
    GuiControl,,TextMessage, checking...
    GuiControl, Hide, YeSButton
    GuiControl, +Disabled, GoButton
    
    GuiControlGet, destinationFolder,,DestinationFolderEdit
    GuiControlGet, sourceFolder,,SourceFolderEdit
    GuiControlGet, folderFormat,,FolderFormatEdit
    GuiControlGet, sub,,SubFoldersChekbox
    GuiControlGet, extensions,,ExtensionsEdit
    
    if sub < 1
        includeSub = 
    else
        includeSub = R
        
    TestFilesExist()
    if notExistArr.Length() < 1
    {
        GuiControl,,TextMessage, % LVArray.Length() " files checked`nall files already exist"
    }
    else
    {
        GuiControl,,TextMessage, % LVArray.Length() " files checked`n" notExistArr.Length() " files not exist, copy them?"
        GuiControl, Show, YeSButton
    }
    GuiControl, -Disabled, GoButton
    GoSub SearchList
return

DoCopy:
    GuiControl, Hide, YeSButton
    GuiControl, +Disabled, GoButton
    CopyFiles()
    GuiControl, -Disabled, GoButton
return

WM_MOUSEMOVE(){
	MouseGetPos,,,, OutputVarControl
    tip = ALL (in capital letters) meaning all file types.`notherwise comma seperated file types (no spaces).`nexample: png,txt,jpg

    IfEqual, OutputVarControl, SysLink1
        ToolTip % tip
    else
        ToolTip
}


ObjIndexOf(obj, item, case_sensitive:=false)
{
	for i, val in obj {
		if (case_sensitive ? (val == item) : (val = item))
			return i
	}
}

TestFilesExist()
{
    global notExistArr = []
    global sourceFolder
    global destinationFolder
    global folderFormat
    global includeSub
    global extensions
    global LVArray = []
    
    extArray := StrSplit(extensions, ",")
    
    IniWrite, %sourceFolder%, %A_Temp%\CopyFilesByDate.ini, data, sourceFolder
    IniWrite, %destinationFolder%, %A_Temp%\CopyFilesByDate.ini, data, destinationFolder
    IniWrite, %extensions%, %A_Temp%\CopyFilesByDate.ini, data, extensions
    IniWrite, %folderFormat%, %A_Temp%\CopyFilesByDate.ini, data, folderFormat
    IniWrite, %includeSub%, %A_Temp%\CopyFilesByDate.ini, data, includeSub
        
    LV_Delete()
    GuiControl, -Redraw, LV
    
    Loop, Files, %sourceFolder%\*.*, %includeSub%
    {
        If not ObjIndexOf(extArray, "ALL", true) && not ObjIndexOf(extArray, A_LoopFileExt)
            Continue
            
        msg =
        FormatTime, formatedTime, %A_LoopFileTimeCreated%, %folderFormat%
        tFolder := destinationFolder . "\" . formatedTime
        tFile := tFolder . "\" . A_LoopFileName
        if !FileExist(tFolder)
        {
            msg = ! target folder not exist
            notExistArr.Push(A_LoopFileLongPath)
            LV_Add("", A_LoopFileName, formatedTime, msg)
        } 
        else if FileExist(tFile)
        {
            msg = ✔ file exist
        }
        else
        {
            if FileExistInSub(tFolder, A_LoopFileName)
                msg = ✔ file exist
            else
            {
                msg = ! file not exist
                notExistArr.Push(A_LoopFileLongPath)
                LV_Add("", A_LoopFileName, formatedTime, msg)
            }
        }
        
        LVArray.Push({name:A_LoopFileName, time:formatedTime, message:msg})
    }
    GuiControl, +Redraw, LV
}


FileExistInSub(tFolder, tfile)
{
    Loop, Files, %tFolder%\*.*, DR
    {
        if ( FileExist(A_LoopFileFullPath "\" tfile) ) 
            return true
    }
    return false
}

CopyFiles()
{
    global notExistArr
    global sourceFolder
    global destinationFolder
    global folderFormat
    global LVArray = []
    
    LV_Delete()
    
    errorCount = 0
    successCount = 0
    
    for index, filePath in notExistArr 
    {
        msg =
        FileGetTime, fileCreatedTime , %filePath%, C
        FormatTime, formatedTime, %fileCreatedTime%, %folderFormat%
        tfolder := destinationFolder . "\" . formatedTime
        FileCreateDir, %tfolder%
        FileCopy, %filePath%, %tfolder%, 0
        if ErrorLevel
        {
            msg = ! could NOT copy %filePath% into %destinationFolder%.
            errorCount ++
        }
        else
        {
            successCount ++
            msg = ✔ Success, file copied
        }
        SplitPath, filePath, fileName
        LV_Add("", fileName, formatedTime, msg)
        LVArray.Push({name:fileName, time:formatedTime, message:msg})
        
        notCopied := ""
        if errorCount > 0
        {
            notCopied :=  "`n" errorCount " files not copied"
        }
            
        GuiControl,,TextMessage, % successCount " files copied" notCopied
    }
}
