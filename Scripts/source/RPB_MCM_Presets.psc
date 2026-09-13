Scriptname RPB_MCM_Presets hidden

import RPB_Utility
import RPB_MCM
import RPB_Memory
import RPB_Data

bool function ShouldHandleEvent(RPB_MCM mcm) global
    return mcm.CurrentPage == "Presets"
endFunction

function Render(RPB_MCM mcm) global
    if (! ShouldHandleEvent(mcm))
        return
    endif

    mcm.SetCursorFillMode(mcm.TOP_TO_BOTTOM)
    Left(mcm)

    mcm.SetCursorPosition(1)
    Right(mcm)
endFunction

function Left(RPB_MCM mcm) global
    mcm.AddOptionCategory("Presets")
    mcm.SetRenderedCategory("SaveLoad")
    mcm.AddOptionMenuKey("Content", "menuContent", "All")

    mcm.SetRenderedCategory("Save")
    mcm.AddOptionMenuKey("Save Preset", "menuSavePreset")

    mcm.SetRenderedCategory("Load")
    mcm.AddOptionMenuKey("Load Preset", "menuLoadPreset")
endFunction

function Right(RPB_MCM mcm) global

endFunction

; =====================================================
; Events
; =====================================================

function OnOptionHighlight(RPB_MCM mcm, string option) global
endFunction

function OnOptionDefault(RPB_MCM mcm, string option) global
endFunction

function OnOptionSelect(RPB_MCM mcm, string option) global
    if (RPB_Utility.String_Contains(option, "btn"))
        bool msgResult = mcm.ShowMessage("Gata", true, "Yes", "No")
        Debug("MCM_Presets::OnOptionSelect", "Option: " + option + ", Result: " + msgResult)

    elseif (RPB_Utility.String_Contains(option, "toggle"))
        mcm.ToggleOption(option)
    endif

    mcm.GetExistingPresets()
endFunction


function OnOptionSliderOpen(RPB_MCM mcm, string option) global
endFunction

function OnOptionSliderAccept(RPB_MCM mcm, string option, float value) global
endFunction

function OnOptionMenuOpen(RPB_MCM mcm, string option) global
    int optionToContents = FastMap("<string>");Object_CreateIfNotExists(optionToContents, FastMap("<string>"))

    string[] presetPages = mcm.GetPresetPages()
    string[] existingPresets = mcm.GetExistingPresets()

    string SAVE_AS = "Save As..."

    string implodedPresets = String_Implode(existingPresets)
    string[] menuOptions = String_Explode( \
        SAVE_AS + "," + \
        implodedPresets \
    )

    FastMap_SetObject(optionToContents, "SaveLoad::menuContent", FastArray_FromStringArray(presetPages))
    FastMap_SetObject(optionToContents, "Save::menuSavePreset",    FastArray_FromStringArray(menuOptions))
    FastMap_SetObject(optionToContents, "SaveLoad::menuContent", FastArray_FromStringArray(presetPages))
    FastMap_SetObject(optionToContents, "Load::menuLoadPreset",    FastArray_FromStringArray(existingPresets))

    if (FastMap_HasKey(optionToContents, option))
        string[] menuItems = FastArray_ToStringArray(FastMap_GetObject(optionToContents, option))
        mcm.SetMenuDialogOptions(menuItems)
        mcm.SetMenuDialogDefaultIndex(0)
    endif


    ; if (option == "SaveLoad::menuContent" || \ 
    ;     option == "SaveLoad::menuContent")
    ;     mcm.SetMenuDialogOptions(mcm.GetPresetPages())
    ;     mcm.SetMenuDialogDefaultIndex(0)

    ; elseif (option == "Load::menuLoadPreset")
    ;     mcm.SetMenuDialogOptions(mcm.GetExistingPresets())
    ;     mcm.SetMenuDialogDefaultIndex(0)
    ; endif
endFunction

; function OnOptionMenuOpen(RPB_MCM mcm, string option) global
;     ; string[] presetPages = mcm.GetPresetPages()
;     ; string[] existingPresets = mcm.GetExistingPresets()

;     ; string SAVE_AS = "Save As..."
;     ; string CANCEL = "Cancel"

;     ; string implodedPresets = String_Implode(existingPresets)
;     ; string[] menuOptions = String_Explode( \
;     ;     SAVE_AS + "," + \
;     ;     implodedPresets + "," + \
;     ;     CANCEL + "," \
;     ; )
;     Debug("", "menuOptions: " + menuOptions)

