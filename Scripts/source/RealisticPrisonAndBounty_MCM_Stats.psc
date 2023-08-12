Scriptname RealisticPrisonAndBounty_MCM_Stats hidden

import RealisticPrisonAndBounty_Util
import RealisticPrisonAndBounty_MCM

bool function ShouldHandleEvent(RealisticPrisonAndBounty_MCM mcm) global
    return mcm.CurrentPage == "Stats"
endFunction

function Render(RealisticPrisonAndBounty_MCM mcm) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    float x = StartBenchmark()
    mcm.SetCursorFillMode(mcm.TOP_TO_BOTTOM)
    Left(mcm)

    mcm.SetCursorPosition(1)
    Right(mcm)

    EndBenchmark(x)
endFunction

function Left(RealisticPrisonAndBounty_MCM mcm) global
    int i = 0
    while (i < mcm.config.Holds.Length)
        mcm.AddOptionCategory(mcm.config.Holds[i])
        mcm.AddOptionStat("Current Bounty", 0, "Bounty")
        mcm.AddOptionStat("Largest Bounty", 0, "Bounty")
        mcm.AddOptionStat("Total Bounty", 0, "Bounty")
        mcm.AddOptionStat("Times Arrested", 0, "Times")
        mcm.AddOptionStat("Times Frisked", 0, "Times")
        mcm.AddOptionStat("Fees Owed", 0, "Gold")
        i += 1
    endWhile
endFunction

function Right(RealisticPrisonAndBounty_MCM mcm) global
    int i = 0
    while (i < mcm.config.Holds.Length)
        mcm.SetRenderedCategory(mcm.config.Holds[i])
        mcm.AddHeaderOption("")
        mcm.AddOptionStat("Days Jailed", 0, "Days")
        mcm.AddOptionStat("Longest Sentence", 0, "Days")
        mcm.AddOptionStat("Times Jailed", 0, "Times")
        mcm.AddOptionStat("Times Escaped", 0, "Times")
        mcm.AddOptionStat("Times Stripped", 0, "Times")
        mcm.AddOptionStat("Infamy Gained", 0, "Infamy")
    i += 1
    endWhile
endFunction

; =====================================================
; Events
; =====================================================

function OnOptionHighlight(RealisticPrisonAndBounty_MCM mcm, string option) global

    string optionName   = GetOptionNameNoCategory(option)
    string statNameWithHold = GetOptionCategory(option)
    string formattedStat = StringUtil.Substring(option, StringUtil.Find(statNameWithHold, "]") + 1) 
    string hold         = GetOptionCategory(option)
    string city         = mcm.config.GetCityNameFromHold(hold)
    ; string hold         = miscVars.Get("[Hold["+ city +"]]")
    ; string city         = miscVars.Get("[City["+ hold +"]]")
    mcm.Debug("Stats::OnOptionHighlight", "\n" + \
        "option: " + option + "\n" + \
        "optionName: " + optionName + "\n" + \
        "statNameWithHold: " + statNameWithHold + "\n" + \
        "formattedStat: " + formattedStat + "\n" + \
        "hold: " + hold + "\n" + \
        "city: " + city + "\n" \
    , true)

    if (option == hold + "::Current Bounty")
        mcm.SetInfoText("The bounty you currently have in " + hold + ".")

    elseif (option == hold + "::Largest Bounty")
        mcm.SetInfoText("The largest bounty you've had in " + hold + ".")
    
    elseif (option == hold + "::Total Bounty")
        mcm.SetInfoText("The total bounty you've accumulated in " + hold + ".")

    elseif (option == hold + "::Times Arrested")
        mcm.SetInfoText("The times you have been arrested in " + hold + ".")

    elseif (option == hold + "::Times Frisked")
        mcm.SetInfoText("The times you have been frisk searched in " + city + "'s jail.")

    elseif (option == hold + "::Fees Owed")
        mcm.SetInfoText("The amount of gold you owe in fees to " + hold + ".")

    elseif (option == hold + "::Days Jailed")
        mcm.SetInfoText("The amount of days you have spent in " + city + "'s jail.")

    elseif (option == hold + "::Longest Sentence")
        mcm.SetInfoText("The longest sentence you have been given in " + city + "'s jail.")

    elseif (option == hold + "::Times Jailed")
        mcm.SetInfoText("The times you have been jailed in " + city + ".")

    elseif (option == hold + "::Times Escaped")
        mcm.SetInfoText("The times you have escaped from " + city + "'s jail.")

    elseif (option == hold + "::Times Stripped")
        mcm.SetInfoText("The times you have been stripped off in " + city + "'s jail.")

    elseif (option == hold + "::Infamy Gained")
        mcm.SetInfoText("The infamy you have accumulated over time in " + city + "'s jail.")
    endif

