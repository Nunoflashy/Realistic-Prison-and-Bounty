Scriptname RealisticPrisonAndBounty_MCM_Undress hidden

import RealisticPrisonAndBounty_Util

string function GetPageName() global
    return "Undressing"
endFunction

bool function ShouldHandleEvent(RealisticPrisonAndBounty_MCM mcm) global
    return mcm.CurrentPage == GetPageName()
endFunction

function Render(RealisticPrisonAndBounty_MCM mcm) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    mcm.SetCursorFillMode(mcm.TOP_TO_BOTTOM)
    Left(mcm)

    mcm.SetCursorPosition(1)
    Right(mcm)
endFunction

function RenderOptions(RealisticPrisonAndBounty_MCM mcm, int index) global
    mcm.oid_undressing_allow[index]                         = mcm.AddToggleOption("Allow Undressing", true)
    mcm.oid_undressing_minimumBounty[index]                 = mcm.AddSliderOption("Minimum Bounty to Undress", 1.0)
    mcm.oid_undressing_whenDefeated[index]                  = mcm.AddToggleOption("Undress when Defeated", true)
    mcm.oid_undressing_atCell[index]                        = mcm.AddToggleOption("Undress at Cell", true)
    mcm.oid_undressing_atChest[index]                       = mcm.AddToggleOption("Undress at Chest", true)
    mcm.oid_undressing_forcedUndressingMinBounty[index]     = mcm.AddSliderOption("Forced Undressing (Minimum Bounty)", 1.0)  ; -1 to Disable
    mcm.oid_undressing_forcedUndressingWhenDefeated[index]  = mcm.AddToggleOption("Forced Undressing when Defeated", true)
    mcm.oid_undressing_stripSearchThoroughness[index]       = mcm.AddSliderOption("Strip Search Thoroughness", 1.0) ; -1 to Disable
    mcm.oid_undressing_allowWearingClothes[index]           = mcm.AddToggleOption("Allow Wearing Clothes", true)
    mcm.oid_undressing_redressBounty[index]                 = mcm.AddSliderOption("Bounty to Redress", 1.0)  ; -1 to Disable
    mcm.oid_undressing_redressWhenDefeated[index]           = mcm.AddToggleOption("Redress when Defeated", true)
    mcm.oid_undressing_redressAtCell[index]                 = mcm.AddToggleOption("Redress at Cell", true)
    mcm.oid_undressing_redressAtChest[index]                = mcm.AddToggleOption("Redress at Chest", true)
endFunction

function Left(RealisticPrisonAndBounty_MCM mcm) global
    string[] holds = mcm.GetHoldNames()

    int i = mcm.LeftPanelIndex
    while (i < mcm.LeftPanelSize)
        mcm.AddHeaderOption(holds[i])
        RenderOptions(mcm, i)
        i+=1
    endWhile
endFunction

function Right(RealisticPrisonAndBounty_MCM mcm) global
    string[] holds = mcm.GetHoldNames()

    int i = mcm.RightPanelIndex
    while (i < mcm.RightPanelSize)
        mcm.AddHeaderOption(holds[i])
        RenderOptions(mcm, i)
        i+=1
    endWhile
endFunction


; Events