;     if (option == "SaveLoad::menuContent" || "SaveLoad::menuContent")
;         mcm.SetMenuDialogOptions(mcm.GetPresetPages())

;     elseif (option == "Save::menuSavePreset" || option == "Load::menuLoadPreset")
;         string[] presetPages = mcm.GetPresetPages()
;         string[] existingPresets = mcm.GetExistingPresets()
    
;         string SAVE_AS = "Save As..."
;         string CANCEL = "Cancel"
    
;         string implodedPresets = String_Implode(existingPresets)
;         string[] menuOptions = String_Explode( \
;             SAVE_AS + "," + \
;             implodedPresets + "," + \
;             CANCEL + "," \
;         )

;         Debug("", "menuOptions: " + menuOptions)

;         mcm.SetMenuDialogOptions(menuOptions)
;     endif

;     mcm.SetMenuDialogDefaultIndex(0)

;     ; int optionToContents = Object_CreateIfNotExists(optionToContents, FastMap("<string>"))

;     ; string[] presetPages = mcm.GetPresetPages()
;     ; string[] existingPresets = mcm.GetExistingPresets()

;     ; string SAVE_AS = "Save As..."
;     ; string CANCEL = "Cancel"

;     ; string implodedPresets = String_Implode(existingPresets)
;     ; string[] menuOptions = String_Explode( \
;     ;     SAVE_AS + "," + \
;     ;     implodedPresets + "," + \
;     ;     CANCEL + "," \
;     ; )

;     ; FastMap_SetObject(optionToContents, "SaveLoad::menuContent", FastArray_FromStringArray(presetPages))
;     ; FastMap_SetObject(optionToContents, "Save::menuSavePreset",    FastArray_FromStringArray(menuOptions))
;     ; FastMap_SetObject(optionToContents, "SaveLoad::menuContent", FastArray_FromStringArray(presetPages))
;     ; FastMap_SetObject(optionToContents, "Load::menuLoadPreset",    FastArray_FromStringArray(existingPresets))

;     ; if (FastMap_HasKey(optionToContents, option))
;     ;     string[] menuItems = FastArray_ToStringArray(FastMap_GetObject(optionToContents, option))
;     ;     mcm.SetMenuDialogOptions(menuItems)
;     ;     mcm.SetMenuDialogDefaultIndex(0)
;     ; endif


;     ; if (option == "SaveLoad::menuContent" || \ 
;     ;     option == "SaveLoad::menuContent")
;     ;     mcm.SetMenuDialogOptions(mcm.GetPresetPages())
;     ;     mcm.SetMenuDialogDefaultIndex(0)

;     ; elseif (option == "Load::menuLoadPreset")
;     ;     mcm.SetMenuDialogOptions(mcm.GetExistingPresets())
;     ;     mcm.SetMenuDialogDefaultIndex(0)
;     ; endif
; endFunction

