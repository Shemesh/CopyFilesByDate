#SingleInstance force
#NoEnv
#Warn
SendMode Input 
SetWorkingDir %A_ScriptDir%

sourceFolder := % A_Desktop "\XXX"
destinationFolder := % A_Desktop "\target"
folderFormat = yyyy-MM-dd

TestFilesExist(sourceFolder, destinationFolder, folderFormat)
MsgBox, 260, copy, Would you like to copy?
IfMsgBox No
    ExitApp
IfMsgBox Yes
{
    Gui, Destroy
    resultCopy := CopyFiles(sourceFolder, destinationFolder, folderFormat)
    MsgBox % resultCopy.successCount " files copied`n" resultCopy.errorCount " files not copied"
    IfMsgBox OK
        ExitApp
}

TestFilesExist(srcF, dstF, folF)
{
    Gui, Add, ListView, r20 w700, file|Size|folder name|result
    Loop, Files, %srcF%\*.*, R
    {
        msg =
        FormatTime, formatedTime, %A_LoopFileTimeCreated%, %folF%
        tFolder := dstF . "\" . formatedTime
        tFile := tFolder . "\" . A_LoopFileName
        if !FileExist(tFolder)
            msg = folder not exist
        else if FileExist(tFile)
            msg = file exist
        else
            msg = file not exist
        
        LV_Add("", A_LoopFileName, A_LoopFileSizeKB, formatedTime, msg)
    }
    LV_ModifyCol()
    Gui, Show
    return
}

CopyFiles(srcF, dstF, folF)
{
    errorCount = 0
    successCount = 0
    Gui, Add, ListView, r20 w700, Name|Size|formatedTime|msg
    Loop, Files, %srcF%\*.*, R
    {
        msg =
        FormatTime, formatedTime, %A_LoopFileTimeCreated%, %folF%
        tfolder := dstF . "\" . formatedTime
        FileCreateDir, %tfolder%
        FileCopy, %A_LoopFileLongPath%, %tfolder%, 0
        if ErrorLevel
        {
            msg = could NOT copy %A_LoopFileFullPath% into %dstF%.
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
