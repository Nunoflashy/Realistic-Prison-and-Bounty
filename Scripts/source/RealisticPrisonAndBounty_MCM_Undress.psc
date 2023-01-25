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
    mcm.oid_undressing_redressBounty[index]                 = mcm.AddSliderOption("Bounty to Re-dress", 1.0)  ; -1 to Disable
    mcm.oid_undressing_redressWhenDefeated[index]           = mcm.AddToggleOption("Re-dress when Defeated", true)
    mcm.oid_undressing_redressAtCell[index]                 = mcm.AddToggleOption("Re-dress at Cell", true)
    mcm.oid_undressing_redressAtChest[index]                = mcm.AddToggleOption("Re-dress at Chest", true)
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


; =====================================================
; Events
; =====================================================

function OnOptionHighlight(RealisticPrisonAndBounty_MCM mcm, int oid) global

    string[] holds = mcm.GetHoldNames()
    string hold = holds[mcm.CurrentOptionIndex]

    int allowUndressing                 = mcm.GetOptionInListByOID(mcm.oid_undressing_allow, oid)
    int minimumBounty                   = mcm.GetOptionInListByOID(mcm.oid_undressing_minimumBounty, oid)
    int undressWhenDefeated             = mcm.GetOptionInListByOID(mcm.oid_undressing_whenDefeated, oid)
    int undressAtCell                   = mcm.GetOptionInListByOID(mcm.oid_undressing_atCell, oid)
    int undressAtChest                  = mcm.GetOptionInListByOID(mcm.oid_undressing_atChest, oid)
    int forcedUndressingMinBounty       = mcm.GetOptionInListByOID(mcm.oid_undressing_forcedUndressingMinBounty, oid)     
    int forcedUndressingWhenDefeated    = mcm.GetOptionInListByOID(mcm.oid_undressing_forcedUndressingWhenDefeated, oid)
    int stripSearchThoroughness         = mcm.GetOptionInListByOID(mcm.oid_undressing_stripSearchThoroughness, oid)  
    int allowWearingClothes             = mcm.GetOptionInListByOID(mcm.oid_undressing_allowWearingClothes, oid)
    int redressBounty                   = mcm.GetOptionInListByOID(mcm.oid_undressing_redressBounty, oid)
    int redressWhenDefeated             = mcm.GetOptionInListByOID(mcm.oid_undressing_redressWhenDefeated, oid)
    int redressAtCell                   = mcm.GetOptionInListByOID(mcm.oid_undressing_redressAtCell, oid)
    int redressAtChest                  = mcm.GetOptionInListByOID(mcm.oid_undressing_redressAtChest, oid)


    mcm.SetInfoText( \
        string_if (oid == allowUndressing, "Determines if you can be undressed while imprisoned in " + hold + ".", \
        string_if (oid == minimumBounty, "The minimum bounty required to be undressed in " + hold + "'s prison.", \
        string_if (oid == undressWhenDefeated, "Whether to have you undressed when defeated and imprisoned in " + hold + ".", \
        string_if (oid == undressAtCell, "Whether to be undressed at the cell in " + hold + "'s prison.", \
        string_if (oid == undressAtChest, "Whether to be undressed at the chest in "  + hold + "'prison.", \
        string_if (oid == forcedUndressingMinBounty, "The minimum bounty required to be force undressed (You will have no possibility of action)", \
        string_if (oid == forcedUndressingWhenDefeated, "Whether to be force undressed when defeated and imprisoned in " + hold + ".", \
        string_if (oid == stripSearchThoroughness, "The thoroughness of the strip search when undressed, higher values mean a more thorough search and therefore possibly less items kept.\n" + \
            "Due to the nature of a strip search, most items will be removed, this value will only determine small objects that could be hidden when stripped bare.", \
        string_if (oid == allowWearingClothes, "Whether to allow wearing clothes while imprisoned in " + hold + ".", \
        string_if (oid == redressBounty, "The maximum bounty you can have in order to be re-dressed while imprisoned in " + hold + ".", \
        string_if (oid == redressWhenDefeated, "Whether to have you re-dressed when defeated (Note: If the bounty exceeds the maximum, this option will have no effect.)", \
        string_if (oid == redressAtCell, "Whether to be re-dressed at the cell in " + hold + "'prison.", \
        string_if (oid == redressAtChest, "Whether to be re-dressed at the chest in " + hold + "'prison.", \
        "No description defined for this option." \
        ))))))))))))) \
    )

endFunction

function OnOptionDefault(RealisticPrisonAndBounty_MCM mcm, int oid) global
    
endFunction

function OnOptionSelect(RealisticPrisonAndBounty_MCM mcm, int oid) global

endFunction

function OnOptionSliderOpen(RealisticPrisonAndBounty_MCM mcm, int oid) global

endFunction

function OnOptionSliderAccept(RealisticPrisonAndBounty_MCM mcm, int oid, float value) global

endFunction

function OnOptionMenuOpen(RealisticPrisonAndBounty_MCM mcm, int oid) global

endFunction

function OnOptionMenuAccept(RealisticPrisonAndBounty_MCM mcm, int oid, int menuIndex) global
    
endFunction

function OnOptionColorOpen(RealisticPrisonAndBounty_MCM mcm, int oid) global
    
endFunction

function OnOptionColorAccept(RealisticPrisonAndBounty_MCM mcm, int oid, int color) global
    
endFunction

function OnOptionInputOpen(RealisticPrisonAndBounty_MCM mcm, int oid) global
    
endFunction

function OnOptionInputAccept(RealisticPrisonAndBounty_MCM mcm, int oid, string input) global
    
endFunction

function OnOptionKeymapChange(RealisticPrisonAndBounty_MCM mcm, int oid, int keyCode, string conflictControl, string conflictName) global
    
endFunction

; =====================================================
; Event Handlers
; =====================================================

function OnHighlight(RealisticPrisonAndBounty_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionHighlight(mcm, oid)
endFunction

function OnDefault(RealisticPrisonAndBounty_MCM mcm, int oid) global

    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionDefault(mcm, oid)
endFunction

function OnSelect(RealisticPrisonAndBounty_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionSelect(mcm, oid)
endFunction

function OnSliderOpen(RealisticPrisonAndBounty_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionSliderOpen(mcm, oid)
endFunction

function OnSliderAccept(RealisticPrisonAndBounty_MCM mcm, int oid, float value) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionSliderAccept(mcm, oid, value)
endFunction

function OnMenuOpen(RealisticPrisonAndBounty_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionMenuOpen(mcm, oid)
endFunction

function OnMenuAccept(RealisticPrisonAndBounty_MCM mcm, int oid, int menuIndex) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionMenuAccept(mcm, oid, menuIndex)
endFunction

function OnColorOpen(RealisticPrisonAndBounty_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionColorOpen(mcm, oid)
endFunction

function OnColorAccept(RealisticPrisonAndBounty_MCM mcm, int oid, int color) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionColorAccept(mcm, oid, color)
endFunction

function OnKeymapChange(RealisticPrisonAndBounty_MCM mcm, int oid, int keycode, string conflictControl, string conflictName) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionKeymapChange(mcm, oid, keycode, conflictControl, conflictName)
endFunction

function OnInputOpen(RealisticPrisonAndBounty_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionInputOpen(mcm, oid)
endFunction

function OnInputAccept(RealisticPrisonAndBounty_MCM mcm, int oid, string inputValue) global
    if (! ShouldHandleEvent(mcm))
        return
    endif
    
    OnOptionInputAccept(mcm, oid, inputValue)
endFunction