function OnOptionMenuAccept(RPB_MCM mcm, string option, int menuIndex) global
    RPB_UIInterface uilib   = (Game.GetPlayer() as Form) as RPB_UIInterface

    int optionToContents = FastMap("<string>")

    string[] presetPages = mcm.GetPresetPages()
    string[] existingPresets = mcm.GetExistingPresets()

    string SAVE_AS = "Save As..."

    string implodedPresets = String_Implode(existingPresets)
    string[] menuOptions = String_Explode( \
        SAVE_AS + "," + \
        implodedPresets \
    )

    FastMap_SetObject(optionToContents, "SaveLoad::menuContent", FastArray_FromStringArray(presetPages))
    FastMap_SetObject(optionToContents, "Save::menuSavePreset",    FastArray_FromStringArray(menuOptions))
    FastMap_SetObject(optionToContents, "SaveLoad::menuContent", FastArray_FromStringArray(presetPages))
    FastMap_SetObject(optionToContents, "Load::menuLoadPreset",    FastArray_FromStringArray(existingPresets))

    if (!FastMap_HasKey(optionToContents, option) || menuIndex == -1)
        return
    endif

    string[] menuItems = FastArray_ToStringArray(FastMap_GetObject(optionToContents, option))
    string selectedItem = menuItems[menuIndex]

    if (option == "SaveLoad::menuContent")
        mcm.SetOptionMenuValue(option, selectedItem)

    elseif (option == "Save::menuSavePreset" || option == "Load::menuLoadPreset")
        string selectedPreset = selectedItem
        string selectedContent = mcm.GetOptionMenuValue("SaveLoad::menuContent")

        if (option == "Save::menuSavePreset")
            if (selectedItem == SAVE_AS)
                string presetName = uilib.ShowInput("Save Preset As")
                mcm.SavePreset(presetName, selectedContent)
                Debug("MCM_Presets::OnOptionMenuAccept", "Saved Preset As: " + presetName)
                mcm.ShowMessage("Saved preset " + presetName + " successfully!", false, "OK", "")
                return
            endif

            ; A preset is selected to be overwritten
            ; bool msgResult = mcm.ShowMessage("Are you sure you want to overwrite your current options (" + selectedContent + ") to preset " + selectedPreset + "?", true, "Yes", "No")
            bool msgResult = mcm.ShowMessage("Are you sure you want to overwrite the preset " + selectedPreset + " with your current options (" + selectedContent + ")?", true, "Yes", "No")

            if (msgResult)
                mcm.SavePreset(selectedPreset, selectedContent)
                Debug("MCM_Presets::OnOptionMenuAccept", "Overwrote Preset: " + selectedPreset + " with options: " + "{CONTENT_TO_SAVE}")
            endif

        elseif (option == "Load::menuLoadPreset")
            bool msgResult = mcm.ShowMessage("Are you sure you want to load the preset " + selectedPreset + " with the options (" + selectedContent + ")?\n\nWarning: This will overwrite your current options for "+ selectedContent +"!", true, "Yes", "No")

            if (msgResult)
                mcm.LoadPreset(selectedPreset, selectedContent)
                Debug("MCM_Presets::OnOptionMenuAccept", "Loaded Preset: " + selectedPreset + " with options: " + "{CONTENT_TO_LOAD}")
            endif
        endif
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

; Scriptname RPB_MCM_Presets hidden

; import RPB_Utility
; import RPB_MCM
; import RPB_Memory

; bool function ShouldHandleEvent(RPB_MCM mcm) global
;     return mcm.CurrentPage == "Presets"
; endFunction

; function Render(RPB_MCM mcm) global
;     if (! ShouldHandleEvent(mcm))
;         return
;     endif

;     mcm.SetCursorFillMode(mcm.TOP_TO_BOTTOM)
;     Left(mcm)

;     mcm.SetCursorPosition(1)
;     Right(mcm)
; endFunction

; function Left(RPB_MCM mcm) global
;     mcm.AddOptionCategory("Save")
;     mcm.AddOptionMenuKey("Content to Save", "menuContentToSave", "All Pages")
;     mcm.AddOptionMenuKey("Save Preset", "menuSavePreset")
    
;     mcm.AddEmptyOption()

;     mcm.AddOptionCategory("Load")
;     mcm.AddOptionMenuKey("Content to Load", "menuContentToLoad", "All Pages")
;     mcm.AddOptionMenuKey("Load Preset", "menuLoadPreset")
; endFunction

; function Right(RPB_MCM mcm) global

; endFunction

; ; =====================================================
; ; Events
; ; =====================================================

; function OnOptionHighlight(RPB_MCM mcm, string option) global
;     string optionName = GetOptionNameNoCategory(option)

;     ; Deleveling Stats
;     if (StringUtil.Find(option, "Deleveling") != -1)
;         mcm.SetInfoText("Sets how much progress you will lose in " + optionName + " for each day in jail.")

;     elseif (option == "General::Timescale")
;         int timescaleValue = mcm.GetOptionSliderValue(option) as int
;         mcm.SetInfoText("Sets the timescale when free.\nThis is how fast the time passes relative to Real Life.\n1:" + timescaleValue + " means that, for each hour in real life, " + timescaleValue + " hour(s) will pass in-game.")

;     elseif (option == "General::TimescalePrison")
;         int timescaleValue = mcm.GetOptionSliderValue(option) as int
;         mcm.SetInfoText("Sets the timescale when in jail.\nThis is how fast the time passes relative to Real Life.\n1:" + timescaleValue + " means that, for each hour in real life, " + timescaleValue + " hour(s) will pass in-game.")
    
;     elseif (option == "General::TimescalePrisonOutsideGame")
;         int timescaleValue = mcm.GetOptionSliderValue(option) as int
;         mcm.SetInfoText("Sets the timescale when in jail and not playing.\nThis is how fast the time passes relative to Real Life.\n1:" + timescaleValue + " means that, for each hour in real life, " + timescaleValue + " hour(s) will pass in-game.")

