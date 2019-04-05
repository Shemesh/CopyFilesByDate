#SingleInstance force
#NoEnv
#Warn
SendMode Input 
SetWorkingDir %A_ScriptDir%

sourceFolder := % A_Desktop "\XXX"
destinationFolder := % A_Desktop "\target"
folderFormat = yyyy-MM-dd
notExistArr := []

Gui Add, Text, x41 y20 w120 h20 +0x200 , From folder
Gui Add, Edit, x120 y20 w250 h20 vSourceFolderEdit, %sourceFolder%
Gui Add, Button, x416 y20 w80 h20 gDoBrowseSource vButBrowseSource, browse
Gui Add, Text, x41 y50 w120 h20 +0x200 , To folder
Gui Add, Edit, x120 y50 w250 h20 vDestinationFolderEdit, %destinationFolder%
Gui Add, Button, x416 y50 w80 h20 gDoBrowseDest vButBrowseDest, browse
Gui Add, Text, x40 y80 w120 h20 +0x200 , Date format
Gui Add, Edit, x120 y80 w181 h20, %folderFormat%
Gui Add, Button, x41 y110 w80 h20 gDoGo, GO
Gui Add, ListView, x40 y160 w469 h141 +LV0x4000, file|Size|folder name|result
LV_ModifyCol(1, 70)
LV_ModifyCol(2, 70)
LV_ModifyCol(3, 70)
LV_ModifyCol(4, 150)
Gui Show, w1022 h544, Window
return

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
    TestFilesExist()
    if notExistArr.Length() < 1
    {
        MsgBox, nothing
        return
    }
    MsgBox, 260, copy, Would you like to copy?
    IfMsgBox Yes
    {
        resultCopy := CopyFiles()
        MsgBox % resultCopy.successCount " files copied`n" resultCopy.errorCount " files not copied"
   }
return

TestFilesExist()
{
    global notExistArr := []
    global sourceFolder
    global destinationFolder
    global folderFormat
    LV_Delete()
    
    Loop, Files, %sourceFolder%\*.*, R
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
        
        LV_Add("", A_LoopFileName, A_LoopFileSizeKB, formatedTime, msg)
    }
    return
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
            msg = Success
        }
        SplitPath, filePath, fileName
        FileGetSize, fileSize, filePath
        LV_Add("", fileName, fileSize, formatedTime, msg)
    }
    return {errorCount: errorCount, successCount: successCount}
}
