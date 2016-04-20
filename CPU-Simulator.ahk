;;;:;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;       CPU Simulator       ;;
;;        Version 1.1        ;;
;;   written in Autohotkey   ;;
;;          by t-vk          ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#SingleInstance off
SetBatchLines -1

;User Interface:

;Background Image, Default EditBox Color
Gui, Add, Picture, x0 y0, bg.jpg
Gui, Color,, 000000

;TrayBar Options
Menu, Tray, NoStandard
Menu, Tray, Add, About, About, Pn
Menu, Tray, Add, Beenden, GuiClose, Pn
Menu, Tray, Add
Menu, Tray, Click, 1

;Menu Bar
Menu, Sub1, Add, &Speichern..., Save
Menu, Sub1, Add, &Laden..., Load
Menu, Sub1, Add, &Beenden, GuiClose
Menu, MyMenuBar, Add, Datei, :Sub1

Menu, Sub2, Add, &Hilfe öffnen, Help
Menu, Sub2, Add, &About, About
Menu, MyMenuBar, Add, Hilfe, :Sub2

Gui, Menu, MyMenuBar

;Memory, Line Numbers etc
Gui, font, s16 cFFFFFF, Lucida Console
Gui, Add, Edit, x820 y10 w32 h616 Right -VScroll, 1`n2`n3`n4`n5`n6`n7`n8`n9`n10`n11`n12`n13`n14`n15`n16`n17`n18`n19`n20`n21`n22`n23`n24`n25`n26`n27`n28`n29
FileRead, Example, Beispielcode.txt
Gui, Add, Edit, x850 y10 w140 h616 vMemory gMemory -VScroll, %Example%
Gui, Add, Edit, x820 y624 w32 h70 Right -VScroll, 30`n31`n32
Gui, Add, Edit, x850 y624 w140 h70 -VScroll, TASTATUR`nBILDSCHIRM`n...

;Startbutton etc
Gui, font, s8 cFFFFFF, MS Comic Sans
Gui, Add, Button, x10 y660 w100 vStart gStart, Programm ausführen
Gui, Add, Button, x282 y660 w100 gCancel, Programm abbrechen
Gui, Add, Slider, x112 y660 w100 h32 ToolTip vSpeed Range1-10, 2
Gui, font, s25 cFFFFFF, MS Comic Sans
Gui, Add, Edit, -VScroll x214 y660 w66 h32 vStartAddress
Gui, Add, UpDown, x112 y660 w100 h32 Range1-29, 1

;Akkumulator, Screen etc
Gui, font, s45 cFFFFFF, Lucida Console
Gui, Add, Edit, x26 y24 w373 h218 -VScroll vScreen, 
Gui, Add, Edit, x159 y310 w202 h53 -VScroll Center vAK, 
Gui, Add, Edit, x159 y427 w202 h53 -VScroll Center vAE,
Gui, Add, Edit, x159 y545 w202 h53 -VScroll Center vES, 

;Moving Data Box
Gui, font, s20 cFFFFFF, MS Comic Sanas
Gui, Add, Text, x770 y-333 w53 h25 -VScroll Center +BackgroundTrans vDataBox, 111

Gui, Show, h700 w1000, CPU Simulator
GuiControl, Focus, Start

ForceCancel := false
Return

