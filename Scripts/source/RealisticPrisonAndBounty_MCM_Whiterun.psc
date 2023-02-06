Scriptname RealisticPrisonAndBounty_MCM_Whiterun hidden

import RealisticPrisonAndBounty_Util

string function GetPageName() global
    return "Whiterun"
endFunction

bool function ShouldHandleEvent(RealisticPrisonAndBounty_MCM mcm) global
    return true
    return mcm.CurrentPage == GetPageName()
endFunction

function Render(RealisticPrisonAndBounty_MCM mcm) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    mcm.SetCursorFillMode(mcm.TOP_TO_BOTTOM)
    RenderOptionsLeft(mcm)
    ; Left(mcm)

    mcm.SetCursorPosition(1)
    ; Right(mcm)
    RenderOptionsRight(mcm)
endFunction

function RenderOptions(RealisticPrisonAndBounty_MCM mcm, int index) global
    mcm.AddOptionToggle("Allow Undressing",                 mcm.UNDRESSING_DEFAULT_ALLOW, index)
    mcm.AddOptionSlider("Minimum Bounty to Undress",        mcm.UNDRESSING_DEFAULT_MIN_BOUNTY, index)
    mcm.AddOptionToggle("Undress when Defeated",            mcm.UNDRESSING_DEFAULT_WHEN_DEFEATED, index)
    mcm.AddOptionToggle("Undress at Cell",                  mcm.UNDRESSING_DEFAULT_AT_CELL, index)
    mcm.AddOptionToggle("Undress at Chest",                 mcm.UNDRESSING_DEFAULT_AT_CHEST, index)
    mcm.AddOptionSlider("Forced Undressing (Bounty)",       mcm.UNDRESSING_DEFAULT_FORCED_MIN_BOUNTY, index)
    mcm.AddOptionToggle("Forced Undressing when Defeated",  mcm.UNDRESSING_DEFAULT_FORCED_WHEN_DEFEATED, index)
    mcm.AddOptionSlider("Strip Search Thoroughness",        mcm.UNDRESSING_DEFAULT_STRIP_THOROUGHNESS, index)
endFunction

