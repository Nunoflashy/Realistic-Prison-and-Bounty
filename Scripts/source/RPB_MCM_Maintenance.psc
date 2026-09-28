Scriptname RPB_MCM_Maintenance hidden

import RPB_Utility
import RPB_MCM

bool function ShouldHandleEvent(RPB_MCM mcm) global
    return mcm.CurrentPage == "Maintenance"
endFunction

function Render(RPB_MCM mcm) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    mcm.SetCursorFillMode(mcm.TOP_TO_BOTTOM)
    ; Left()/Right() below were never wired to the MCM (this page used to render empty); their options have no storage
    ; behind them yet. Only the Recovery section is shown for now.
    Recovery(mcm)
endFunction

; For an arrest or imprisonment that got stuck (RPB_Recovery.ResetActor)
function Recovery(RPB_MCM mcm) global
    mcm.AddOptionCategory("Recovery")
    mcm.AddOptionMenuKey("Reset Stuck Actor", "ResetStuckActor", "Choose...")
endFunction

; Who the "Reset Stuck Actor" menu offers, index for index: the console-selected actor first, then every arrestee, then
; every prisoner not in a cell yet
string function __RecoveryCandidatesPath() global
    return ".RPB_Recovery.Candidates"
endFunction

function __OpenResetMenu(RPB_MCM mcm) global
    int candidates = JArray.object()
    JDB.solveObjSetter(__RecoveryCandidatesPath(), candidates, true)
    int names = JArray.object()

    JArray.addForm(candidates, none)
    JArray.addStr(names, "Console-selected actor")

    Form[] arrestees = RPB_API.GetArrest().Arrestees.GetActors()
    int i = 0
    while (i < arrestees.Length)
        Actor a = arrestees[i] as Actor
        if (a)
            JArray.addForm(candidates, a)
            JArray.addStr(names, a.GetDisplayName() + " (arrestee)")
        endif
        i += 1
    endWhile

    RPB_PrisonManager prisonManager = RPB_API.GetPrisonManager()
    int slot = 0
    while (slot < prisonManager.PrisonSlots)
        RPB_Prison prison = prisonManager.GetNthAlias(slot) as RPB_Prison
        if (prison && prison.Active)
            Form[] prisoners = prison.Prisoners.GetActors()
            int p = 0
            while (p < prisoners.Length)
                Actor pa = prisoners[p] as Actor
                if (pa && !RPB_Utility.IsActorImprisoned(pa) && JArray.findForm(candidates, pa) < 0)
                    JArray.addForm(candidates, pa)
                    JArray.addStr(names, pa.GetDisplayName() + " (prisoner, not in a cell)")
                endif
                p += 1
            endWhile
        endif
        slot += 1
    endWhile

    mcm.SetMenuDialogOptions(JArray.asStringArray(names))
    mcm.SetMenuDialogStartIndex(0)
    mcm.SetMenuDialogDefaultIndex(0)
endFunction

function __AcceptResetMenu(RPB_MCM mcm, int menuIndex) global
    int candidates = JDB.solveObj(__RecoveryCandidatesPath())
    if (menuIndex < 0 || !candidates || menuIndex >= JArray.count(candidates))
        return
    endif

    Actor target = JArray.getForm(candidates, menuIndex) as Actor
    if (menuIndex == 0)
        target = Game.GetCurrentConsoleRef() as Actor
    endif

    if (!target)
        mcm.ShowMessage("No actor selected: click one with the console open first.", false)
        return
    endif

    if (mcm.ShowMessage("Free " + target.GetDisplayName() + " from everything Realistic Prison and Bounty left on them? If imprisoned, they are released where they stand.", true, "Reset", "Cancel"))
        string done = RPB_Recovery.ResetActor(target)
        mcm.ShowMessage(string_if(done == "", "Nothing to reset.", "Done: " + done), false)
        mcm.ForcePageReset()
    endif
endFunction

function Left(RPB_MCM mcm) global
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

function Right(RPB_MCM mcm) global
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

