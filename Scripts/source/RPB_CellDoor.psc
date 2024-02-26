scriptname RPB_CellDoor extends ObjectReference

import Math
import RPB_Utility
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

RPB_JailCell __jailCell
RPB_JailCell property JailCell
    RPB_JailCell function get()
        return __jailCell
    endFunction
endProperty

bool property IsOpen
    bool function get()
        int openState = self.GetOpenState()
        return openState == 1 || openState == 2
    endFunction
endProperty

bool property IsClosed
    bool function get()
        int openState = self.GetOpenState()
        return openState == 3 || openState == 4
    endFunction
endProperty

bool __hasDecayableLock
bool property HasDecayableLock
    bool function get()
        if (!__hasDecayableLock)
            string[] subCategories = new string[2]
            subCategories[0] = "Decay Options"
            subCategories[1] = "Wear Thresholds"

            __hasDecayableLock = self.HasOption(self.CurrentLockLevel, "Lock", subCategories)
        endif

        return __hasDecayableLock
    endFunction
endProperty

;/
    Retrieves whether this lock has been broken (decayed to the point of having no lock.)
/;
bool __isLockBroken
bool property IsLockBroken
    bool function get()
        return __isLockBroken
    endFunction
endProperty

;/
    Retrieves the current wear level of this lock.
/;
int __lockLevelWear
int property LockLevelWear
    int function get()
        return __lockLevelWear
    endFunction
endProperty

;/
    The minimum lock level to decay to, if this lock has been set as decayable.
    When not set, and enough wear level has been accrued, the lock will break.
/;
string __minimumLockLevel
string property MinimumLockLevel
    string function get()
        if (!__minimumLockLevel)
            string[] subCategories = new string[1]
            subCategories[0] = "Decay Options"
            __minimumLockLevel = self.GetOptionOfTypeString("Min. Lock Level", "Lock", subCategories)
        endif

        return __minimumLockLevel
    endFunction
endProperty

;/
    The current level of the lock of this door.
/;
string __currentLockLevel
string property CurrentLockLevel
    string function get()
        if (!__currentLockLevel)
            return LockLevelAsString(self.GetLockLevel())
        endif

        return __currentLockLevel
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
    if (self.IsLockBroken)
        return
    endif

    ; TODO: Implement additional lock logic
    parent.Lock(abLock, abAsOwner)
endFunction

function Unlock()
    parent.Lock(false, false)
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

    if (self.IsLocked())
        
    else
        
    endif

    if (self.HasDecayableLock)
        self.DetermineLockLevel()
    endif
endEvent

event OnOpen(ObjectReference akActionRef)
    if (!self.IsRegisteredCellDoor())
        return
    endif

    Debug(self, "CellDoor::OnOpen", akActionRef + " opened cell door " + self + ", which belongs to jail cell " + self.JailCell)

endEvent

event OnClose(ObjectReference akActionRef)
    if (!self.IsRegisteredCellDoor())
        return
    endif

endEvent

; =========================================================
;                         Management
; =========================================================

function Initialize()
    string lockLevel = self.GetOptionOfTypeString("Level", "Lock")

    if (lockLevel)
        int lockLevelAsInt  = LockLevelAsInteger(lockLevel)
        Debug(self, "["+ self +"] CellDoor::Initialize", "Lock Level: " + lockLevel + ", As Integer: " + lockLevelAsInt + ", Door: " + self)
        self.SetLockLevel(lockLevelAsInt)
    endif
endFunction

;/
    Determines if this is a registered cell door for a RPB_JailCell in a RPB_Prison.

    This is used to determine if we should process events and functions on this cell door,
    to avoid execution of this script on other cell doors that were not registered for this Prison/Cell.
/;
bool function IsRegisteredCellDoor()
    return JailCell.IsRegisteredCellDoorInPrison(self.GetFormID())
    ;/
        Form[] registeredCellDoors = JailCell.Prison.GetRegisteredCellDoors()
        int i = 0
        while (i < registeredCellDoors.Length)
            if (self.GetFormID() == registeredCellDoors[i].GetFormID())
                return true
            endif
            i += 1
        endWhile

        return false
    /;
endFunction

function BindCell(RPB_JailCell akJailCell)
    __jailCell = akJailCell
endFunction

int function LockLevelAsInteger(string asLockLevel) global
    if (asLockLevel == "Novice")
        return 1
    elseif (asLockLevel == "Apprentice")
        return 25
    elseif (asLockLevel == "Adept")
        return 50
    elseif (asLockLevel == "Expert")
        return 75
    elseif (asLockLevel == "Master")
        return 100
    elseif (asLockLevel == "Requires Key")
        return 255
    endif
endFunction