About:
    MsgBox, Entwickelt von t-vk (2013).`nAls Antwort auf Ulmicosi.
Return

Help:
    If FileExist("Hilfe.txt")
        Run, Hilfe.txt
    Else
        MsgBox, Die Hilfe ist nicht verfügbar.
Return

~^s::
If !WinActive("CPU Simulator")
    Return
Save:
    FileSelectFile, File, S 24,,, *.txt
    If ERRORLEVEL
        Return
    StringSplit, FF, File, .
    If (FF%FF0% != "txt")
        File .= ".txt"
    GuiControlGet, Memory
    If FileExist(File)
    {
        FileDelete, %File%
        If ERRORLEVEL
        {
            MsgBox, "%File%" konnte nicht überschrieben werden!
            Return
        }
    }
    FileAppend, %Memory%, %File%
    If ERRORLEVEL
        MsgBox, Die Datei konnte nicht korrekt gespeichert werden!
Return

~^l::
If !WinActive("CPU Simulator")
    Return
Load:
    FileSelectFile, File, 1,,, *.txt
    If ERRORLEVEL
        Return
    FileRead, Content, %File%
    GuiControl,, Memory, %Content%
Return

;Prevent the user from changing the akku, screen etc
~LButton::
    Sleep, 10
    GuiControlGet, currentFocus, Focus
    If (currentFocus = "Edit1" || currentFocus = "Edit3" || currentFocus = "Edit4" || currentFocus = "Edit6" || currentFocus = "Edit7" || currentFocus = "Edit8" || currentFocus = "Edit9" )
        GuiControl, Focus, Start
Return

Cancel:
    ForceCancel := true
    ;TrayTip, CPU Simulator, Programm-Abbruch eingeleitet...
Return

Reset() {
    Global
    GuiControl,, Memory, %memoryBackup%
    GuiControl,, AK,
    GuiControl,, AE,
    GuiControl,, ES,
    TrayTip, CPU Simulator, Programm Erfolgreich beendet!
}

F1::
    MoveDataBox("MemToAK","2")
    MoveDataBox("MemToAE","+3")
    MoveDataBox("SCRToAE","+3")
    MoveDataBox("AEToES","5")
    MoveDataBox("ESToAK","5")
    MoveDataBox("AKToSCR","5")
    MoveDataBox("SCRToAK","5")
    MoveDataBox("AKToMem","5")
Return

GuiClose:
    ExitApp
Return

Memory:
    GuiControlGet, Memory
    StringSplit, LinesB, Memory, `n
    If (LinesB0 < 29)
    {
        AllLines := ""
        Loop, 28
        {
            If (A_Index <= LinesB0)
                AllLines .= LinesB%A_Index%
            AllLines .= "`n"
        }
        GuiControl,, Memory, %AllLines%
        SendInput, {CTRL DOWN}{END}{CTRL UP}
    }
    If (LinesB0 > 29)
    {
        AllLines := ""
        Failed := false
        Loop, %LinesB0%
        {
            If (A_Index < 30)
                AllLines .= LinesB%A_Index%
            If (A_Index < 29)
                AllLines .= "`n"
            If (A_Index > 29 && LinesB%A_Index% != "" && LinesB%A_Index% != "`n" && LinesB%A_Index% != " ")
            {
                Failed := true
                Break
            }
        }
        If (!Failed)
        {
            GuiControl,, Memory, %AllLines%
            SendInput, {CTRL DOWN}{END}{CTRL UP}
        }
        Else
        {
            TrayTip, CPU Simulator, Du hast das Zeilenlimit von 29 überschritten`, das Programm kann so nicht ausgeführt werden. Die Zeilennummerierung ist in diesem zustand auf Grund der Verschiebung verfälscht.
            GuiControl, +VSCROLL, Memory
        }
    }
    
Return

Start:
    TrayTip
    GuiControl,, Screen,
    ForceCancel := false
    GuiControlGet, Memory
    memoryBackup := Memory
    StringSplit, Lines, Memory, `n
    If (Lines0 > 29)
    {
        MsgBox, Es sind nur 29 Speicheraddressen verfügbar!
        Return
    }
    ii = 0
    Loop
    {
        ii++
        If (A_Index = 1)
        {
            GuiControlGet, StartAddress
            ii := StartAddress
        }
        If (ii > 29)
        {
            MsgBox, Das Programm wurde nicht korrekt beendet.
            Break
        }
        If (ii >= StartAddress)
        {
            UnmarkAllAddresses()
            GuiControlGet, Memory
            StringSplit, Lines, Memory, `n
            MarkAddress(ii)
            CurrentLine := Lines%ii%
            StringSplit, CommandPart, CurrentLine, %A_Space%
            If GetSpeed() = 900
            {
                If (CommandPart1 = "END")
                    MsgBox, %CommandPart1%
                Else
                    MsgBox, %CommandPart1% %CommandPart2%
            }
            ;Assembler Syntax
            If (CommandPart1 = "LDA")
            {
                If (CommandPart2 = 30)
                {
                    TrayTip, CPU Simulator, Drücke eine beliebige Taste...
                    Input, SingleKey, L1
                    CommandPart2 := Asc(SingleKey)
                }
                Else If (CommandPart2 < 61 && CommandPart2 > 30)
                {
                    GuiControlGet, Screen
                    StringSplit, CharsS, Screen
                    screenAddressTemp := CommandPart2-30
                    CommandPart2 := Asc(CharsS%screenAddressTemp%)
                    MoveDataBox("SCRToAK",CommandPart2)
                }
                Else If (CommandPart2 < 30 && CommandPart2 > 0)
                {
                    CommandPart2 := Lines%CommandPart2%
                    MoveDataBox("MemToAK",CommandPart2)
                }
                GuiControl,, AK, %CommandPart2%
            }
            Else If (CommandPart1 = "LAI")
            {
                CommandPart2 := Lines%CommandPart2%
                If (CommandPart2 = 30)
                {
                    TrayTip, CPU Simulator, Drücke eine beliebige Taste...
                    Input, SingleKey, L1
                    CommandPart2 := Asc(SingleKey)
                }
                Else If (CommandPart2 < 61 && CommandPart2 > 30)
                {
                    GuiControlGet, Screen
                    StringSplit, CharsS, Screen
                    screenAddressTemp := CommandPart2-30
                    CommandPart2 := Asc(CharsS%screenAddressTemp%)
                    MoveDataBox("SCRToAK",CommandPart2)
                }
                Else If (CommandPart2 < 30 && CommandPart2 > 0)
                {
                    CommandPart2 := Lines%CommandPart2%
                    MoveDataBox("MemToAK",CommandPart2)
                }
                GuiControl,, AK, %CommandPart2%
            }
            Else If (CommandPart1 = "STA")
            {
                AkkuToAddress(CommandPart2)
            }
            Else If (CommandPart1 = "SAI")
            {
                NewAddress := Lines%CommandPart2%
                AkkuToAddress(NewAddress)
            }
            Else If (CommandPart1 = "ADD")
            {
                GuiControlGet, AK
                MoveDataBox("AKToAE",AK)
                GuiControl,, AE, %AK%%A_Space%%A_Space%
                If (AK = "")
                {
                    MsgBox, Es muss zunächst ein Wert in den Akkumulator geladen werden, um eine Addition durchzuführen!
                    Break
                }
                If (CommandPart2 < 61 && CommandPart2 > 30)
                {
                    GuiControlGet, Screen
                    StringSplit, CharsS, Screen
                    screenAddressTemp := CommandPart2-30
                    CommandPart2 := Asc(CharsS%screenAddressTemp%)
                    MoveDataBox("SCRToAE","+" . CommandPart2)
                }
                Else If (CommandPart2 < 30 && CommandPart2 > 0)
                {
                    CommandPart2 := Lines%CommandPart2%
                    MoveDataBox("MemToAE","+" . CommandPart2)
                }
                AddToAkku(CommandPart2)
            }
            Else If (CommandPart1 = "SUB")
            {
                GuiControlGet, AK
                MoveDataBox("AKToAE",AK)
                GuiControl,, AE, %AK%%A_Space%%A_Space%
                If (AK = "")
                {
                    MsgBox, Es muss zunächst ein Wert in den Akkumulator geladen werden, um eine Subtraktion durchzuführen!
                    Break
                }
                If (CommandPart2 < 61 && CommandPart2 > 30)
                {
                    GuiControlGet, Screen
                    StringSplit, CharsS, Screen
                    screenAddressTemp := CommandPart2-30
                    CommandPart2 := Asc(CharsS%screenAddressTemp%)
                    MoveDataBox("SCRToAE","-" . CommandPart2)
                }
                Else If (CommandPart2 < 30 && CommandPart2 > 0)
                {
                    CommandPart2 := Lines%CommandPart2%
                    MoveDataBox("MemToAE","-" . CommandPart2)
                }
                SubtractFromAkku(CommandPart2)
            }
            Else If (CommandPart1 = "JMP")
            {
                ii := CommandPart2-1
            }
            Else If (CommandPart1 = "JIN")
            {
                GuiControlGet, AK
                If (AK < 0)
                    ii := CommandPart2-1
            }
            Else If (CommandPart1 = "JIP")
            {
                GuiControlGet, AK
                If (AK > 0)
                    ii := CommandPart2-1
            }
            Else If (CommandPart1 = "JEZ")
            {
                GuiControlGet, AK
                If (AK = 0)
                    ii := CommandPart2-1
            }
            Else If (CommandPart1 = "JNZ")
            {
                GuiControlGet, AK
                If (AK != 0)
                    ii := CommandPart2-1
            }
            Else If (CommandPart1 = "END")
            {
                ;UnmarkAllAddresses()
                Reset()
                Break
            }
        }
        If ForceCancel
        {
            ;UnmarkAllAddresses()
            Reset()
            ;MsgBox, Programm erfolgreich abgebrochen!
            ForceCancel := false
            Break
        }
    }
Return

GetSpeed()
{
    GuiControlGet, Speed
    If (Speed = 10)
        Return 0
    Speed := (10-Speed)*100
    Return Speed
}

SubtractFromAkku(Value)
{
    GuiControlGet, AK
    GuiControl,, AE, % AK . "-" . Value
    Sleep, % GetSpeed()/2
    AK -= Value
    MoveDataBox("AEToES",AK)
    GuiControl,, ES, %AK%
    GuiControl,, AE
    MoveDataBox("ESToAK",AK)
    GuiControl,, AK, %AK%
}

AddToAkku(Value)
{
    GuiControlGet, AK
    GuiControl,, AE, % AK . "+" . Value
    Sleep, % GetSpeed()/2
    AK += Value
    MoveDataBox("AEToES",AK)
    GuiControl,, ES, %AK%
    GuiControl,, AE
    MoveDataBox("ESToAK",AK)
    GuiControl,, AK, %AK%
}

AkkuToAddress(Address)
{
    If (Address < 1)
    {
        MsgBox, Die Adresse kann nicht kleiner als 1 sein!
        Return
    }
    Else If (Address = 30)
    {
        MsgBox, Dei Adresse 30 ist für Tastatureingaben vorgesehen!
        Return
    }
    Else If (Address > 60)
    {
        MsgBox, Dei Adresse kann nicht größer als 60 sein!
        Return
    }
    Else If (Address > 0 && Address < 30)
    {
        GuiControlGet, AK
        GuiControlGet, Memory
        StringSplit, LinesA, Memory, `n
        MoveDataBox("AKToMem",AK)
        Loop, 29
        {
            If (LinesA%A_Index% = "")
                LinesA%A_Index% := " "
            If (A_Index = Address)
                result .= AK
            Else
                result .= LinesA%A_Index%
                
            If (A_Index != 29)
                result .= "`n"
        }
        GuiControl,, Memory, %result%
    }
    Else If (Address > 30 && Address < 61)
    {
        GuiControlGet, AK
        GuiControlGet, Screen
        StringSplit, Chars, Screen
        MoveDataBox("AKToSCR",AK)
        Loop, 30
        {
            If (Chars%A_Index% = "")
                Chars%A_Index% := " "
            If (A_Index+30 = Address)
                result .= chr(AK)
            Else
                result .= Chars%A_Index%
            GuiControl,, Screen, %result%
        }       
    }
}

MarkAddress(Address)
{
    GuiControlGet, Memory
    StringSplit, LinesC, Memory, `n
    
    Loop, %LinesC0%
    {
        If (A_Index = Address)
        {
            result .= ">" . LinesC%A_Index% . "<"
        }
        Else
            result .= LinesC%A_Index%
        If (A_Index != 29)
            result .= "`n"
    }
    GuiControl,, Memory, %result%
    Sleep, % GetSpeed()
}

UnmarkAllAddresses()
{
    GuiControlGet, Memory
    StringReplace, Memory, Memory, >, , All
    StringReplace, Memory, Memory, <, , All
    GuiControl,, Memory, %Memory%
}

MoveDataBox(Way,Value)
{
    GuiControl,, DataBox, %Value%
    If (Way = "MemToAK")
    {
        xPos := 770
        yPos := 120
        GuiControl, Move, DataBox, % "x" xPos "y" yPos
        Sleep, % GetSpeed()/6
        Loop
        {
            xPos -= 10-GetSpeed()/100+5
            GuiControl, Move, DataBox, % "x" xPos
            If (xPos <= 467)
            {
                GuiControl, Move, DataBox, % "x" 467
                Break
            }
            If (GetSpeed() != 0)
                Sleep, GetSpeed()/100
        }
        Loop
        {
            yPos += 10-GetSpeed()/100+5
            GuiControl, Move, DataBox, % "y" yPos
            If (yPos >= 325)
            {
                GuiControl, Move, DataBox, % "y" 325
                Break
            }
            If (GetSpeed() != 0)
                Sleep, GetSpeed()/100
        }
        Loop
        {
            xPos -= 10-GetSpeed()/100+5
            GuiControl, Move, DataBox, % "x" xPos
            If (xPos <= 412)
            {
                GuiControl, Move, DataBox, % "x" 412
                Break
            }
            If (GetSpeed() != 0)
                Sleep, GetSpeed()/100
        }
    }
    Else If (Way = "AKToMem")
    {
        xPos := 412
        yPos := 325
        GuiControl, Move, DataBox, % "x" xPos "y" yPos
        Sleep, % GetSpeed()/6
        Loop
        {
            xPos += 10-GetSpeed()/100+5
            GuiControl, Move, DataBox, % "x" xPos
            If (xPos >= 467)
            {
                GuiControl, Move, DataBox, % "x" 467
                Break
            }
            If (GetSpeed() != 0)
                Sleep, GetSpeed()/100
        }
        
        Loop
        {
            yPos -= 10-GetSpeed()/100+5
            GuiControl, Move, DataBox, % "y" yPos
            If (yPos <= 120)
            {
                GuiControl, Move, DataBox, % "y" 120
                Break
            }
            If (GetSpeed() != 0)
                Sleep, GetSpeed()/100
        }

        Loop
        {
            xPos += 10-GetSpeed()/100+5
            GuiControl, Move, DataBox, % "x" xPos
            If (xPos >= 770)
            {
                GuiControl, Move, DataBox, % "x" 765
                Break
            }
            If (GetSpeed() != 0)
                Sleep, GetSpeed()/100
        }
    }
    Else If (Way = "AKToSCR")
    {
        xPos := 412
        yPos := 325
        GuiControl, Move, DataBox, % "x" xPos "y" yPos
        Sleep, % GetSpeed()/6
        Loop
        {
            xPos += 10-GetSpeed()/100+5
            GuiControl, Move, DataBox, % "x" xPos
            If (xPos >= 467)
            {
                GuiControl, Move, DataBox, % "x" 467
                Break
            }
            If (GetSpeed() != 0)
                Sleep, GetSpeed()/100
        }
        
        Loop
        {
            yPos -= 10-GetSpeed()/100+5
            GuiControl, Move, DataBox, % "y" yPos
            If (yPos <= 120)
            {
                GuiControl, Move, DataBox, % "y" 120
                Break
            }
            If (GetSpeed() != 0)
                Sleep, GetSpeed()/100
        }

        Loop
        {
            xPos -= 10-GetSpeed()/100+5
            GuiControl, Move, DataBox, % "x" xPos
            If (xPos <= 412)
            {
                GuiControl, Move, DataBox, % "x" 412
                Break
            }
            If (GetSpeed() != 0)
                Sleep, GetSpeed()/100
        }
    }
    Else If (Way = "SCRToAK")
    {
        xPos := 412
        yPos := 120
        GuiControl, Move, DataBox, % "x" xPos "y" yPos
        Sleep, % GetSpeed()/6
        Loop
        {
            xPos += 10-GetSpeed()/100+5
            GuiControl, Move, DataBox, % "x" xPos
            If (xPos >= 467)
            {
                GuiControl, Move, DataBox, % "x" 467
                Break
            }
            If (GetSpeed() != 0)
                Sleep, GetSpeed()/100
        }
        
        Loop
        {
            yPos += 10-GetSpeed()/100+5
            GuiControl, Move, DataBox, % "y" yPos
            If (yPos >= 325)
            {
                GuiControl, Move, DataBox, % "y" 325
                Break
            }
            If (GetSpeed() != 0)
                Sleep, GetSpeed()/100
        }

        Loop
        {
            xPos -= 10-GetSpeed()/100+5
            GuiControl, Move, DataBox, % "x" xPos
            If (xPos <= 412)
            {
                GuiControl, Move, DataBox, % "x" 412
                Break
            }
            If (GetSpeed() != 0)
                Sleep, GetSpeed()/100
        }
    }
    Else If (Way = "SCRToAE")
    {
        xPos := 412
        yPos := 120
        GuiControl, Move, DataBox, % "x" xPos "y" yPos
        Sleep, % GetSpeed()/6
        Loop
        {
            xPos += 10-GetSpeed()/100+5
            GuiControl, Move, DataBox, % "x" xPos
            If (xPos >= 467)
            {
                GuiControl, Move, DataBox, % "x" 467
                Break
            }
            If (GetSpeed() != 0)
                Sleep, GetSpeed()/100
        }
        
        Loop
        {
            yPos += 10-GetSpeed()/100+5
            GuiControl, Move, DataBox, % "y" yPos
            If (yPos >= 440)
            {
                GuiControl, Move, DataBox, % "y" 440
                Break
            }
            If (GetSpeed() != 0)
                Sleep, GetSpeed()/100
        }

        Loop
        {
            xPos -= 10-GetSpeed()/100+5
            GuiControl, Move, DataBox, % "x" xPos
            If (xPos <= 412)
            {
                GuiControl, Move, DataBox, % "x" 412
                Break
            }
            If (GetSpeed() != 0)
                Sleep, GetSpeed()/100
        }
    }
    If (Way = "MemToAE")
    {
        xPos := 770
        yPos := 120
        GuiControl, Move, DataBox, % "x" xPos "y" yPos
        Sleep, % GetSpeed()/6
        Loop
        {
            xPos -= 10-GetSpeed()/100+5
            GuiControl, Move, DataBox, % "x" xPos
            If (xPos <= 467)
            {
                GuiControl, Move, DataBox, % "x" 467
                Break
            }
            If (GetSpeed() != 0)
                Sleep, GetSpeed()/100
        }
        Loop
        {
            yPos += 10-GetSpeed()/100+5
            GuiControl, Move, DataBox, % "y" yPos
            If (yPos >= 440)
            {
                GuiControl, Move, DataBox, % "y" 440
                Break
            }
            If (GetSpeed() != 0)
                Sleep, GetSpeed()/100
        }
        Loop
        {
            xPos -= 10-GetSpeed()/100+5
            GuiControl, Move, DataBox, % "x" xPos
            If (xPos <= 412)
            {
                GuiControl, Move, DataBox, % "x" 412
                Break
            }
            If (GetSpeed() != 0)
                Sleep, GetSpeed()/100
        }
    }
    Else If (Way = "ESToAK")
    {
        xPos := 412
        yPos := 561
        GuiControl, Move, DataBox, % "x" xPos "y" yPos
        Sleep, % GetSpeed()/6
        Loop
        {
            xPos += 10-GetSpeed()/100+5
            GuiControl, Move, DataBox, % "x" xPos
            If (xPos >= 467)
            {
                GuiControl, Move, DataBox, % "x" 467
                Break
            }
            If (GetSpeed() != 0)
                Sleep, GetSpeed()/100
        }
        
        Loop
        {
            yPos -= 10-GetSpeed()/100+5
            GuiControl, Move, DataBox, % "y" yPos
            If (yPos <= 325)
            {
                GuiControl, Move, DataBox, % "y" 325
                Break
            }
            If (GetSpeed() != 0)
                Sleep, GetSpeed()/100
        }

        Loop
        {
            xPos -= 10-GetSpeed()/100+5
            GuiControl, Move, DataBox, % "x" xPos
            If (xPos <= 412)
            {
                GuiControl, Move, DataBox, % "x" 412
                Break
            }
            If (GetSpeed() != 0)
                Sleep, GetSpeed()/100
        }
    }
    Else If (Way = "AKToAE")
    {
        Sleep, % GetSpeed()/4
        GuiControl, Move, DataBox, % "x" 235 "y" 383
    }
    Else If (Way = "AEToES")
    {
        Sleep, % GetSpeed()/4
        GuiControl, Move, DataBox, % "x" 235 "y" 501
    }
    
    Sleep, % GetSpeed()/3
    GuiControl, Move, DataBox, % "y" -333
}