function OnOptionHighlight(RPB_MCM mcm, string option) global
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

    elseif (option == "Recovery::ResetStuckActor")
        mcm.SetInfoText("For an arrest or imprisonment that got stuck: frees the chosen actor from everything the mod left on them. A prisoner is released where they stand, with their belongings.")
    endif
 
    Debug("OnOptionHighlight", option + ", find: " + StringUtil.Find(option, "Deleveling") + ", optionName: " + optionName)

endFunction

function OnOptionDefault(RPB_MCM mcm, string option) global
    
endFunction

function OnOptionSelect(RPB_MCM mcm, string option) global
    mcm.ToggleOption(option)
endFunction

function LoadSliderOptions(RPB_MCM mcm, string option, float currentSliderValue) global
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

function OnOptionSliderOpen(RPB_MCM mcm, string option) global
    float sliderOptionValue = mcm.GetOptionSliderValue(option)
    LoadSliderOptions(mcm, option, sliderOptionValue)
    Debug("OnOptionSliderOpen", "Option: " + option + ", Value: " + sliderOptionValue)
endFunction

function OnOptionSliderAccept(RPB_MCM mcm, string option, float value) global
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

function OnOptionMenuOpen(RPB_MCM mcm, string option) global
    if (option == "Recovery::ResetStuckActor")
        __OpenResetMenu(mcm)
    endif
endFunction

function OnOptionMenuAccept(RPB_MCM mcm, string option, int menuIndex) global
    if (option == "Recovery::ResetStuckActor")
        __AcceptResetMenu(mcm, menuIndex)
    endif
endFunction

function OnOptionColorOpen(RPB_MCM mcm, string option) global
    
endFunction

function OnOptionColorAccept(RPB_MCM mcm, string option, int color) global
    
endFunction

function OnOptionInputOpen(RPB_MCM mcm, string option) global
    
endFunction

function OnOptionInputAccept(RPB_MCM mcm, string option, string input) global
    
endFunction

function OnOptionKeymapChange(RPB_MCM mcm, string option, int keyCode, string conflictControl, string conflictName) global
    
endFunction

; =====================================================
; Event Handlers
; =====================================================

function OnHighlight(RPB_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif
    
    OnOptionHighlight(mcm, mcm.GetKeyFromOption(oid, false))
endFunction

function OnDefault(RPB_MCM mcm, int oid) global

    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionDefault(mcm, mcm.GetKeyFromOption(oid, false))
endFunction

function OnSelect(RPB_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionSelect(mcm, mcm.GetKeyFromOption(oid, false))
endFunction

function OnSliderOpen(RPB_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionSliderOpen(mcm, mcm.GetKeyFromOption(oid, false))
endFunction

function OnSliderAccept(RPB_MCM mcm, int oid, float value) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionSliderAccept(mcm, mcm.GetKeyFromOption(oid, false), value)
endFunction

function OnMenuOpen(RPB_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionMenuOpen(mcm, mcm.GetKeyFromOption(oid, false))
endFunction

function OnMenuAccept(RPB_MCM mcm, int oid, int menuIndex) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionMenuAccept(mcm, mcm.GetKeyFromOption(oid, false), menuIndex)
endFunction

function OnColorOpen(RPB_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionColorOpen(mcm, mcm.GetKeyFromOption(oid, false))
endFunction

function OnColorAccept(RPB_MCM mcm, int oid, int color) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionColorAccept(mcm, mcm.GetKeyFromOption(oid, false), color)
endFunction

function OnKeymapChange(RPB_MCM mcm, int oid, int keycode, string conflictControl, string conflictName) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionKeymapChange(mcm, mcm.GetKeyFromOption(oid, false), keycode, conflictControl, conflictName)
endFunction

function OnInputOpen(RPB_MCM mcm, int oid) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    OnOptionInputOpen(mcm, mcm.GetKeyFromOption(oid, false))
endFunction

function OnInputAccept(RPB_MCM mcm, int oid, string inputValue) global
    if (! ShouldHandleEvent(mcm))
        return
    endif
    
    OnOptionInputAccept(mcm, mcm.GetKeyFromOption(oid, false), inputValue)
endFunction