string function LockLevelAsString(int aiLockLevel) global
    if (aiLockLevel == 1)
        return "Novice"
    elseif (aiLockLevel == 25)
        return "Apprentice"
    elseif (aiLockLevel == 50)
        return "Adept"
    elseif (aiLockLevel == 75)
        return "Expert"
    elseif (aiLockLevel == 100)
        return "Master"
    elseif (aiLockLevel == 255)
        return "Requires Key"
    endif
endFunction

function DetermineLockLevel()
    __lockLevelWear += 1

    string[] subCategories = new string[2]
    subCategories[0] = "Decay Options"
    subCategories[1] = "Wear Thresholds"
    int wearThresholdForCurrentLockLevel = self.GetOptionOfTypeInt(self.CurrentLockLevel, "Lock", subCategories)

    if (self.LockLevelWear >= wearThresholdForCurrentLockLevel)
        self.DowngradeLock()
    endif
endFunction

; Probably temporary, need to find a way to downgrade based on the threshold and not the current lock
function DowngradeLock()
    string nextLockLevel
    string previousLockLevel = self.CurrentLockLevel

    if (self.CurrentLockLevel == "Requires Key")
        nextLockLevel = "Master"
        self.SetLockLevel(LockLevelAsInteger(nextLockLevel))
    
    elseif (self.CurrentLockLevel == "Master")
        nextLockLevel = "Expert"
        self.SetLockLevel(LockLevelAsInteger(nextLockLevel))

    elseif (self.CurrentLockLevel == "Expert")
        nextLockLevel = "Adept"
        self.SetLockLevel(LockLevelAsInteger(nextLockLevel))

    elseif (self.CurrentLockLevel == "Adept")
        nextLockLevel = "Apprentice"
        self.SetLockLevel(LockLevelAsInteger(nextLockLevel))

    elseif (self.CurrentLockLevel == "Apprentice")
        nextLockLevel = "Novice"
        self.SetLockLevel(LockLevelAsInteger(nextLockLevel))

    elseif (self.CurrentLockLevel == "Novice")
        self.Lock(false)
        __isLockBroken = true
    endif

    ; Reset lock wear, since we have downgraded the lock and passed onto the next threshold target
    __lockLevelWear = 0

    ; Reset decayable flag, this way we get the condition for the new lock level
    __hasDecayableLock = false

    ; Assign the new lock level
    __currentLockLevel = nextLockLevel

    Debug(self, "CellDoor::DowngradeLock", "Cell door lock has been downgraded from " + previousLockLevel + " to " + self.CurrentLockLevel)
endFunction


; =========================================================
;                         Data Config                      
; =========================================================

;                           Options                        
; =========================================================
bool function HasOption(string asOption, string asOptionCategory, string[] asArrOptionsSubCategories = none)
    return RPB_Data.CellDoor_HasOption(JailCell.GetDataObject(), self, asOption, asOptionCategory, asArrOptionsSubCategories)
endFunction

bool function GetOptionOfTypeBool(string asOption, string asOptionCategory, string[] asArrOptionsSubCategories = none)
    return RPB_Data.CellDoor_GetOptionOfTypeBool(JailCell.GetDataObject(), self, asOption, asOptionCategory, asArrOptionsSubCategories)
endFunction

int function GetOptionOfTypeInt(string asOption, string asOptionCategory, string[] asArrOptionsSubCategories = none)
    return RPB_Data.CellDoor_GetOptionOfTypeInt(JailCell.GetDataObject(), self, asOption, asOptionCategory, asArrOptionsSubCategories)
endFunction

float function GetOptionOfTypeFloat(string asOption, string asOptionCategory, string[] asArrOptionsSubCategories = none)
    return RPB_Data.CellDoor_GetOptionOfTypeFloat(JailCell.GetDataObject(), self, asOption, asOptionCategory, asArrOptionsSubCategories)
endFunction

string function GetOptionOfTypeString(string asOption, string asOptionCategory, string[] asArrOptionsSubCategories = none)
    return RPB_Data.CellDoor_GetOptionOfTypeString(JailCell.GetDataObject(), self, asOption, asOptionCategory, asArrOptionsSubCategories)
endFunction

Form function GetOptionOfTypeForm(string asOption, string asOptionCategory, string[] asArrOptionsSubCategories = none)
    return RPB_Data.CellDoor_GetOptionOfTypeForm(JailCell.GetDataObject(), self, asOption, asOptionCategory, asArrOptionsSubCategories)
endFunction

; =========================================================
;                         Cell Vars                      
; =========================================================

string function __getCellIdentifierVarKey(string asVarName)
    return "["+ self.GetFormID() +"]Cell::" + asVarName
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