;     elseif (option == "General::Bounty Decay (Update Interval)")
;         mcm.SetInfoText("Sets the time between updates in in-game hours for when the bounty should decay for all holds.")

;     elseif (option == "General::Infamy Decay (Update Interval)")
;         mcm.SetInfoText("Sets the time between updates in in-game days for when infamy should be lost over time for all holds that have it enabled.")

;     elseif (option == "General::Arrest Elude Warning Time")
;         mcm.SetInfoText("Determines the time after pursuit that guards will wait for you to stop and surrender before they consider you as being eluding arrest and start attacking.")
;     endif
 
;     Debug("OnOptionHighlight", option + ", find: " + StringUtil.Find(option, "Deleveling") + ", optionName: " + optionName)

; endFunction

; function OnOptionDefault(RPB_MCM mcm, string option) global
    
; endFunction

; function OnOptionSelect(RPB_MCM mcm, string option) global
;     if (RPB_Utility.String_Contains(option, "btn"))
;         bool msgResult = mcm.ShowMessage("Gata", true, "Yes", "No")
;         Debug("MCM_Presets::OnOptionSelect", "Option: " + option + ", Result: " + msgResult)

;     elseif (RPB_Utility.String_Contains(option, "toggle"))
;         mcm.ToggleOption(option)
;     endif

;     mcm.GetExistingPresets()
; endFunction


; function OnOptionSliderOpen(RPB_MCM mcm, string option) global
; endFunction

; function OnOptionSliderAccept(RPB_MCM mcm, string option, float value) global
; endFunction

; function OnOptionMenuOpen(RPB_MCM mcm, string option) global
;     int optionToContents = Object_CreateIfNotExists(optionToContents, FastMap("<string>"))

;     string[] presetPages = mcm.GetPresetPages()
;     string[] existingPresets = mcm.GetExistingPresets()

;     string SAVE_AS = "Save As..."
;     string CANCEL = "Cancel"

;     string implodedPresets = String_Implode(existingPresets)
;     string[] menuOptions = String_Explode( \
;         SAVE_AS + "," + \
;         implodedPresets + "," + \
;         CANCEL + "," \
;     )

;     FastMap_SetObject(optionToContents, "Save::menuContentToSave", FastArray_FromStringArray(presetPages))
;     FastMap_SetObject(optionToContents, "Save::menuSavePreset",    FastArray_FromStringArray(menuOptions))
;     FastMap_SetObject(optionToContents, "Load::menuContentToLoad", FastArray_FromStringArray(presetPages))
;     FastMap_SetObject(optionToContents, "Load::menuLoadPreset",    FastArray_FromStringArray(existingPresets))

;     if (FastMap_HasKey(optionToContents, option))
;         string[] menuItems = FastArray_ToStringArray(FastMap_GetObject(optionToContents, option))
;         mcm.SetMenuDialogOptions(menuItems)
;         mcm.SetMenuDialogDefaultIndex(0)
;     endif


;     ; if (option == "Save::menuContentToSave" || \ 
;     ;     option == "Load::menuContentToLoad")
;     ;     mcm.SetMenuDialogOptions(mcm.GetPresetPages())
;     ;     mcm.SetMenuDialogDefaultIndex(0)

;     ; elseif (option == "Load::menuLoadPreset")
;     ;     mcm.SetMenuDialogOptions(mcm.GetExistingPresets())
;     ;     mcm.SetMenuDialogDefaultIndex(0)
;     ; endif
; endFunction

; ; function OnOptionMenuOpen(RPB_MCM mcm, string option) global
; ;     ; string[] presetPages = mcm.GetPresetPages()
; ;     ; string[] existingPresets = mcm.GetExistingPresets()

; ;     ; string SAVE_AS = "Save As..."
; ;     ; string CANCEL = "Cancel"

; ;     ; string implodedPresets = String_Implode(existingPresets)
; ;     ; string[] menuOptions = String_Explode( \
; ;     ;     SAVE_AS + "," + \
; ;     ;     implodedPresets + "," + \
; ;     ;     CANCEL + "," \
; ;     ; )
; ;     Debug("", "menuOptions: " + menuOptions)

; ;     if (option == "Save::menuContentToSave" || "Load::menuContentToLoad")
; ;         mcm.SetMenuDialogOptions(mcm.GetPresetPages())

; ;     elseif (option == "Save::menuSavePreset" || option == "Load::menuLoadPreset")
; ;         string[] presetPages = mcm.GetPresetPages()
; ;         string[] existingPresets = mcm.GetExistingPresets()
    
