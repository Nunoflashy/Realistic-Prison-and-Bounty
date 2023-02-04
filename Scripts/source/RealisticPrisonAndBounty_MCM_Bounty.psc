Scriptname RealisticPrisonAndBounty_MCM_Bounty hidden

import RealisticPrisonAndBounty_Util

string function GetPageName() global
    return "Bounty"
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
    mcm.AddTextOption("", "Stats", mcm.OPTION_FLAG_DISABLED)
    ; mcm.oid_bounty_currentBounty[index] = mcm.AddTextOption("Current Bounty ", 4000.0 as int)
    ; mcm.oid_bounty_largestBounty[index] = mcm.AddTextOption("Largest Bounty ", 15000.0 as int)
    mcm.AddTextOption("Bounty History", 15000.0 as int)
    mcm.AddEmptyOption()

    mcm.AddTextOption("", "Bounty Decay", mcm.OPTION_FLAG_DISABLED)
    mcm.AddOptionToggleEx("Enable Bounty Decay",        mcm.ARREST_DEFAULT_ALLOW_CIVILIAN_CAPTURE, index)
    mcm.AddOptionToggleEx("Decay while Imprisoned",  mcm.ARREST_DEFAULT_ALLOW_ARREST_TRANSFER, index)
    mcm.AddOptionSliderEx("Bounty Lost (% of Bounty)",               mcm.ARREST_DEFAULT_BOUNTY_WHEN_DEFEATED_FLAT, index)
    mcm.AddOptionSliderEx("Bounty Lost (Flat)",               mcm.ARREST_DEFAULT_BOUNTY_WHEN_DEFEATED_FLAT, index)
    
endFunction

function Left(RealisticPrisonAndBounty_MCM mcm) global
    string[] holds = mcm.GetHoldNames()

    mcm.AddOptionToggle("Enable Bounty Decay", true)
    mcm.AddOptionToggle("Update Interval (In-Game Time)", 12.0)
    ; mcm.oid_bounty_enableBountyDecayGeneral = mcm.AddToggleOption("Enable Bounty Decay", true)
    ; mcm.oid_bounty_updateInterval           = mcm.AddSliderOption("Update Interval (In-Game Time)", 1.0)

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

function OnOptionHighlight(RealisticPrisonAndBounty_MCM mcm, string option) global
    string hold = mcm.CurrentHold

    if (option == "Allow Undressing")
        mcm.SetInfoText("Determines if you can be undressed while imprisoned in " + hold + ".")

    elseif (option == "Minimum Bounty to Undress")
        mcm.SetInfoText("The minimum bounty required to be undressed in " + hold + "'s prison.")

    elseif (option == "Undress when Defeated")
        mcm.SetInfoText("Whether to have you undressed when defeated and imprisoned in " + hold + ".")

    elseif (option == "Undress at Cell")
        mcm.SetInfoText("Whether to be undressed at the cell in " + hold + "'s prison.")

    elseif (option == "Undress at Chest")
        mcm.SetInfoText("Whether to be undressed at the chest in "  + hold + "'s prison.")

    elseif (option == "Forced Undressing (Bounty)")
        mcm.SetInfoText("The minimum bounty required to be force undressed (You will have no possibility of action)")

    elseif (option == "Forced Undressing when Defeated")
        mcm.SetInfoText("Whether to be force undressed when defeated and imprisoned in " + hold + ".")

    elseif (option == "Strip Search Thoroughness")
        mcm.SetInfoText("The thoroughness of the strip search when undressed, higher values mean a more thorough search and therefore possibly less items kept.\n" + \
                     "Due to the nature of a strip search, most items will be removed, this value will only determine small objects that could be hidden when stripped bare.")

    elseif (option == "undressing::allowWearingClothes")
        mcm.SetInfoText("Whether to allow wearing clothes while imprisoned in " + hold + ".")

    elseif (option == "undressing::bountyToRe-dress")
        mcm.SetInfoText("The maximum bounty you can have in order to be re-dressed while imprisoned in " + hold + ".")

    elseif (option == "undressing::Re-dressWhenDefeated")
        mcm.SetInfoText("Whether to have you re-dressed when defeated (Note: If the bounty exceeds the maximum, this option will have no effect.)")

    elseif (option == "undressing::Re-dressAtCell")
        mcm.SetInfoText("Whether to be re-dressed at the cell in " + hold + "'prison.")

    elseif (option == "undressing::Re-dressAtChest")
        mcm.SetInfoText("Whether to be re-dressed at the chest in " + hold + "'prison.")
    endif

    ; int currentBounty   = mcm.GetOptionInListByOID(mcm.oid_bounty_currentBounty, oid)
    ; int largestBounty   = mcm.GetOptionInListByOID(mcm.oid_bounty_largestBounty, oid)
    ; int enableBountyDecay   = mcm.GetOptionInListByOID(mcm.oid_bounty_enableBountyDecay, oid)
    ; int decayInPrison       = mcm.GetOptionInListByOID(mcm.oid_bounty_decayInPrison, oid)
    ; int bountyLostPercent   = mcm.GetOptionInListByOID(mcm.oid_bounty_bountyLostPercent, oid)
    ; int bountyLostFlat      = mcm.GetOptionInListByOID(mcm.oid_bounty_bountyLostFlat, oid)

    ; ; mcm.SetInfoText( \
    ; ;     string_if (oid == currentBounty, "Your current bounty in " + holds[mcm.CurrentOptionIndex] + ".", \
    ; ;     string_if (oid == largestBounty, "The largest bounty you acquired in " + holds[mcm.CurrentOptionIndex] + ".", \
    ; ;     string_if (oid == enableBountyDecay, "Whether to enable bounty decaying for " + holds[mcm.CurrentOptionIndex] + ".", \
    ; ;     string_if (oid == decayInPrison, "Whether to allow bounty decaying while imprisoned in " + holds[mcm.CurrentOptionIndex] + ".", \
    ; ;     string_if (oid == bountyLostPercent, "The amount of bounty lost as a percentage of the current bounty in " + holds[mcm.CurrentOptionIndex] + ".", \
    ; ;     string_if (oid == bountyLostFlat, "The amount of bounty lost in " + holds[mcm.CurrentOptionIndex] + ".", \
    ; ;     "No description defined for this property." \
    ; ;     )))))) \
    ; ; )

    ; if (oid == currentBounty)
    ;     mcm.SetInfoText("Your current bounty in " + holds[mcm.CurrentOptionIndex] + ".")
    ; elseif (oid == largestBounty)
    ;     mcm.SetInfoText("The largest bounty you acquired in " + holds[mcm.CurrentOptionIndex] + ".")
    ; elseif (oid == enableBountyDecay)
    ;     mcm.SetInfoText("Whether to enable bounty decaying for " + holds[mcm.CurrentOptionIndex] + ".")
    ; elseif (oid == decayInPrison)
    ;     mcm.SetInfoText("Whether to allow bounty decaying while imprisoned in " + holds[mcm.CurrentOptionIndex] + ".")
    ; elseif (oid == bountyLostPercent)
    ;     mcm.SetInfoText("The amount of bounty lost as a percentage of the current bounty in " + holds[mcm.CurrentOptionIndex] + ".")
    ; elseif (oid == bountyLostFlat)
    ;     mcm.SetInfoText("The amount of bounty lost in " + holds[mcm.CurrentOptionIndex] + ".")
    ; endif