endFunction

function OnOptionDefault(RealisticPrisonAndBounty_MCM mcm, string option) global
    
endFunction

function OnOptionSelect(RealisticPrisonAndBounty_MCM mcm, string option) global
    ; option = Hold::Option (Whiterun::Current Bounty)
    int currentValue = mcm.config.actorVars.Get("[20]" + option)
    mcm.config.actorVars.Set("[20]" + option, currentValue + 1)
    ; if (mcm.IsStatOption(option))
    ;     string hold     = GetOptionCategory(option)
    ;     string statName = GetOptionNameNoCategory(option)
    ;     mcm.config.IncrementStat(hold, statName)
    ;     ; mcm.Debug("OnOptionSelect", "Incrementing Stat: " + hold + "::" + statName + "(option: " + option +")")
    ;     return
    ; endif
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
    
    mcm.Trace(mcm, "Stats::OnHighlght", "Option ID: " + oid)

    
    ; OnOptionHighlight(mcm, mcm.TemporaryGetStatKeyFromOID(oid))
    OnOptionHighlight(mcm, mcm.GetKeyFromOption(oid, false))
endFunction

function OnDefault(RealisticPrisonAndBounty_MCM mcm, int oid) global

    if (! ShouldHandleEvent(mcm))
        return
    endif

    ; OnOptionDefault(mcm, mcm.TemporaryGetStatKeyFromOID(oid))
    ; OnOptionDefault(mcm, mcm.GetKeyFromOption(oid, false))
endFunction

function OnSelect(RealisticPrisonAndBounty_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionSelect(mcm, mcm.GetKeyFromOption(oid, false))
endFunction

function OnSliderOpen(RealisticPrisonAndBounty_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionSliderOpen(mcm, mcm.GetKeyFromOption(oid, false))
endFunction

function OnSliderAccept(RealisticPrisonAndBounty_MCM mcm, int oid, float value) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionSliderAccept(mcm, mcm.GetKeyFromOption(oid, false), value)
endFunction

function OnMenuOpen(RealisticPrisonAndBounty_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionMenuOpen(mcm, mcm.GetKeyFromOption(oid, false))
endFunction

function OnMenuAccept(RealisticPrisonAndBounty_MCM mcm, int oid, int menuIndex) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionMenuAccept(mcm, mcm.GetKeyFromOption(oid, false), menuIndex)
endFunction

function OnColorOpen(RealisticPrisonAndBounty_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionColorOpen(mcm, mcm.GetKeyFromOption(oid, false))
endFunction

function OnColorAccept(RealisticPrisonAndBounty_MCM mcm, int oid, int color) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionColorAccept(mcm, mcm.GetKeyFromOption(oid, false), color)
endFunction

function OnKeymapChange(RealisticPrisonAndBounty_MCM mcm, int oid, int keycode, string conflictControl, string conflictName) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionKeymapChange(mcm, mcm.GetKeyFromOption(oid, false), keycode, conflictControl, conflictName)
endFunction

function OnInputOpen(RealisticPrisonAndBounty_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionInputOpen(mcm, mcm.GetKeyFromOption(oid, false))
endFunction

function OnInputAccept(RealisticPrisonAndBounty_MCM mcm, int oid, string inputValue) global
    if (! ShouldHandleEvent(mcm))
        return
    endif
    
    OnOptionInputAccept(mcm, mcm.GetKeyFromOption(oid, false), inputValue)
endFunction