function RenderOptionsLeft(RealisticPrisonAndBounty_MCM mcm) global
    mcm.AddHeaderOption("Arrest")
    mcm.AddOptionSlider("Minimum Bounty to Arrest",                         mcm.ARREST_DEFAULT_MIN_BOUNTY)
    mcm.AddOptionSlider("Guaranteed Payable Bounty",                        mcm.ARREST_DEFAULT_GUARANTEED_PAYABLE_BOUNTY)
    mcm.AddOptionSlider("Maximum Payable Bounty",                           mcm.ARREST_DEFAULT_MAXIMUM_PAYABLE_BOUNTY)
    mcm.AddOptionSlider("Additional Bounty when Resisting (% of Bounty)",   mcm.ARREST_DEFAULT_BOUNTY_WHEN_RESISTING_PERCENT)
    mcm.AddOptionSlider("Additional Bounty when Resisting (Flat)",          mcm.ARREST_DEFAULT_BOUNTY_WHEN_RESISTING_FLAT)
    mcm.AddOptionSlider("Additional Bounty when Defeated (% of Bounty)",    mcm.ARREST_DEFAULT_BOUNTY_WHEN_DEFEATED_PERCENT)
    mcm.AddOptionSlider("Additional Bounty when Defeated (Flat)",           mcm.ARREST_DEFAULT_BOUNTY_WHEN_DEFEATED_FLAT)
    mcm.AddOptionToggle("Allow Civilian Capture",                           mcm.ARREST_DEFAULT_ALLOW_CIVILIAN_CAPTURE)
    mcm.AddOptionToggle("Allow Arrest Transfer",                            mcm.ARREST_DEFAULT_ALLOW_ARREST_TRANSFER)
    mcm.AddOptionToggle("Allow Unconscious Arrest",                         mcm.ARREST_DEFAULT_ALLOW_UNCONSCIOUS_ARREST)
    mcm.AddOptionSlider("Unequip Hand Garments (Minimum Bounty)",           mcm.ARREST_DEFAULT_UNEQUIP_HAND_BOUNTY)
    mcm.AddOptionSlider("Unequip Head Garments (Minimum Bounty)",           mcm.ARREST_DEFAULT_UNEQUIP_HEAD_BOUNTY)
    mcm.AddOptionSlider("Unequip Foot Garments (Minimum Bounty)",           mcm.ARREST_DEFAULT_UNEQUIP_FOOT_BOUNTY)
    
    mcm.AddHeaderOption("Frisking")
    mcm.AddOptionToggle("Allow Frisk Search",                     mcm.FRISKING_DEFAULT_ALLOW)
    mcm.AddOptionSlider("Minimum Bounty for Frisking",            mcm.FRISKING_DEFAULT_MIN_BOUNTY)
    mcm.AddOptionSlider("Guaranteed Payable Bounty",              mcm.FRISKING_DEFAULT_GUARANTEED_PAYABLE_BOUNTY)
    mcm.AddOptionSlider("Maximum Payable Bounty",                 mcm.FRISKING_DEFAULT_MAXIMUM_PAYABLE_BOUNTY)
    mcm.AddOptionSlider("Maximum Payable Bounty (Chance)",        mcm.FRISKING_DEFAULT_MAXIMUM_PAYABLE_BOUNTY_CHANCE)
    mcm.AddOptionSlider("Frisk Search Thoroughness",              mcm.FRISKING_DEFAULT_FRISK_THOROUGHNESS)
    mcm.AddOptionToggle("Confiscate Stolen Items",                mcm.FRISKING_DEFAULT_CONFISCATE_ITEMS)
    mcm.AddOptionToggle("Strip Search if Stolen Items Found",     mcm.FRISKING_DEFAULT_STRIP_IF_STOLEN_FOUND)
    mcm.AddOptionSlider("Minimum No. of Stolen Items Required",   mcm.FRISKING_DEFAULT_NUMBER_STOLEN_ITEMS_REQUIRED)

    mcm.AddHeaderOption("Release")
    mcm.AddOptionToggle("Give items back on Release",        mcm.ARREST_DEFAULT_ALLOW_CIVILIAN_CAPTURE)
    mcm.AddOptionSlider("Give items back on Release (Bounty)",               mcm.ARREST_DEFAULT_BOUNTY_WHEN_DEFEATED_FLAT)
    mcm.AddOptionToggle("Re-dress on Release",        mcm.ARREST_DEFAULT_ALLOW_CIVILIAN_CAPTURE)

    mcm.AddEmptyOption()
    mcm.AddEmptyOption()
    mcm.AddHeaderOption("Bounty Hunting")
    mcm.AddOptionToggle("Enable Bounty Hunters",        mcm.ARREST_DEFAULT_ALLOW_CIVILIAN_CAPTURE)
    mcm.AddOptionToggle("Allow Outlaw Bounty Hunters",  mcm.ARREST_DEFAULT_ALLOW_ARREST_TRANSFER)
    mcm.AddOptionSlider("Minimum Bounty",               mcm.ARREST_DEFAULT_BOUNTY_WHEN_DEFEATED_FLAT)
    mcm.AddOptionSlider("Bounty (Posse)",               mcm.ARREST_DEFAULT_BOUNTY_WHEN_DEFEATED_FLAT)

endFunction

