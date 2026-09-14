Scriptname RPB_MCM_Presets hidden

import RPB_Utility
import RPB_MCM
import RPB_Memory
import RPB_Data

string function SAVE_AS() global
    return "Save As..."
endFunction

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

;/
    Renders one group of Scope toggles under its own category header. Kept as a shared helper since
    Left() renders two such groups (Pages, Holds) today and will likely render a third (Prisons)
    once the Hold/Prison MCM decoupling lands - see ROADMAP.md.
/;
function RenderScopeGroup(RPB_MCM mcm, string asCategory, string[] akBuckets) global
    mcm.AddOptionCategory(asCategory)

    int i = 0
    while (i < akBuckets.Length)
        string bucket = akBuckets[i]
        int optionId = mcm.AddToggleOption(bucket, false) ; native SKI_ConfigBase toggle, no RPB wrapper/persistence
        mcm.RegisterOption("Scope::" + bucket, optionId) ; id<->key bookkeeping only, needed for dispatch
        i += 1
    endWhile
endFunction

function Left(RPB_MCM mcm) global
    mcm.ResetPresetScopeChecked() ; always start unchecked - ephemeral, not real MCM option storage

    RenderScopeGroup(mcm, "Pages", mcm.GetPresetPageBuckets())
    RenderScopeGroup(mcm, "Holds", mcm.Holds)
endFunction

function Right(RPB_MCM mcm) global
    mcm.AddOptionCategory("Scope Controls")
    mcm.AddOptionTextKey("Select All", "btnSelectAll", "Click to Apply")
    mcm.AddOptionTextKey("Clear All", "btnClearAll", "Click to Apply")

    ; No "/" in this name - GetKeyFromOption(oid, includePageInKey=false) (what this page's whole
    ; dispatch chain uses) strips everything up to the FIRST "/" in the stored key, which would
    ; silently corrupt "Save / Load::menuSavePreset" into " Load::menuSavePreset".
    mcm.AddOptionCategory("Save & Load")
    mcm.AddOptionMenuKey("Save Preset", "menuSavePreset")

    ; Show which preset is currently tracked (most recent Save or Load) as this option's own
    ; displayed value, computed fresh every render so "(Changed)" reflects live state.
    string trackedDisplayName = mcm.GetTrackedPresetDisplayName()

    if (trackedDisplayName != "")
        mcm.SetOptionMenuValue("Save & Load::menuLoadPreset", trackedDisplayName)
    endif

    mcm.AddOptionMenuKey("Load Preset", "menuLoadPreset")

    mcm.AddOptionCategory("Copy")
    mcm.AddOptionMenuKey("Copy From", "menuCopyFrom")
    mcm.AddOptionMenuKey("Copy To", "menuCopyTo")
    mcm.AddOptionTextKey("Copy", "btnCopy", "Click to Apply")
endFunction

;/
    Retrieves the buckets currently checked in the Scope category.
/;
string[] function GetCheckedBuckets(RPB_MCM mcm) global
    string[] buckets = mcm.GetPresetBuckets()
    int checked = FastArray("<string>")

    int i = 0
    while (i < buckets.Length)
        if (mcm.IsPresetBucketChecked(buckets[i]))
            FastArray_AddString(checked, buckets[i])
        endif
        i += 1
    endWhile

    return FastArray_ToStringArray(checked)
endFunction

function SetAllBucketsChecked(RPB_MCM mcm, bool abChecked) global
    string[] buckets = mcm.GetPresetBuckets()

    int i = 0
    while (i < buckets.Length)
        string bucket = buckets[i]
        mcm.SetPresetBucketChecked(bucket, mcm.GetOptionID("Scope::" + bucket), abChecked)
        i += 1
    endWhile
endFunction

string[] function GetSaveMenuOptions(RPB_MCM mcm) global
    string[] existingPresets = mcm.GetExistingPresets()

    if (existingPresets.Length == 0)
        return String_Explode(SAVE_AS())
    endif

    return String_Explode(SAVE_AS() + "," + String_Implode(existingPresets))
endFunction

; =====================================================
; Events
; =====================================================

function OnOptionHighlight(RPB_MCM mcm, string option) global
endFunction

function OnOptionDefault(RPB_MCM mcm, string option) global
endFunction

function OnOptionSelect(RPB_MCM mcm, string option) global
    if (option == "Scope Controls::btnSelectAll")
        SetAllBucketsChecked(mcm, true)

    elseif (option == "Scope Controls::btnClearAll")
        SetAllBucketsChecked(mcm, false)

    elseif (option == "Copy::btnCopy")
        RunCopy(mcm)

    elseif (StringUtil.Find(option, "Scope::") == 0)
        string bucket = StringUtil.Substring(option, 7) ; strip the "Scope::" prefix (7 chars)
        mcm.SetPresetBucketChecked(bucket, mcm.GetOptionID(option), !mcm.IsPresetBucketChecked(bucket))
    endif
endFunction

;/
    Runs the Copy From -> Copy To action, with the same confirm-then-notify pattern as Save/Load.