; ;         string SAVE_AS = "Save As..."
; ;         string CANCEL = "Cancel"
    
; ;         string implodedPresets = String_Implode(existingPresets)
; ;         string[] menuOptions = String_Explode( \
; ;             SAVE_AS + "," + \
; ;             implodedPresets + "," + \
; ;             CANCEL + "," \
; ;         )

; ;         Debug("", "menuOptions: " + menuOptions)

; ;         mcm.SetMenuDialogOptions(menuOptions)
; ;     endif

; ;     mcm.SetMenuDialogDefaultIndex(0)

; ;     ; int optionToContents = Object_CreateIfNotExists(optionToContents, FastMap("<string>"))

; ;     ; string[] presetPages = mcm.GetPresetPages()
; ;     ; string[] existingPresets = mcm.GetExistingPresets()

; ;     ; string SAVE_AS = "Save As..."
; ;     ; string CANCEL = "Cancel"

; ;     ; string implodedPresets = String_Implode(existingPresets)
; ;     ; string[] menuOptions = String_Explode( \
; ;     ;     SAVE_AS + "," + \
; ;     ;     implodedPresets + "," + \
; ;     ;     CANCEL + "," \
; ;     ; )

; ;     ; FastMap_SetObject(optionToContents, "Save::menuContentToSave", FastArray_FromStringArray(presetPages))
; ;     ; FastMap_SetObject(optionToContents, "Save::menuSavePreset",    FastArray_FromStringArray(menuOptions))
; ;     ; FastMap_SetObject(optionToContents, "Load::menuContentToLoad", FastArray_FromStringArray(presetPages))
; ;     ; FastMap_SetObject(optionToContents, "Load::menuLoadPreset",    FastArray_FromStringArray(existingPresets))

; ;     ; if (FastMap_HasKey(optionToContents, option))
; ;     ;     string[] menuItems = FastArray_ToStringArray(FastMap_GetObject(optionToContents, option))
; ;     ;     mcm.SetMenuDialogOptions(menuItems)
; ;     ;     mcm.SetMenuDialogDefaultIndex(0)
; ;     ; endif


; ;     ; if (option == "Save::menuContentToSave" || \ 
; ;     ;     option == "Load::menuContentToLoad")
; ;     ;     mcm.SetMenuDialogOptions(mcm.GetPresetPages())
; ;     ;     mcm.SetMenuDialogDefaultIndex(0)

; ;     ; elseif (option == "Load::menuLoadPreset")
; ;     ;     mcm.SetMenuDialogOptions(mcm.GetExistingPresets())
; ;     ;     mcm.SetMenuDialogDefaultIndex(0)
; ;     ; endif
; ; endFunction

; function OnOptionMenuAccept(RPB_MCM mcm, string option, int menuIndex) global
;     RPB_UIInterface uilib   = (Game.GetPlayer() as Form) as RPB_UIInterface

;     int optionToContents = Object_CreateIfNotExists(optionToContents, FastMap("<string>"))

;     string[] presetPages = mcm.GetPresetPages()
;     string[] existingPresets = mcm.GetExistingPresets()

;     string SAVE_AS = "Save As..."
;     string CANCEL = "Cancel"

;     string implodedPresets = String_Implode(existingPresets)
;     string[] menuOptions = String_Explode( \
;         SAVE_AS + "," + \
;         implodedPresets + "," + \
;         CANCEL + "," \
;     )

;     FastMap_SetObject(optionToContents, "Save::menuContentToSave", FastArray_FromStringArray(presetPages))
;     FastMap_SetObject(optionToContents, "Save::menuSavePreset",    FastArray_FromStringArray(menuOptions))
;     FastMap_SetObject(optionToContents, "Load::menuContentToLoad", FastArray_FromStringArray(presetPages))
;     FastMap_SetObject(optionToContents, "Load::menuLoadPreset",    FastArray_FromStringArray(existingPresets))

;     if (FastMap_HasKey(optionToContents, option) && menuIndex != -1)
;         string[] menuItems = FastArray_ToStringArray(FastMap_GetObject(optionToContents, option))
;         string selectedItem = menuItems[menuIndex]

;         if (selectedItem == CANCEL)
;             return
;         endif

;         if (selectedItem == SAVE_AS)
;             string presetName = uilib.ShowInput("Save Preset As")
;             Debug("MCM_Presets::OnOptionMenuAccept", "Saved Preset As: " + presetName)
;             return
;         endif

