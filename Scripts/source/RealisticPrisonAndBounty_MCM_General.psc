Scriptname RealisticPrisonAndBounty_MCM_General hidden

import RealisticPrisonAndBounty_Util
import RealisticPrisonAndBounty_MCM

bool function ShouldHandleEvent(RealisticPrisonAndBounty_MCM mcm) global
    return mcm.CurrentPage == "General"
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

function Left(RealisticPrisonAndBounty_MCM mcm) global
    mcm.AddOptionCategory("General")
    mcm.AddOptionSlider("Update Interval", "{0} Hours")
    mcm.AddOptionSlider("Bounty Decay (Update Interval)", "{0} Hours")
    mcm.AddOptionSlider("Infamy Decay (Update Interval)", "{0} Days")

    mcm.AddEmptyOption()
    mcm.AddEmptyOption()

    mcm.AddTextOption("", "WHEN FREE", mcm.OPTION_DISABLED)
    mcm.AddOptionSlider("Timescale", "1:{0}")

    mcm.AddEmptyOption()

    mcm.AddTextOption("", "When Eluding Arrest", mcm.OPTION_DISABLED)
    mcm.AddOptionSliderKey("Guards Warning Time", "Arrest Elude Warning Time", "{0} Seconds")

    mcm.AddEmptyOption()
    mcm.AddEmptyOption() ; maybe

    mcm.AddOptionCategory("Bounty for Actions")
    mcm.AddOptionSlider("Assault", "{0} Bounty",                Game.GetGameSettingInt("iCrimeGoldAttack"))
    mcm.AddOptionSlider("Murder", "{0} Bounty",                 Game.GetGameSettingInt("iCrimeGoldMurder"))
    mcm.AddOptionSlider("Theft", "{1}x Item Worth as Bounty",   Game.GetGameSettingFloat("fCrimeGoldSteal"))
endFunction

function Right(RealisticPrisonAndBounty_MCM mcm) global
    mcm.AddOptionCategoryKey("", "General")
    ; mcm.SetRenderedCategory("General")
    mcm.AddOptionToggleKey("Display Arrest Notifications", "ArrestNotifications")
    mcm.AddOptionToggleKey("Display Jail Notifications", "JailedNotifications")
    mcm.AddOptionToggleKey("Display Bounty Decay Notifications", "BountyDecayNotifications")
    mcm.AddOptionToggleKey("Display Infamy Notifications", "InfamyNotifications")

    mcm.AddEmptyOption()

    mcm.AddTextOption("", "WHEN IN JAIL", mcm.OPTION_DISABLED)
    mcm.AddOptionSliderKey("Timescale", "TimescalePrison", "1:{0}")

    mcm.AddEmptyOption()
    mcm.AddEmptyOption()
    mcm.AddEmptyOption()

    mcm.AddEmptyOption()
    mcm.AddEmptyOption()

    mcm.AddOptionCategory("")
    mcm.SetRenderedCategory("Bounty for Actions")
    mcm.AddOptionSlider("Trespassing", "{0} Bounty",    Game.GetGameSettingInt("iCrimeGoldTrespass"))
    mcm.AddOptionSlider("Pickpocketing", "{0} Bounty", Game.GetGameSettingInt("iCrimeGoldPickpocket"))
    ; mcm.AddOptionSlider("Lockpicking", "{0} Bounty")
    mcm.AddOptionSlider("Stealing Horse", "{0} Bounty", Game.GetGameSettingInt("iCrimeStealHorse")) ; Might have wrong ID for GetGameSettingInt()
    ; mcm.AddOptionSlider("Disturbing the Peace", "{0} Bounty")
endFunction

; =====================================================
; Events
; =====================================================

function OnOptionHighlight(RealisticPrisonAndBounty_MCM mcm, string option) global
    string optionName = GetOptionNameNoCategory(option)

    ; Deleveling Stats
    if (StringUtil.Find(option, "Deleveling") != -1)
        mcm.SetInfoText("Sets how much progress you will lose in " + optionName + " for each day in jail.")

    elseif (option == "General::Timescale")
        int timescaleValue = mcm.GetOptionSliderValue(option) as int
        mcm.SetInfoText("Sets the timescale when free.\nThis is how fast the time passes relative to Real Life.\n1:" + timescaleValue + " means that, for each minute in real life, " + timescaleValue + " minute(s) will pass in-game.")

    elseif (option == "General::TimescalePrison")
        int timescaleValue = mcm.GetOptionSliderValue(option) as int
        mcm.SetInfoText("Sets the timescale when in jail.\nThis is how fast the time passes relative to Real Life.\n1:" + timescaleValue + " means that, for each minute in real life, " + timescaleValue + " minute(s) will pass in-game.")
    
    elseif (option == "General::Bounty Decay (Update Interval)")
        mcm.SetInfoText("Sets the time between updates in in-game hours for when the bounty should decay for all holds.")

    elseif (option == "General::Infamy Decay (Update Interval)")
        mcm.SetInfoText("Sets the time between updates in in-game days for when infamy should be lost over time for all holds that have it enabled.")

    elseif (option == "General::Arrest Elude Warning Time")
        mcm.SetInfoText("Determines the time after pursuit that guards will wait for you to stop and surrender before they consider you as being eluding arrest and start attacking.")
    endif
 
    mcm.Debug("OnOptionHighlight", option + ", find: " + StringUtil.Find(option, "Deleveling") + ", optionName: " + optionName)

