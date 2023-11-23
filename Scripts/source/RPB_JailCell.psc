scriptname RPB_JailCell extends ReferenceAlias

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

RPB_Prison property Prison
    RPB_Prison function get()
        
    endFunction
endProperty

ObjectReference property CellDoor
    ObjectReference function get()
        return self.GetCellDoor()
    endFunction
endProperty

RPB_Guard property Guard
    RPB_Guard function get()
        return self.GetGuard()
    endFunction
endProperty

RPB_Prisoner[] __prisoners
RPB_Prisoner[] property Prisoners
    RPB_Prisoner[] function get()
        return self.GetPrisoners()
    endFunction
endProperty

bool property IsEmpty
    bool function get()
    endFunction
endProperty

bool property IsAvailable
    bool function get()
    endFunction
endProperty

bool property IsFemaleOnly
    bool function get()
    endFunction
endProperty

bool property IsMaleOnly
    bool function get()
    endFunction
endProperty

; ==========================================================

ObjectReference function GetCellObject(Keyword akPropType)

endFunction

;/
    Retrieves the door of this jail cell.
/;
ObjectReference function GetCellDoor()

endFunction


ObjectReference function GetMarker()
    
endFunction

;/
    Retrieves the guard this jail cell is assigned to
/;
RPB_Guard function GetGuard()

endFunction

ObjectReference[] function GetBeds()
    
endFunction


; =========================================================
;                           Cell                        
; =========================================================

function SetAsFemaleOnly()
    Cell_SetBool("Female Only", true)
endFunction

function SetAsMaleOnly()
    Cell_SetBool("Male Only", true)
endFunction

; =========================================================
;                         Prisoners                        
; =========================================================

bool function HasPrisoners()

endFunction

bool function HasFemales(bool abStrictlyFemales = false)
    
endFunction

bool function HasMales(bool abStrictlyMales = false)
    
endFunction

;/
    Retrieves the prisoner(s) living in this jail cell.
/;
RPB_Prisoner[] function GetPrisoners()

endFunction

RPB_Prisoner[] function GetFemalePrisoners()

endFunction

RPB_Prisoner[] function GetMalePrisoners()
    
endFunction

; =========================================================
;                          Events
; =========================================================

event OnPrisonerEnter(RPB_Prisoner akPrisoner)

endEvent

event OnPrisonerLeave(RPB_Prisoner akPrisoner)

endEvent

; =========================================================
;                         Management
; =========================================================

bool function IsRegisteredCellDoorInPrison(int aiCellDoorFormID)
    
endFunction

function BindCellDoor(RPB_CellDoor akCellDoor)
    
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

ObjectReference property this
    ObjectReference function get()
        return self.GetReference()
    endFunction
endProperty