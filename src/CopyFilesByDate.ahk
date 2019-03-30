#SingleInstance force
#NoEnv
#Warn
SendMode Input 
SetWorkingDir %A_ScriptDir%

sourceFolder := % A_Desktop "\XXX"
destinationFolder := % A_Desktop "\target"
folderFormat = yyyy-MM-dd
notExistArr := []

TestFilesExist()
MsgBox, 260, copy, Would you like to copy?
IfMsgBox No
    ExitApp
IfMsgBox Yes
{
    Gui, Destroy
    resultCopy := CopyFiles()
    MsgBox % resultCopy.successCount " files copied`n" resultCopy.errorCount " files not copied"
    IfMsgBox OK
        ExitApp
}

TestFilesExist()
{
    global notExistArr := []
    global sourceFolder
    global destinationFolder
    global folderFormat
    
    Gui, Add, ListView, r20 w700, file|Size|folder name|result
    
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
    LV_ModifyCol()
    Gui, Show
    return
}

CopyFiles()
{
    global notExistArr
    global sourceFolder
    global destinationFolder
    global folderFormat
    
    errorCount = 0
    successCount = 0
    Gui, Add, ListView, r20 w700, Name|Size|formatedTime|msg    
    
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
        LV_Add("", A_LoopFileName, A_LoopFileSizeKB, formatedTime, msg)
    }
    LV_ModifyCol()
    Gui, Show
    return {errorCount: errorCount, successCount: successCount}
}