endFunction

function OnOptionDefault(RealisticPrisonAndBounty_MCM mcm, string option) global
    
endFunction

function OnOptionSelect(RealisticPrisonAndBounty_MCM mcm, string option) global
    mcm.ToggleOption(option)
endFunction

function LoadSliderOptions(RealisticPrisonAndBounty_MCM mcm, string option, float currentSliderValue) global
    float minRange = 1
    float maxRange = 100
    float intervalSteps = 1
    float defaultValue = mcm.GetOptionDefaultFloat(option)

    ; ==========================================================
    ;                     GENERAL / DELEVELING
    ; ==========================================================

    if (option == "General::Timescale")
        maxRange = 1000

    elseif (option == "General::TimescalePrison")
        maxRange = 1000

    elseif (option == "General::Bounty Decay (Update Interval)")
        minRange = 1
        maxRange = 96 ; 4d

    elseif (option == "General::Infamy Decay (Update Interval)")
        minRange = 1
        maxRange = 30

    elseif (option == "General::Arrest Elude Warning Time")
        minRange = 1
        maxRange = 60

    elseif (option == "Outfit::Item Slot: Underwear (Top)")
        minRange = 0
        maxRange = 100

    elseif (option == "Outfit::Item Slot: Underwear (Bottom)")
        minRange = 0
        maxRange = 100

    elseif (option == "Bounty for Actions::Trespassing")
        minRange = 10
        maxRange = 10000
        intervalSteps = 10

    elseif (option == "Bounty for Actions::Assault")
        minRange = 10
        maxRange = 10000
        intervalSteps = 10

    elseif (option == "Bounty for Actions::Theft")
        minRange = 0.1
        maxRange = 10
        intervalSteps = 0.1

    elseif (option == "Bounty for Actions::Pickpocketing")
        minRange = 10
        maxRange = 10000
        intervalSteps = 10

    elseif (option == "Bounty for Actions::Lockpicking")
        minRange = 10
        maxRange = 10000
        intervalSteps = 10

    elseif (option == "Bounty for Actions::Disturbing the Peace")
        minRange = 10
        maxRange = 10000
        intervalSteps = 10
    endif

    float startValue = float_if (currentSliderValue > mcm.GENERAL_ERROR, currentSliderValue, defaultValue)
    mcm.SetSliderOptions(minRange, maxRange, intervalSteps, defaultValue, startValue)
endFunction

function OnOptionSliderOpen(RealisticPrisonAndBounty_MCM mcm, string option) global
    float sliderOptionValue = mcm.GetOptionSliderValue(option)
    LoadSliderOptions(mcm, option, sliderOptionValue)
    mcm.Debug("OnOptionSliderOpen", "Option: " + option + ", Value: " + sliderOptionValue)
endFunction

function OnOptionSliderAccept(RealisticPrisonAndBounty_MCM mcm, string option, float value) global
    string formatString = "{0}"

    ; ==========================================================
    ;                     GENERAL / DELEVELING
    ; ==========================================================

    if (option == "General::Timescale")
        formatString = "1:{0}"

    elseif (option == "General::TimescalePrison")
        formatString = "1:{0}"

    elseif (option == "General::Update Interval")
        formatString = "{0} Hours"

    elseif (option == "General::Bounty Decay (Update Interval)")
        formatString = "{0} Hours"

    elseif (option == "General::Infamy Decay (Update Interval)")
        formatString = "{0} Days"

    elseif (option == "General::Arrest Elude Warning Time")
        formatString = "{0} Seconds"

    elseif (option == "Outfit::Item Slot: Underwear (Top)")
        formatString = "Slot {0}"

    elseif (option == "Outfit::Item Slot: Underwear (Bottom)")
        formatString = "Slot {0}"

    elseif (option == "Bounty for Actions::Trespassing")
        formatString = "{0} Bounty"

    elseif (option == "Bounty for Actions::Assault")
        formatString = "{0} Bounty"

    elseif (option == "Bounty for Actions::Murder")
        formatString = "{0} Bounty"

    elseif (option == "Bounty for Actions::Theft")
        formatString = "{1}x Item Worth as Bounty"

    elseif (option == "Bounty for Actions::Pickpocketing")
        formatString = "{0} Bounty"

    elseif (option == "Bounty for Actions::Lockpicking")
        formatString = "{0} Bounty"

    elseif (option == "Bounty for Actions::Disturbing the Peace")
        formatString = "{0} Bounty"
    endif

    ; Send option changed event
    mcm.SendModEvent("RPB_SliderOptionChanged", option, value)

    mcm.SetOptionSliderValue(option, value, formatString)
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
    
    OnOptionHighlight(mcm, mcm.GetKeyFromOption(oid, false))
endFunction

function OnDefault(RealisticPrisonAndBounty_MCM mcm, int oid) global

    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionDefault(mcm, mcm.GetKeyFromOption(oid, false))
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
