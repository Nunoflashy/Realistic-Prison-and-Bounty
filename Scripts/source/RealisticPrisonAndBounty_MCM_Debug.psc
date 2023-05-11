Scriptname RealisticPrisonAndBounty_MCM_Debug hidden

import RealisticPrisonAndBounty_Util
import RealisticPrisonAndBounty_MCM
import PO3_SKSEFunctions

bool function ShouldHandleEvent(RealisticPrisonAndBounty_MCM mcm) global
    return mcm.CurrentPage == "Debug"
endFunction

function Render(RealisticPrisonAndBounty_MCM mcm) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    float bench = StartBenchmark()
    mcm.SetCursorFillMode(mcm.TOP_TO_BOTTOM)
    Left(mcm)

    mcm.SetCursorPosition(1)
    Right(mcm)

    HandleDependencies(mcm)

    EndBenchmark(bench, mcm.CurrentPage + " page loaded -")
endFunction

function Left(RealisticPrisonAndBounty_MCM mcm) global
    mcm.AddOptionCategory("Jail")
    int holdIndex = 0
    while (holdIndex < mcm.config.Holds.Length)
        string hold = mcm.config.Holds[holdIndex]
        string city = mcm.config.GetCityNameFromHold(hold)
        mcm.AddOptionTextKey("Teleport to " + city + " Jail Cell", "TeleportJailCell" + hold, "Click to Test")
        holdIndex += 1
    endWhile

    mcm.AddOptionCategory("Outfits")
    int i = 1
    while (i <= mcm.OUTFIT_COUNT)
        string outfitId = "Outfit " + i
        string outfitName = mcm.GetOptionInputValue(outfitId + "::Name", "Clothing")
        mcm.AddOptionTextKey(string_if(outfitName == "", outfitId, outfitName), outfitId, "Click to Test")
        i += 1
    endWhile
    mcm.AddEmptyOption()
    mcm.AddOptionMenuKey("Test Condition For Hold", "OutfitCondition", "Whiterun")
endFunction

function Right(RealisticPrisonAndBounty_MCM mcm) global
    
endFunction

function HandleDependencies(RealisticPrisonAndBounty_MCM mcm) global

endFunction

function HandleSliderOptionDependency(RealisticPrisonAndBounty_MCM mcm, string option, float value) global

endFunction

function LoadSliderOptions(RealisticPrisonAndBounty_MCM mcm, string option, float currentSliderValue) global

endFunction

; =====================================================
; Events
; =====================================================

function OnOptionHighlight(RealisticPrisonAndBounty_MCM mcm, string option) global
    mcm.Trace("OnOptionHighlight", "Option: " + option)
endFunction

function OnOptionDefault(RealisticPrisonAndBounty_MCM mcm, string option) global
    
endFunction

function OnOptionSelect(RealisticPrisonAndBounty_MCM mcm, string option) global
    string optionKey = mcm.CurrentPage + "::" + option

    if (IsSelectedOption(option, "Outfit"))
        string outfitId = GetOptionNameNoCategory(option) ; Outfit 1, Outfit 2 ...
        string testHold = mcm.GetOptionMenuValue("Outfits::OutfitCondition")
        ; int outfitMinBounty = mcm.config.GetOutfitMinimumBounty(outfitId)
        ; int outfitMaxBounty = mcm.config.GetOutfitMaximumBounty(outfitId)

        ; mcm.Debug("OnOptionSelect", "outfitMinBounty: " + outfitMinBounty + ", outfitMaxBounty: " + outfitMaxBounty)

        if (!mcm.config.Debug_OutfitMeetsCondition(mcm.config.GetFaction(testHold), outfitId))
            string outfitName = mcm.GetOptionInputValue(outfitId + "::Name", "Clothing")
            Debug.MessageBox(outfitId + " (" + outfitName + ") does not meet the condition to be worn in " + testHold)
            return
        endif

        ; Call wear method for the specified outfit
        mcm.config.WearOutfit(outfitId)
        return
    
    elseif (IsSelectedOption(option, "TeleportJailCell"))
        string hold = StringUtil.Substring(option, StringUtil.Find(option, "TeleportJailCell") + 16)
        ObjectReference jailCellRef = mcm.config.GetRandomJailMarker(hold)
        mcm.config.Player.MoveTo(jailCellRef)
    endif

    mcm.ToggleOption(optionKey)
    HandleDependencies(mcm)
endFunction

function OnOptionSliderOpen(RealisticPrisonAndBounty_MCM mcm, string option) global
    float sliderOptionValue = mcm.GetOptionSliderValue(option)
    LoadSliderOptions(mcm, option, sliderOptionValue)
    mcm.Trace("OnOptionSliderOpen", "Option: " + option + ", Value: " + sliderOptionValue)
endFunction

function OnOptionSliderAccept(RealisticPrisonAndBounty_MCM mcm, string option, float value) global
    string formatString = "{0}"

    ; Handle any slider option that depends on the current option being set
    HandleSliderOptionDependency(mcm, option, value)

    mcm.SetOptionSliderValue(option, value, formatString)
endFunction

function OnOptionMenuOpen(RealisticPrisonAndBounty_MCM mcm, string option) global
    if (IsSelectedOption(option, "OutfitCondition"))
        mcm.SetMenuDialogOptions(mcm.config.Holds)
        mcm.SetMenuDialogDefaultIndex(GetOptionIndexFromKey(mcm.config.Holds, "Whiterun"))
    endif
endFunction

function OnOptionMenuAccept(RealisticPrisonAndBounty_MCM mcm, string option, int menuIndex) global
    if (IsSelectedOption(option, "OutfitCondition"))
        if (menuIndex != -1)
            mcm.SetOptionMenuValue(option, mcm.config.Holds[menuIndex])
        endif
    endif
endFunction

function OnOptionColorOpen(RealisticPrisonAndBounty_MCM mcm, string option) global
    
endFunction

function OnOptionColorAccept(RealisticPrisonAndBounty_MCM mcm, string option, int color) global
    
endFunction

function OnOptionInputOpen(RealisticPrisonAndBounty_MCM mcm, string option) global
    string inputOptionValue = mcm.GetOptionInputValue(option)
    mcm.SetInputDialogStartText(inputOptionValue)

    mcm.Trace("OnOptionInputOpen", "GetOptionInputValue("+  option +") = " + mcm.GetOptionInputValue(option, mcm.CurrentPage))
endFunction

function OnOptionInputAccept(RealisticPrisonAndBounty_MCM mcm, string option, string inputValue) global

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