;         if (String_Contains(selectedItem, implodedPresets))
;             bool msgResult = mcm.ShowMessage("Are you sure you want to save your current option to preset " + selectedItem + "?", true, "Yes", "No")
;             if (!msgResult)
;                 return
;             endif     

;             if (msgResult)
;                 Debug("MCM_Presets::OnOptionMenuAccept", "Overwrote Preset: " + selectedItem + " with options: " + "{CONTENT_TO_SAVE}")
;                 return
;             endif
;         endif

;         mcm.SetOptionMenuValue(option, selectedItem)
;     endif

; endFunction

; function OnOptionColorOpen(RPB_MCM mcm, string option) global
    
; endFunction

; function OnOptionColorAccept(RPB_MCM mcm, string option, int color) global
    
; endFunction

; function OnOptionInputOpen(RPB_MCM mcm, string option) global
    
; endFunction

; function OnOptionInputAccept(RPB_MCM mcm, string option, string input) global
    
; endFunction

; function OnOptionKeymapChange(RPB_MCM mcm, string option, int keyCode, string conflictControl, string conflictName) global
    
; endFunction

; ; =====================================================
; ; Event Handlers
; ; =====================================================

; function OnHighlight(RPB_MCM mcm, int oid) global
;     if (! ShouldHandleEvent(mcm))
;         return
;     endif
    
;     OnOptionHighlight(mcm, mcm.GetKeyFromOption(oid, false))
; endFunction

; function OnDefault(RPB_MCM mcm, int oid) global

;     if (! ShouldHandleEvent(mcm))
;         return
;     endif

;     OnOptionDefault(mcm, mcm.GetKeyFromOption(oid, false))
; endFunction

; function OnSelect(RPB_MCM mcm, int oid) global
;     if (! ShouldHandleEvent(mcm))
;         return
;     endif

;     OnOptionSelect(mcm, mcm.GetKeyFromOption(oid, false))
; endFunction

; function OnSliderOpen(RPB_MCM mcm, int oid) global
;     if (! ShouldHandleEvent(mcm))
;         return
;     endif

;     OnOptionSliderOpen(mcm, mcm.GetKeyFromOption(oid, false))
; endFunction

; function OnSliderAccept(RPB_MCM mcm, int oid, float value) global
;     if (! ShouldHandleEvent(mcm))
;         return
;     endif

;     OnOptionSliderAccept(mcm, mcm.GetKeyFromOption(oid, false), value)
; endFunction

; function OnMenuOpen(RPB_MCM mcm, int oid) global
;     if (! ShouldHandleEvent(mcm))
;         return
;     endif

;     OnOptionMenuOpen(mcm, mcm.GetKeyFromOption(oid, false))
; endFunction

; function OnMenuAccept(RPB_MCM mcm, int oid, int menuIndex) global
;     if (! ShouldHandleEvent(mcm))
;         return
;     endif

;     OnOptionMenuAccept(mcm, mcm.GetKeyFromOption(oid, false), menuIndex)
; endFunction

; function OnColorOpen(RPB_MCM mcm, int oid) global
;     if (! ShouldHandleEvent(mcm))
;         return
;     endif

;     OnOptionColorOpen(mcm, mcm.GetKeyFromOption(oid, false))
; endFunction

; function OnColorAccept(RPB_MCM mcm, int oid, int color) global
;     if (! ShouldHandleEvent(mcm))
;         return
;     endif

;     OnOptionColorAccept(mcm, mcm.GetKeyFromOption(oid, false), color)
; endFunction

; function OnKeymapChange(RPB_MCM mcm, int oid, int keycode, string conflictControl, string conflictName) global
;     if (! ShouldHandleEvent(mcm))
;         return
;     endif

;     OnOptionKeymapChange(mcm, mcm.GetKeyFromOption(oid, false), keycode, conflictControl, conflictName)
; endFunction

; function OnInputOpen(RPB_MCM mcm, int oid) global
;     if (! ShouldHandleEvent(mcm))
;         return
;     endif

;     OnOptionInputOpen(mcm, mcm.GetKeyFromOption(oid, false))
; endFunction

; function OnInputAccept(RPB_MCM mcm, int oid, string inputValue) global
;     if (! ShouldHandleEvent(mcm))
;         return
;     endif
    
;     OnOptionInputAccept(mcm, mcm.GetKeyFromOption(oid, false), inputValue)
; endFunction