function RenderOptionsRight(RealisticPrisonAndBounty_MCM mcm) global
    mcm.AddHeaderOption("Prison")
    mcm.AddOptionSlider("Bounty to Days",               mcm.ARREST_DEFAULT_BOUNTY_WHEN_DEFEATED_FLAT)
    mcm.AddOptionSlider("Minimum Sentence (Days)",               mcm.ARREST_DEFAULT_BOUNTY_WHEN_DEFEATED_FLAT)
    mcm.AddOptionSlider("Maximum Sentence (Days)",               mcm.ARREST_DEFAULT_BOUNTY_WHEN_DEFEATED_FLAT)
    mcm.AddOptionToggle("Allow Bountyless Imprisonment",        mcm.ARREST_DEFAULT_ALLOW_CIVILIAN_CAPTURE)
    mcm.AddOptionToggle("Sentence pays Bounty",        mcm.ARREST_DEFAULT_ALLOW_CIVILIAN_CAPTURE)
    mcm.AddOptionToggle("Fast Forward",        mcm.ARREST_DEFAULT_ALLOW_CIVILIAN_CAPTURE)
    mcm.AddOptionSlider("Day to fast forward from",               mcm.ARREST_DEFAULT_BOUNTY_WHEN_DEFEATED_FLAT)
    mcm.AddOptionToggle("Hands Bound in Prison",        mcm.ARREST_DEFAULT_ALLOW_CIVILIAN_CAPTURE)
    mcm.AddOptionSlider("Hands Bound (Minimum Bounty)",               mcm.ARREST_DEFAULT_BOUNTY_WHEN_DEFEATED_FLAT)
    mcm.AddOptionToggle("Hands Bound (Randomize)",        mcm.ARREST_DEFAULT_ALLOW_CIVILIAN_CAPTURE)
    mcm.AddOptionMenu("Cell Lock Level", mcm.PRISON_DEFAULT_CELL_LOCK_LEVEL)

    mcm.AddEmptyOption()
    mcm.AddEmptyOption()
    mcm.AddHeaderOption("Undressing")
    mcm.AddOptionToggle("Allow Undressing",                 mcm.UNDRESSING_DEFAULT_ALLOW)
    mcm.AddOptionSlider("Minimum Bounty to Undress",        mcm.UNDRESSING_DEFAULT_MIN_BOUNTY)
    mcm.AddOptionToggle("Undress when Defeated",            mcm.UNDRESSING_DEFAULT_WHEN_DEFEATED)
    mcm.AddOptionToggle("Undress at Cell",                  mcm.UNDRESSING_DEFAULT_AT_CELL)
    mcm.AddOptionToggle("Undress at Chest",                 mcm.UNDRESSING_DEFAULT_AT_CHEST)
    mcm.AddOptionSlider("Forced Undressing (Bounty)",       mcm.UNDRESSING_DEFAULT_FORCED_MIN_BOUNTY)
    mcm.AddOptionToggle("Forced Undressing when Defeated",  mcm.UNDRESSING_DEFAULT_FORCED_WHEN_DEFEATED)
    mcm.AddOptionSlider("Strip Search Thoroughness",        mcm.UNDRESSING_DEFAULT_STRIP_THOROUGHNESS)
    mcm.AddOptionToggle("Allow Wearing Clothes",            mcm.CLOTHING_DEFAULT_ALLOW_CLOTHES)
    mcm.AddOptionToggle("When Defeated",                    mcm.CLOTHING_DEFAULT_REDRESS_WHEN_DEFEATED)
    mcm.AddOptionSlider("Maximum Bounty",                   mcm.CLOTHING_DEFAULT_REDRESS_BOUNTY)

    mcm.AddHeaderOption("Escape")
    mcm.AddOptionSlider("Escape Bounty (% of Bounty)",               mcm.ARREST_DEFAULT_BOUNTY_WHEN_DEFEATED_FLAT)
    mcm.AddOptionSlider("Escape Bounty (Flat)",               mcm.ARREST_DEFAULT_BOUNTY_WHEN_DEFEATED_FLAT)
    mcm.AddOptionToggle("Allow Surrendering",        mcm.ARREST_DEFAULT_ALLOW_CIVILIAN_CAPTURE)
    mcm.AddOptionToggle("Frisk Search upon Captured",        mcm.ARREST_DEFAULT_ALLOW_CIVILIAN_CAPTURE)
    mcm.AddOptionToggle("Undress upon Captured",  mcm.ARREST_DEFAULT_ALLOW_ARREST_TRANSFER)

    mcm.AddHeaderOption("Bounty")
    mcm.AddTextOption("", "Bounty Decay", mcm.OPTION_FLAG_DISABLED)
    mcm.AddOptionToggle("Enable Bounty Decay",        mcm.ARREST_DEFAULT_ALLOW_CIVILIAN_CAPTURE)
    mcm.AddOptionToggle("Decay while Imprisoned",  mcm.ARREST_DEFAULT_ALLOW_ARREST_TRANSFER)
    mcm.AddOptionSlider("Bounty Lost (% of Bounty)",               mcm.ARREST_DEFAULT_BOUNTY_WHEN_DEFEATED_FLAT)
    mcm.AddOptionSlider("Bounty Lost (Flat)",               mcm.ARREST_DEFAULT_BOUNTY_WHEN_DEFEATED_FLAT)
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

