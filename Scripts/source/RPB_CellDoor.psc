scriptname RPB_CellDoor extends ObjectReference

import Math
import RealisticPrisonAndBounty_Util
import RealisticPrisonAndBounty_Config

; ==========================================================
;                     Script References
; ==========================================================

RealisticPrisonAndBounty_Config property Config
    RealisticPrisonAndBounty_Config function get()
        return Game.GetFormFromFile(0x3317, GetPluginName()) as RealisticPrisonAndBounty_Config
    endFunction
endProperty

RealisticPrisonAndBounty_ArrestVars property ArrestVars
    RealisticPrisonAndBounty_ArrestVars function get()
        return Config.ArrestVars
    endFunction
endProperty

RealisticPrisonAndBounty_MiscVars property MiscVars
    RealisticPrisonAndBounty_MiscVars function get()
        return Config.MiscVars
    endFunction
endProperty

; ==========================================================

RPB_JailCell property JailCell
    RPB_JailCell function get()
        
    endFunction
endProperty

ObjectReference property this
    ObjectReference function get()
        return self
    endFunction
endProperty

bool property IsOpen
    bool function get()
        int openState = this.GetOpenState()
        return openState == 1 || openState == 2
    endFunction
endProperty

bool property IsClosed
    bool function get()
        int openState = this.GetOpenState()
        return openState == 3 || openState == 4
    endFunction
endProperty

; ==========================================================

; =========================================================
;                         Functions
; =========================================================

function Open()
    self.SetOpen(true)
endFunction

function Close()
    self.SetOpen(false)
endFunction

; Lock/unlock this object. If told to lock it, it will add a lock if it doesn't have one. If locked/unlocked as the owner on a door,
; the adjoining cell will be made public/private as appropriate
function Lock(bool abLock = true, bool abAsOwner = false)
    ; TODO: Implement lock logic
endFunction

; =========================================================
;                          Events
; =========================================================

event OnActivate(ObjectReference akActionRef)
    if (!self.IsRegisteredCellDoor())
        return
    endif

endEvent

event OnLockStateChanged()
    if (!self.IsRegisteredCellDoor())
        return
    endif

    if (this.IsLocked())
        
    else
        
    endif
endEvent

event OnOpen(ObjectReference akActionRef)
    if (!self.IsRegisteredCellDoor())
        return
    endif

endevent

event OnClose(ObjectReference akActionRef)
    if (!self.IsRegisteredCellDoor())
        return
    endif

endevent

; =========================================================
;                         Management
; =========================================================

;/
    Determines if this is a registered cell door for an RPB_JailCell in a RPB_Prison.

    This is used to determine if we should process events and functions on this cell door,
    to avoid execution of this script on other cell doors that were not registered for this Prison/Cell.
/;
bool function IsRegisteredCellDoor()
    return JailCell.IsRegisteredCellDoorInPrison(this.GetFormID())
endFunction

; =========================================================
;                         Cell Vars                      
; =========================================================

string function __getCellIdentifierVarKey(string asVarName)
    return "["+ this.GetFormID() +"]Cell::" + asVarName
endFunction

;                           Getters
bool function Cell_GetBool(string asVarName)
    string identifierKey = __getCellIdentifierVarKey(asVarName)
    return ArrestVars.GetBool(identifierKey)
endFunction

int function Cell_GetInt(string asVarName)
    string identifierKey = __getCellIdentifierVarKey(asVarName)
    return ArrestVars.GetInt(identifierKey)
endFunction

float function Cell_GetFloat(string asVarName)
    string identifierKey = __getCellIdentifierVarKey(asVarName)
    return ArrestVars.GetFloat(identifierKey)
endFunction

string function Cell_GetString(string asVarName)
    string identifierKey = __getCellIdentifierVarKey(asVarName)
    return ArrestVars.GetString(identifierKey)
endFunction

Form function Cell_GetForm(string asVarName)
    string identifierKey = __getCellIdentifierVarKey(asVarName)
    return ArrestVars.GetForm(identifierKey)
endFunction

ObjectReference function Cell_GetReference(string asVarName)
    string identifierKey = __getCellIdentifierVarKey(asVarName)
    return ArrestVars.GetReference(identifierKey)
endFunction

Actor function Cell_GetActor(string asVarName)
    string identifierKey = __getCellIdentifierVarKey(asVarName)
    return ArrestVars.GetActor(identifierKey)
endFunction

;                           Setters
function Cell_SetBool(string asVarName, bool abValue)

endFunction

function Cell_SetInt(string asVarName, int aiValue, int aiMinValue = 0, int aiMaxValue = 0)

endFunction

function Cell_ModInt(string asVarName, int aiValue)

endFunction

function Cell_SetFloat(string asVarName, float afValue)

endFunction

function Cell_ModFloat(string asVarName, float afValue)

endFunction

function Cell_SetString(string asVarName, string asValue)

endFunction

function Cell_SetForm(string asVarName, Form akValue)

endFunction

function Cell_SetReference(string asVarName, ObjectReference akValue)

endFunction

function Cell_SetActor(string asVarName, Actor akValue)

endFunction