/;
function RunCopy(RPB_MCM mcm) global
    string copyFrom = mcm.GetOptionMenuValue("Copy::menuCopyFrom")
    string copyTo   = mcm.GetOptionMenuValue("Copy::menuCopyTo")

    if (copyFrom == "" || copyTo == "")
        mcm.ShowMessage("Pick both a Copy From and Copy To Hold first.", false, "OK", "")
        return
    endif

    if (copyFrom == copyTo)
        mcm.ShowMessage("Copy From and Copy To must be different Holds.", false, "OK", "")
        return
    endif

    bool msgResult = mcm.ShowMessage("Are you sure you want to copy " + copyFrom + "'s options into " + copyTo + "?\n\nWarning: This will overwrite " + copyTo + "'s current settings!", true, "Yes", "No")

    if (!msgResult)
        return
    endif

    bool copied = mcm.CopyBucketOptions(copyFrom, copyTo)

    if (copied)
        Debug("MCM_Presets::RunCopy", "Copied " + copyFrom + "'s options into " + copyTo)
        mcm.ShowMessage("Copied " + copyFrom + "'s options into " + copyTo + " successfully!", false, "OK", "")
    else
        mcm.ShowMessage("Could not copy " + copyFrom + " into " + copyTo + " - they don't share the same shape.", false, "OK", "")
    endif
endFunction


function OnOptionSliderOpen(RPB_MCM mcm, string option) global
endFunction

function OnOptionSliderAccept(RPB_MCM mcm, string option, float value) global
endFunction

function OnOptionMenuOpen(RPB_MCM mcm, string option) global
    if (option == "Save & Load::menuSavePreset")
        string[] menuOptions = GetSaveMenuOptions(mcm)
        mcm.SetPresetMenuOptionsCache(option, menuOptions) ; captured now so Accept can't drift from what's shown
        mcm.SetMenuDialogOptions(menuOptions)
        mcm.SetMenuDialogDefaultIndex(0)

    elseif (option == "Save & Load::menuLoadPreset")
        string[] existingPresets = mcm.GetExistingPresets()
        mcm.SetPresetMenuOptionsCache(option, existingPresets)
        mcm.SetMenuDialogOptions(existingPresets)
        mcm.SetMenuDialogDefaultIndex(0)

    elseif (option == "Copy::menuCopyFrom" || option == "Copy::menuCopyTo")
        ; mcm.Holds is a stable property (not a fresh directory listing), no drift risk here -
        ; no need for the same open/accept caching Save/Load use.
        mcm.SetMenuDialogOptions(mcm.Holds)
        mcm.SetMenuDialogDefaultIndex(0)
    endif
endFunction

function OnOptionMenuAccept(RPB_MCM mcm, string option, int menuIndex) global
    if (menuIndex == -1)
        return
    endif

    if (option == "Copy::menuCopyFrom" || option == "Copy::menuCopyTo")
        if (menuIndex >= mcm.Holds.Length)
            return
        endif

        mcm.SetOptionMenuValue(option, mcm.Holds[menuIndex])
        return
    endif

    ; Everything past this point (Save/Load) acts on the Scope checklist.
    string[] checkedBuckets = GetCheckedBuckets(mcm)

    if (checkedBuckets.Length == 0)
        mcm.ShowMessage("Check at least one item under Scope first.", false, "OK", "")
        return
    endif

    ; Reuse the exact list captured at OnOptionMenuOpen-time - recomputing here (e.g. a fresh
    ; directory listing) risks it drifting from what the player actually saw and clicked on,
    ; silently mismatching menuIndex to the wrong item. Fall back to a fresh list only if nothing
    ; was cached (accept firing without a matching open shouldn't normally happen).
    string[] menuOptions = mcm.GetPresetMenuOptionsCache(option)

    if (!menuOptions)
        if (option == "Save & Load::menuSavePreset")
            menuOptions = GetSaveMenuOptions(mcm)
        else
            menuOptions = mcm.GetExistingPresets()
        endif
    endif

    if (menuIndex >= menuOptions.Length)
        return
    endif

    string selectedItem = menuOptions[menuIndex]

    if (option == "Save & Load::menuSavePreset")
        RPB_UIInterface uilib = (Game.GetPlayer() as Form) as RPB_UIInterface

        if (selectedItem == SAVE_AS())
            string presetName = uilib.ShowInput("Save Preset As")

            if (presetName == "")
                return
            endif

            mcm.SavePreset(presetName, checkedBuckets)
            Debug("MCM_Presets::OnOptionMenuAccept", "Saved Preset As: " + presetName + " (" + String_Implode(checkedBuckets) + ")")
            mcm.SetOptionMenuValue("Save & Load::menuLoadPreset", mcm.GetTrackedPresetDisplayName()) ; refresh now, don't wait for the next page reset
            mcm.ShowMessage("Saved preset " + presetName + " successfully!", false, "OK", "")
            return
        endif

        bool msgResult = mcm.ShowMessage("Are you sure you want to overwrite the preset " + selectedItem + " with your currently checked options (" + String_Implode(checkedBuckets) + ")?", true, "Yes", "No")

        if (msgResult)
            mcm.SavePreset(selectedItem, checkedBuckets)
            Debug("MCM_Presets::OnOptionMenuAccept", "Overwrote Preset: " + selectedItem + " with buckets: " + String_Implode(checkedBuckets))
            mcm.SetOptionMenuValue("Save & Load::menuLoadPreset", mcm.GetTrackedPresetDisplayName())
        endif

    elseif (option == "Save & Load::menuLoadPreset")
        string selectedPreset = selectedItem

        bool msgResult = mcm.ShowMessage("Are you sure you want to load the preset " + selectedPreset + " for your currently checked options (" + String_Implode(checkedBuckets) + ")?\n\nWarning: This will overwrite your current settings for those!", true, "Yes", "No")

        if (msgResult)
            mcm.LoadPreset(selectedPreset, checkedBuckets)
            Debug("MCM_Presets::OnOptionMenuAccept", "Loaded Preset: " + selectedPreset + " for buckets: " + String_Implode(checkedBuckets))
            mcm.SetOptionMenuValue("Save & Load::menuLoadPreset", mcm.GetTrackedPresetDisplayName())
            mcm.ShowMessage("Loaded preset " + selectedPreset + " successfully!", false, "OK", "")
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