function OnOptionHighlight(RealisticPrisonAndBounty_MCM mcm, string option) global

    string hold = mcm.CurrentHold

    int optionId = mcm.GetOption(option)

    mcm.Debug("OnOptionHighlight", "Option ID: " + optionId)

    if (option == "Allow Undressing")
        mcm.SetInfoText("Determines if you can be undressed while imprisoned in " + mcm.CurrentPage + ".")

    elseif (option == "Minimum Bounty to Undress")
        mcm.SetInfoText("The minimum bounty required to be undressed in " + mcm.CurrentPage + "'s prison.")

    elseif (option == "Undress when Defeated")
        mcm.SetInfoText("Whether to have you undressed when defeated and imprisoned in " + mcm.CurrentPage + ".")

    elseif (option == "Undress at Cell")
        mcm.SetInfoText("Whether to be undressed at the cell in " + mcm.CurrentPage + "'s prison.")

    elseif (option == "Undress at Chest")
        mcm.SetInfoText("Whether to be undressed at the chest in "  + mcm.CurrentPage + "'s prison.")

    elseif (option == "Forced Undressing (Bounty)")
        mcm.SetInfoText("The minimum bounty required to be force undressed (You will have no possibility of action)")

    elseif (option == "Forced Undressing when Defeated")
        mcm.SetInfoText("Whether to be force undressed when defeated and imprisoned in " + mcm.CurrentPage + ".")

    elseif (option == "Strip Search Thoroughness")
        mcm.SetInfoText("The thoroughness of the strip search when undressed, higher values mean a more thorough search and therefore possibly less items kept.\n" + \
                     "Due to the nature of a strip search, most items will be removed, this value will only determine small objects that could be hidden when stripped bare.")
    endif

    ; Debug(mcm, "OnOptionHighlight", "Expected OID: " + oid, mcm.IS_DEBUG)

endFunction

function OnOptionDefault(RealisticPrisonAndBounty_MCM mcm, string option) global
    
endFunction

function OnOptionSelect(RealisticPrisonAndBounty_MCM mcm, string option) global
    string optionKey = GetPageName() + "::" + option
    mcm.ToggleOption(optionKey)
endFunction

function OnOptionSliderOpen(RealisticPrisonAndBounty_MCM mcm, string option) global

    int sliderOptionValue = mcm.GetOptionSliderValue(option)

    if (option == "Minimum Bounty to Undress")
        mcm.SetSliderOptions(minRange = 1, \
         maxRange = 100000, \
         intervalSteps = 1, \
         defaultValue = mcm.UNDRESSING_DEFAULT_MIN_BOUNTY, \
         startValue = int_if(sliderOptionValue, sliderOptionValue, mcm.UNDRESSING_DEFAULT_MIN_BOUNTY))

    elseif (option == "Forced Undressing (Bounty)")
        mcm.SetSliderOptions(minRange = 1, \
         maxRange = 100000, \
         intervalSteps = 1, \
         defaultValue = mcm.UNDRESSING_DEFAULT_FORCED_MIN_BOUNTY, \
         startValue = int_if(sliderOptionValue, sliderOptionValue, mcm.UNDRESSING_DEFAULT_FORCED_MIN_BOUNTY))
         
    elseif (option == "Strip Search Thoroughness")
        mcm.SetSliderOptions(minRange = 1, \
         maxRange = 10, \
         intervalSteps = 1, \
         defaultValue = mcm.UNDRESSING_DEFAULT_STRIP_THOROUGHNESS, \
         startValue = int_if(sliderOptionValue, sliderOptionValue, mcm.UNDRESSING_DEFAULT_STRIP_THOROUGHNESS))
    endif

endFunction

function OnOptionSliderAccept(RealisticPrisonAndBounty_MCM mcm, string option, float value) global

    ; int minimumBounty                   = mcm.GetOptionInListByOID(mcm.oid_undressing_minimumBounty, oid)
    ; int forcedUndressingMinBounty       = mcm.GetOptionInListByOID(mcm.oid_undressing_forcedUndressingMinBounty, oid)     
    ; int stripSearchThoroughness         = mcm.GetOptionInListByOID(mcm.oid_undressing_stripSearchThoroughness, oid)  
    ; int redressBounty                   = mcm.GetOptionInListByOID(mcm.oid_undressing_redressBounty, oid)

    ; mcm.SetSliderOptionValue(oid, value, string_if(oid == stripSearchThoroughness, "{0}", "{0} Bounty"))
    ; ; if (oid == minimumBounty)
    ; ;     SetOptionValueIntByKey("oid_undressing_minimumBounty" + mcm.CurrentOptionIndex , value as int)
    ; ; elseif (oid == forcedUndressingMinBounty)
    ; ;     SetOptionValueIntByKey("oid_undressing_forcedUndressingMinBounty" + mcm.CurrentOptionIndex , value as int)
    ; ; elseif (oid == stripSearchThoroughness)
    ; ;     SetOptionValueIntByKey("oid_undressing_stripSearchThoroughness" + mcm.CurrentOptionIndex , value as int)
    ; ; elseif (oid == redressBounty)
    ; ;     SetOptionValueIntByKey("oid_undressing_redressBounty" + mcm.CurrentOptionIndex , value as int)
    ; ; endif

    ; SetOptionValueInt(oid, value as int)
    mcm.SetOptionSliderValue(option, value)
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