function OnOptionHighlight(RealisticPrisonAndBounty_MCM mcm, int oid, int index) global
    string[] holds = mcm.GetHoldNames()

    if (oid == mcm.oid_undressing_allow[index])
        mcm.SetInfoText("Determines if you can be undressed in " + holds[index] + ".")
        Log(mcm, "Undressing::OnHighlight", "Option = " + oid)
    elseif (oid == mcm.oid_undressing_minimumBounty[index])
        mcm.SetInfoText("The minimum bounty required to be undressed in " + holds[index] + ".")
        Log(mcm, "Undressing::OnHighlight", "Option = " + oid)
    elseif (oid == mcm.oid_undressing_whenDefeated[index])
        mcm.SetInfoText("Whether to have the player undressed when defeated.")
        Log(mcm, "Undressing::OnHighlight", "Option = " + oid)
    elseif (oid == mcm.oid_undressing_atCell[index])
        mcm.SetInfoText("Should the undressing take place at the cell?")
        Log(mcm, "Undressing::OnHighlight", "Option = " + oid)
    elseif (oid == mcm.oid_undressing_atChest[index])
        mcm.SetInfoText("Should the undressing take place at the chest?")
        Log(mcm, "Undressing::OnHighlight", "Option = " + oid)
    elseif (oid == mcm.oid_undressing_forcedUndressingMinBounty[index])
        mcm.SetInfoText("The bounty required to be force undressed (the player will have no possibility of action)")  
        Log(mcm, "Undressing::OnHighlight", "Option = " + oid)
    elseif (oid == mcm.oid_undressing_forcedUndressingWhenDefeated[index])
        mcm.SetInfoText("Force undress when defeated.")
        Log(mcm, "Undressing::OnHighlight", "Option = " + oid)
    elseif (oid == mcm.oid_undressing_stripSearchThoroughness[index])
        mcm.SetInfoText("The thoroughness of the strip search when undressed, higher values mean a more thorough search and possibly less items kept.\n" + \
                        "Due to the nature of a strip search, most items are removed, this value will only determine small objects such as Lockpicks, Keys, Rings, etc...")
        Log(mcm, "Undressing::OnHighlight", "Option = " + oid)
    elseif (oid == mcm.oid_undressing_allowWearingClothes[index])
        mcm.SetInfoText("Whether to allow wearing clothes in prison after being undressed.")
        Log(mcm, "Undressing::OnHighlight", "Option = " + oid)
    elseif (oid == mcm.oid_undressing_redressBounty[index])
        mcm.SetInfoText("The maximum bounty to have the player be redressed.")
        Log(mcm, "Undressing::OnHighlight", "Option = " + oid)
    elseif (oid == mcm.oid_undressing_redressWhenDefeated[index])
        mcm.SetInfoText("Whether to redress the player when defeated (Note: If the bounty exceeds the maximum, this has no effect if enabled, the player will still be undressed).")
        Log(mcm, "Undressing::OnHighlight", "Option = " + oid)
    elseif (oid == mcm.oid_undressing_redressAtCell[index])
        mcm.SetInfoText("Should the player be redressed at the cell?")
        Log(mcm, "Undressing::OnHighlight", "Option = " + oid)
    elseif (oid == mcm.oid_undressing_redressAtChest[index])
        mcm.SetInfoText("Should the player be redressed at the chest?")
        Log(mcm, "Undressing::OnHighlight", "Option = " + oid)
    endif
endFunction

function OnOptionDefault(RealisticPrisonAndBounty_MCM mcm, int oid, int index) global
    
endFunction

function OnOptionSelect(RealisticPrisonAndBounty_MCM mcm, int oid, int index) global
    
endFunction

function OnOptionSliderOpen(RealisticPrisonAndBounty_MCM mcm, int oid, int index) global

endFunction

function OnOptionSliderAccept(RealisticPrisonAndBounty_MCM mcm, int oid, float value, int index) global
    
endFunction

function OnOptionMenuOpen(RealisticPrisonAndBounty_MCM mcm, int oid, int index) global

endFunction

function OnOptionMenuAccept(RealisticPrisonAndBounty_MCM mcm, int oid, int menuIndex, int itemIndex) global
    
endFunction

function OnOptionColorOpen(RealisticPrisonAndBounty_MCM mcm, int oid, int index) global
    
endFunction

function OnOptionColorAccept(RealisticPrisonAndBounty_MCM mcm, int oid, int color, int index) global
    
endFunction

function OnOptionInputOpen(RealisticPrisonAndBounty_MCM mcm, int oid, int index) global
    
endFunction

function OnOptionInputAccept(RealisticPrisonAndBounty_MCM mcm, int oid, string input, int index) global
    
endFunction

function OnOptionKeymapChange(RealisticPrisonAndBounty_MCM mcm, int oid, int keyCode, string conflictControl, string conflictName, int index) global
    
