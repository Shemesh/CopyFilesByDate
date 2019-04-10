#SingleInstance force
#NoEnv
#Warn
SendMode Input 
SetWorkingDir %A_ScriptDir%

sourceFolder := % A_Desktop "\XXX"
destinationFolder := % A_Desktop "\target"
folderFormat = yyyy-MM-dd
notExistArr := []
extensions := "*"
includeSub := "R"

Gui Add, Text, x40 y20 h20 +0x200, From folder
Gui Add, Edit, x120 y20 w250 h20 vSourceFolderEdit, %sourceFolder%
Gui Add, Button, x380 y20 w80 h20 gDoBrowseSource vButBrowseSource, browse
Gui Add, Text, x40 y50 h20 +0x200, Extensions
Gui Add, Edit, x120 y50 w90 h20 vExtensionsEdit disabled, %extensions%
Gui, Add, Checkbox, x260 y50 h20 Checked1 vSubFoldersChekbox, Include sub Folders
Gui Add, Text, x40 y80 h20 +0x200, To folder
Gui Add, Edit, x120 y80 w250 h20 vDestinationFolderEdit, %destinationFolder%
Gui Add, Button, x380 y80 w80 h20 gDoBrowseDest vButBrowseDest, browse
Gui Add, Text, x40 y110 w120 h20 +0x200, Folder format
Gui Add, Edit, x120 y110 w100 h20 vFolderFormatEdit, %folderFormat%
Gui, Add, Link, x230 y113, <a href="https://autohotkey.com/docs/commands/FormatTime.htm#Date_Formats_case_sensitive">?</a>
Gui Add, Button, x40 y150 w80 h30 gDoGo vGoButton, GO
Gui Add, ListView, x40 y200 w469 h141 +LV0x4000, file name|folder name|result
Gui, Font, s14
Gui,Add, Text, x40 y380 w470 h50 vTextMessage, Jah Bless
Gui, Add, Button, x40 y450 gDoCopy vYeSButton, Yes
LV_ModifyCol(1, 70)
LV_ModifyCol(2, 100)
LV_ModifyCol(3, 150)
GuiControl, Focus, GoButton
GuiControl, Hide, YeSButton
Gui Show, w550 h540, Copy Files by date
Return

GuiEscape:
GuiClose:
    ExitApp

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
        GuiControl,,TextMessage, nothing to do, all files already exist
        return
    }
    else
    {
        GuiControl,,TextMessage, % notExistArr.Length() " files not exist, copy them?"
        GuiControl, Show, YeSButton
    }
return

DoCopy:
    GuiControl, Hide, YeSButton
    resultCopy := CopyFiles()
    notCopied :=
    if resultCopy.errorCount > 0
    {
        notCopied :=  "`n" resultCopy.errorCount " files not copied"
    }
        
    GuiControl,,TextMessage, % resultCopy.successCount " files copied" notCopied
return

TestFilesExist()
{
    global notExistArr := []
    global sourceFolder
    global destinationFolder
    global folderFormat
    global includeSub
    global extensions
    LV_Delete()
    
    Loop, Files, %sourceFolder%\%extensions%, %includeSub%
    {
        msg =
        FormatTime, formatedTime, %A_LoopFileTimeCreated%, %folderFormat%
        tFolder := destinationFolder . "\" . formatedTime
        tFile := tFolder . "\" . A_LoopFileName
        if !FileExist(tFolder)
        {
            msg = target folder not exist
            notExistArr.Push(A_LoopFileLongPath)
        }  
        else if FileExist(tFile)
            msg = file already exist
        else
        {
            msg = file not exist
            notExistArr.Push(A_LoopFileLongPath)
        }
        
        LV_Add("", A_LoopFileName, formatedTime, msg)
    }
}

CopyFiles()
{
    global notExistArr
    global sourceFolder
    global destinationFolder
    global folderFormat
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
            msg = could NOT copy %filePath% into %destinationFolder%.
            errorCount ++
        }
        else
        {
            successCount ++
            msg = Success, file copied
        }
        SplitPath, filePath, fileName
        FileGetSize, fileSize, filePath
        LV_Add("", fileName, formatedTime, msg)
    }
    return {errorCount: errorCount, successCount: successCount}
}