endFunction

function OnOptionDefault(RealisticPrisonAndBounty_MCM mcm, string option) global
    
endFunction

function OnOptionSelect(RealisticPrisonAndBounty_MCM mcm, string option) global
    string optionKey = option

    mcm.ToggleOption(optionKey)
endFunction

function OnOptionSliderOpen(RealisticPrisonAndBounty_MCM mcm, string option) global

endFunction

function OnOptionSliderAccept(RealisticPrisonAndBounty_MCM mcm, string option, float value) global

endFunction

function OnOptionMenuOpen(RealisticPrisonAndBounty_MCM mcm, string option) global

endFunction

function OnOptionMenuAccept(RealisticPrisonAndBounty_MCM mcm, string option, int menuIndex) global
    
endFunction

function OnOptionColorOpen(RealisticPrisonAndBounty_MCM mcm, string option) global
    
endFunction

function OnOptionColorAccept(RealisticPrisonAndBounty_MCM mcm, string option, int color) global
    
endFunction

function OnOptionInputOpen(RealisticPrisonAndBounty_MCM mcm, string option) global
    
endFunction

function OnOptionInputAccept(RealisticPrisonAndBounty_MCM mcm, string option, string input) global
    
endFunction

function OnOptionKeymapChange(RealisticPrisonAndBounty_MCM mcm, string option, int keyCode, string conflictControl, string conflictName) global
    
endFunction

; =====================================================
; Event Handlers
; =====================================================

function OnHighlight(RealisticPrisonAndBounty_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif
    
    mcm.UpdateIndex(oid)
    OnOptionHighlight(mcm, mcm.GetKeyFromOption(oid))
endFunction

function OnDefault(RealisticPrisonAndBounty_MCM mcm, int oid) global

    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionDefault(mcm, mcm.GetKeyFromOption(oid))
endFunction

function OnSelect(RealisticPrisonAndBounty_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionSelect(mcm, mcm.GetKeyFromOption(oid))
endFunction

function OnSliderOpen(RealisticPrisonAndBounty_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionSliderOpen(mcm, mcm.GetKeyFromOption(oid))
endFunction

function OnSliderAccept(RealisticPrisonAndBounty_MCM mcm, int oid, float value) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionSliderAccept(mcm, mcm.GetKeyFromOption(oid), value)
endFunction

function OnMenuOpen(RealisticPrisonAndBounty_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionMenuOpen(mcm, mcm.GetKeyFromOption(oid))
endFunction

function OnMenuAccept(RealisticPrisonAndBounty_MCM mcm, int oid, int menuIndex) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionMenuAccept(mcm, mcm.GetKeyFromOption(oid), menuIndex)
endFunction

function OnColorOpen(RealisticPrisonAndBounty_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionColorOpen(mcm, mcm.GetKeyFromOption(oid))
endFunction

function OnColorAccept(RealisticPrisonAndBounty_MCM mcm, int oid, int color) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionColorAccept(mcm, mcm.GetKeyFromOption(oid), color)
endFunction

function OnKeymapChange(RealisticPrisonAndBounty_MCM mcm, int oid, int keycode, string conflictControl, string conflictName) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionKeymapChange(mcm, mcm.GetKeyFromOption(oid), keycode, conflictControl, conflictName)
endFunction

function OnInputOpen(RealisticPrisonAndBounty_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionInputOpen(mcm, mcm.GetKeyFromOption(oid))
endFunction

function OnInputAccept(RealisticPrisonAndBounty_MCM mcm, int oid, string inputValue) global
    if (! ShouldHandleEvent(mcm))
        return
    endif
    
    OnOptionInputAccept(mcm, mcm.GetKeyFromOption(oid), inputValue)
endFunction
