scriptname RPB_CellDoor extends ObjectReference

import Math
import RPB_Utility
import RPB_Config

; ==========================================================
;                     Script References
; ==========================================================


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
            __hasDecayableLock = self.HasProperty("Lock//Decay Options//Wear Thresholds")
        endif

        return __hasDecayableLock
    endFunction
endProperty

bool property EscapeTriggerDoor
    bool function get()
        return true ; Change later to be a dynamic option in the config file.
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
            __minimumLockLevel = self.GetPropertyOfTypeString("Lock//Decay Options//Min. Lock Level")
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

    Actor akOpener = akActionRef as Actor
    Form[] cellPrisoners = JailCell.Prisoners

    int i = 0
    while (i < cellPrisoners.Length)
        if (akOpener == cellPrisoners[i])
            ; Get the Prisoner from the cell attached to this door (right now it's retrieving from the Prison, so all prisoners will be retrieved, not ideal)
            RPB_Prisoner prisoner = JailCell.Prison.GetPrisoner(akOpener)
            JailCell.OnPrisonerOpenCellDoor(self, prisoner)
        endif
        i += 1
    endWhile

    Debug("["+ self +"] CellDoor::OnOpen", akOpener + " opened cell door " + self + ", which belongs to jail cell " + self.JailCell)
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
    ; string lockLevel = self.GetOptionOfTypeString("Level", "Lock")
    string lockLevel = self.GetPropertyOfTypeString("Lock//Level")
    Debug("CellDoor::Initialize", "lockLevel: " + lockLevel)


    if (lockLevel)
        int lockLevelAsInt  = LockLevelAsInteger(lockLevel)
        Debug("["+ self +"] CellDoor::Initialize", "Lock Level: " + lockLevel + ", As Integer: " + lockLevelAsInt + ", Door: " + self)
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

    int wearThresholdForCurrentLockLevel = self.GetPropertyOfTypeInt("Lock//Decay Options//Wear Thresholds//" + self.CurrentLockLevel)

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

    Debug("CellDoor::DowngradeLock", "Cell door lock has been downgraded from " + previousLockLevel + " to " + self.CurrentLockLevel)
endFunction


; =========================================================
;                         Data Config                      
; =========================================================

int function GetRootObject()
    return RPB_Data.GetPropertyOfTypeObject(JailCell.GetRootObject(), "Cell Doors//" + self)
endFunction

bool function GetPropertyOfTypeBool(string asPropertyName)
    return RPB_Data.GetPropertyOfTypeInteger(self.GetRootObject(), asPropertyName) as bool
endFunction

int function GetPropertyOfTypeInt(string asPropertyName)
    return RPB_Data.GetPropertyOfTypeInteger(self.GetRootObject(), asPropertyName)
endFunction

float function GetPropertyOfTypeFloat(string asPropertyName)
    return RPB_Data.GetPropertyOfTypeFloat(self.GetRootObject(), asPropertyName)
endFunction

string function GetPropertyOfTypeString(string asPropertyName)
    return RPB_Data.GetPropertyOfTypeString(self.GetRootObject(), asPropertyName)
endFunction

Form function GetPropertyOfTypeForm(string asPropertyName)
    return RPB_Data.GetPropertyOfTypeForm(self.GetRootObject(), asPropertyName)
endFunction

string[] function GetPropertyOfTypeStringArray(string asPropertyName)
    return RPB_Data.GetPropertyOfTypeStringArray(self.GetRootObject(), asPropertyName)
endFunction

Form[] function GetPropertyOfTypeFormArray(string asPropertyName)
    return RPB_Data.GetPropertyOfTypeFormArray(self.GetRootObject(), asPropertyName)
endFunction

bool function HasProperty(string asPropertyName)
    return RPB_Data.HasProperty(self.GetRootObject(), asPropertyName)
endFunction