endFunction



function OnHighlight(RealisticPrisonAndBounty_MCM mcm, int oid) global

    if (! ShouldHandleEvent(mcm))
        return
    endif

    int i = 0
    while (i < mcm.GetHoldCount())
        OnOptionHighlight(mcm, oid, i)
        i += 1
    endWhile
endFunction

function OnDefault(RealisticPrisonAndBounty_MCM mcm, int oid) global

    if (! ShouldHandleEvent(mcm))
        return
    endif

    int i = 0
    while (i < mcm.GetHoldCount())
        OnOptionDefault(mcm, oid, i)
        i += 1
    endWhile
endFunction

function OnSelect(RealisticPrisonAndBounty_MCM mcm, int oid) global

    if (! ShouldHandleEvent(mcm))
        return
    endif

    int i = 0
    while (i < mcm.GetHoldCount())
        OnOptionSelect(mcm, oid, i)
        i += 1
    endWhile
endFunction

function OnSliderOpen(RealisticPrisonAndBounty_MCM mcm, int oid) global

    if (! ShouldHandleEvent(mcm))
        return
    endif

    int i = 0
    while (i < mcm.GetHoldCount())
        OnOptionSliderOpen(mcm, oid, i)
        i += 1
    endWhile
endFunction

function OnSliderAccept(RealisticPrisonAndBounty_MCM mcm, int oid, float value) global

    if (! ShouldHandleEvent(mcm))
        return
    endif

    int i = 0
    while (i < mcm.GetHoldCount())
        OnOptionSliderAccept(mcm, oid, value, i)
        i += 1
    endWhile
endFunction

function OnMenuOpen(RealisticPrisonAndBounty_MCM mcm, int oid) global

    if (! ShouldHandleEvent(mcm))
        return
    endif

    int i = 0
    while (i < mcm.GetHoldCount())
        OnOptionMenuOpen(mcm, oid, i)
        i += 1
    endWhile
endFunction

function OnMenuAccept(RealisticPrisonAndBounty_MCM mcm, int oid, int menuIndex) global

    if (! ShouldHandleEvent(mcm))
        return
    endif

    int i = 0
    while (i < mcm.GetHoldCount())
        OnOptionMenuAccept(mcm, oid, menuIndex, i)
        i += 1
    endWhile
endFunction

function OnColorOpen(RealisticPrisonAndBounty_MCM mcm, int oid) global

    if (! ShouldHandleEvent(mcm))
        return
    endif

    int i = 0
    while (i < mcm.GetHoldCount())
        OnOptionColorOpen(mcm, oid, i)
        i += 1
    endWhile
endFunction

function OnColorAccept(RealisticPrisonAndBounty_MCM mcm, int oid, int color) global

    if (! ShouldHandleEvent(mcm))
        return
    endif

    int i = 0
    while (i < mcm.GetHoldCount())
        OnOptionColorAccept(mcm, oid, color, i)
        i += 1
    endWhile
endFunction

function OnKeymapChange(RealisticPrisonAndBounty_MCM mcm, int oid, int keycode, string conflictControl, string conflictName) global
    
    if (! ShouldHandleEvent(mcm))
        return
    endif

    int i = 0
    while (i < mcm.GetHoldCount())
        OnOptionKeymapChange(mcm, oid, keycode, conflictControl, conflictName, i)
        i += 1
    endWhile
endFunction

function OnInputOpen(RealisticPrisonAndBounty_MCM mcm, int oid) global

    if (! ShouldHandleEvent(mcm))
        return
    endif

    int i = 0
    while (i < mcm.GetHoldCount())
        OnOptionInputOpen(mcm, oid, i)
        i += 1
    endWhile
endFunction

function OnInputAccept(RealisticPrisonAndBounty_MCM mcm, int oid, string inputValue) global

    if (! ShouldHandleEvent(mcm))
        return
    endif
    
    int i = 0
    while (i < mcm.GetHoldCount())
        OnOptionInputAccept(mcm, oid, inputValue, i)
        i += 1
    endWhile
endFunction