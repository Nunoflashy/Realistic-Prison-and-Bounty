Scriptname RPB_MCM_Skills hidden

import RPB_Utility
import RPB_MCM

bool function ShouldHandleEvent(RPB_MCM mcm) global
    return mcm.CurrentPage == "Skills"
endFunction

function Render(RPB_MCM mcm) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    float bench = StartBenchmark()
    mcm.SetCursorFillMode(mcm.TOP_TO_BOTTOM)
    Left(mcm)

    mcm.SetCursorPosition(1)
    Right(mcm)

    EndBenchmark(bench, mcm.CurrentPage + " page loaded -")
endFunction

function Left(RPB_MCM mcm) global
    mcm.AddOptionCategory("Deleveling")

    int i = 0
    while (i < 10)
        string skill = mcm.Skills[i]
        mcm.AddOptionSlider(skill, string_if (IsStatSkill(skill), "{0} Points", "{0} Levels"), 0)
        i += 1
    endWhile

    mcm.AddEmptyOption()

    mcm.AddOptionCategory("Level Caps")
    int j = 0
    while (j < 10)
        string skill = mcm.Skills[j]
        mcm.AddOptionSlider(skill, string_if (IsStatSkill(skill), "{0} Points", "Level {0}"), 0)
        j += 1
    endWhile
endFunction

function Right(RPB_MCM mcm) global
    mcm.AddOptionCategoryKey("", "Deleveling")
    ; mcm.SetRenderedCategory("Skills")

    int i = 0
    while (i < 11)
        string skill = mcm.Skills[i+10]
        mcm.AddOptionSlider(skill, string_if (IsStatSkill(skill), "{0} Points", "{0} Levels"), 0)
        i += 1
    endWhile

    mcm.AddOptionCategoryKey("", "Level Caps")
    int j = 0
    while (j < 11)
        string skill = mcm.Skills[j+10]
        mcm.AddOptionSlider(skill, string_if (IsStatSkill(skill), "{0} Points", "Level {0}"), 0)
        j += 1
    endWhile
endFunction

function HandleDependencies(RPB_MCM mcm) global

endFunction

function HandleSliderOptionDependency(RPB_MCM mcm, string option, float value) global

endFunction

; =====================================================
; Events
; =====================================================

function OnOptionHighlight(RPB_MCM mcm, string option) global
    string optionName = GetOptionNameNoCategory(option)

    ; Deleveling Stats
    if (IsDelevelingCategory(option))
        mcm.SetInfoText("Sets how much progress you will lose in " + optionName + " for each day in jail.")

    elseif (IsSkillCapCategory(option))
        string levelOrPoints = string_if (IsStatSkill(option), "points", "level")
        mcm.SetInfoText("Determines the lowest " + levelOrPoints + " for " + optionName + " when being deleveled in jail.")
    endif
endFunction

function OnOptionDefault(RPB_MCM mcm, string option) global

endFunction

function OnOptionSelect(RPB_MCM mcm, string option) global
    mcm.ToggleOption(option)
    HandleDependencies(mcm)
endFunction

function LoadSliderOptions(RPB_MCM mcm, string option, float currentSliderValue) global
    float minRange = 0
    float maxRange = 100000
    float intervalSteps = 1
    float defaultValue = mcm.GetOptionDefaultFloat(option)

    if (IsDelevelingCategory(option))
        if (IsStatSkill(option))
            maxRange = 1000
        else
            maxRange = 100 ; For Perk Skills (Max Lv.100)
        endif

    elseif (IsSkillCapCategory(option))
        if (IsStatSkill(option))
            maxRange = 1000
        else
            maxRange = 100 ; For Perk Skills (Max Lv.100)
        endif
    endif

    defaultValue = float_if (defaultValue > maxRange, maxRange, defaultValue)
    float startValue = float_if (currentSliderValue > mcm.GENERAL_ERROR, currentSliderValue, defaultValue)
    mcm.SetSliderOptions(minRange, maxRange, intervalSteps, defaultValue, startValue)
endFunction

function OnOptionSliderOpen(RPB_MCM mcm, string option) global
    float sliderOptionValue = mcm.GetOptionSliderValue(option)
    LoadSliderOptions(mcm, option, sliderOptionValue)
    Debug("OnOptionSliderOpen", "Option: " + option + ", Value: " + sliderOptionValue)
endFunction

function OnOptionSliderAccept(RPB_MCM mcm, string option, float value) global
    string formatString = "{0} Levels"

    if (IsDelevelingCategory(option))
        if (IsStatSkill(option))
            formatString = "{0} Points"
        else
            formatString = "{0} Levels"
        endif

    elseif (IsSkillCapCategory(option))
        if (IsStatSkill(option))
            formatString = "{0} Points"
        else
            formatString = "Level {0}"
        endif
    endif

    ; Handle any slider option that depends on the current option being set
    HandleSliderOptionDependency(mcm, option, value)

    ; Set the main option value
    mcm.SetOptionSliderValue(option, value, formatString)

    ; Send option changed event
    mcm.SendModEvent("RPB_SliderOptionChanged", option, value)

    Debug("OnSliderAccept", "GetOptionSliderValue("+  option +") = " + mcm.GetOptionSliderValue(option, mcm.CurrentPage))
endFunction

function OnOptionMenuOpen(RPB_MCM mcm, string option) global
    string defaultValue = mcm.GetOptionDefaultString(option)

endFunction

function OnOptionMenuAccept(RPB_MCM mcm, string option, int menuIndex) global
    Debug("OnOptionMenuAccept", "GetMenuOptionValue("+  option +") = " + mcm.GetOptionMenuValue(option, mcm.CurrentPage))
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
;                       Utility
; =====================================================

bool function IsDelevelingCategory(string asOption) global
    return StringUtil.Find(asOption, "Deleveling") != -1
endFunction

bool function IsSkillCapCategory(string asOption) global
    return StringUtil.Find(asOption, "Level Caps") != -1
endFunction

bool function IsStatSkill(string asSkillName) global    
    return  StringUtil.Find(asSkillName, "Health") != -1 || \
            StringUtil.Find(asSkillName, "Stamina") != -1 || \
            StringUtil.Find(asSkillName, "Magicka") != -1
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
