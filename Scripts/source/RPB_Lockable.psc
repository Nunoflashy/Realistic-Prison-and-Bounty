scriptname RPB_Lockable extends RPB_SerializableObjectReference

import Math
import RPB_Utility

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
    The current level of the lock of this lockable.
/;
string __currentLockLevel
string property CurrentLockLevel
    string function get()
        if (!__currentLockLevel)
            return LockLevelAsString(self.GetLockLevel())
        endif

        if (self.IsLockBroken)
            return "Lock Broken"
        endif

        return __currentLockLevel
    endFunction
endProperty

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
;                         Management
; =========================================================

function Initialize()
    string lockLevel = self.GetPropertyOfTypeString("Lock//Level")
    Debug("["+ self +"] Lockable::Initialize", "lockLevel: " + lockLevel)


    if (lockLevel)
        int lockLevelAsInt  = LockLevelAsInteger(lockLevel)
        Debug("["+ self +"] Lockable::Initialize", "Lock Level: " + lockLevel + ", As Integer: " + lockLevelAsInt + ", Object: " + self)
        self.SetLockLevel(lockLevelAsInt)
    endif
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

string function GetOpenStateAsString()
    if (self.IsLocked())
        return "Locked"
    endif

    if (self.IsClosed)
        return "Closed"
    else
        return "Open"
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

    Debug("Lockable::DowngradeLock", "Lock has been downgraded from " + previousLockLevel + " to " + self.CurrentLockLevel)
endFunction
