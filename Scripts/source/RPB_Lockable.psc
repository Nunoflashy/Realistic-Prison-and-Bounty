scriptname RPB_Lockable extends RPB_SerializableObjectReference

import Math
import RPB_Utility

; =========================================================
;                         Properties
; =========================================================

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

bool property IsUnlocked
    bool function get()
        return !self.IsLocked
    endFunction
endProperty

bool __isLocked
bool property IsLocked
    bool function get()
        return self.IsLocked()
        if (!__isLockInitialized)
            __initializeLockStates()
            return parent.IsLocked()
        endif

        return __isLocked
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
;                          Events
; =========================================================

int __previousLockState
bool __wasLocked
;/
    STATE_OPEN      = 1
    STATE_OPENING   = 2
    STATE_CLOSED    = 3
    STATE_CLOSING   = 4

    (currentState == 2 && __previousLockState == 4)                      ; Open (not Unlocked)
    (currentState == 2 && __previousLockState == 3)                      ; Unlocked and Open
    (currentState == 3 && __previousLockState == 2)                      ; Closed and Locked
    (currentState == 4 && __previousLockState == 2)                      ; Closed (not Locked)
    (currentState == 4 && __previousLockState == 3)                      ; Locked
    (currentState == 3 && __previousLockState == 4)                      ; Locked
    (currentState == 3 && __previousLockState == 3 && self.IsLocked)     ; Locked
    (currentState == 3 && __previousLockState == 3 && !self.IsLocked)    ; Unlocked
    (currentState == 3 && __previousLockState == 1 && self.IsLocked)     ; Locked
    (currentState == 4 && __previousLockState == 4 && self.IsLocked)     ; Locked
/;
event OnLockStateChanged()
    if (!_shouldProcessLockable())
        return
    endif

    int currentState = self.GetOpenState()

    int STATE_OPEN      = 1
    int STATE_OPENING   = 2
    int STATE_CLOSED    = 3
    int STATE_CLOSING   = 4

    if (!__isLockInitialized)
        __initializeLockStates()
        return
    endif

    bool unlockedToLocked = (currentState == STATE_CLOSING && __previousLockState == STATE_CLOSED) || \
                            (currentState == STATE_CLOSED && __previousLockState == STATE_CLOSING && self.IsLocked) || \
                            (currentState == STATE_CLOSED && __previousLockState == STATE_CLOSED && !__wasLocked && self.IsLocked) || \
                            (currentState == STATE_CLOSED && __previousLockState == STATE_OPEN && self.IsLocked)

    bool lockedToUnlocked             = (currentState == STATE_CLOSED && __previousLockState == STATE_CLOSED && __wasLocked && !self.IsLocked)
    bool openUnlockedToClosedLocked   = (currentState == STATE_CLOSED && __previousLockState == STATE_OPENING)
    bool closedLockedToOpenUnlocked   = (currentState == STATE_OPENING && __previousLockState == STATE_CLOSED && __wasLocked)

    if (openUnlockedToClosedLocked)
        self.OnLocked()
        __isLocked = true

    elseif (closedLockedToOpenUnlocked)
        self.OnUnlocked()
        __isLocked = false

    elseif (unlockedToLocked)
        self.OnLock()
        __isLocked = true

    elseif (lockedToUnlocked)
        self.OnUnlock()
        __isLocked = false
    endif

    if (self.HasDecayableLock)
        __determineLockLevel()
    endif

    ; Debug("["+ self +"] Lockable::OnLockStateChanged", "["+ __previousLockState +" -> "+ currentState +"] (Was Locked: "+ __wasLocked +", Is Locked: "+ self.IsLocked +")")

    __wasLocked = self.IsLocked
    __previousLockState = currentState
endEvent

; Happens when this Lockable is locked
event OnLock()
    ; Debug("["+ self +"] Lockable::OnLock", "Locked")
endEvent

; Happens when this Lockable is unlocked
event OnUnlock()
    ; Debug("["+ self +"] Lockable::OnUnlock", "Unlocked")
endEvent

; Happens when this Lockable is closed and locked (Ensuring the Lockable is locked)
event OnLocked()
    ; Debug("["+ self +"] Lockable::OnLocked", "Closed and Locked")
endEvent

; Happens when this Lockable is unlocked and open
event OnUnlocked()
    ; Debug("["+ self +"] Lockable::OnUnlocked", "Unlocked and Open")
endEvent

event OnInit()
    Initialize()
endEvent

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
    ; Debug("["+ self +"] Lockable::Initialize", self)
    string lockLevel = self.GetPropertyOfTypeString("Lock//Level")
    int lockLevelAsInt

    if (lockLevel)
        lockLevelAsInt  = LockLevelAsInteger(lockLevel)
        ; Debug("["+ self +"] Lockable::Initialize", "Lock Level: " + lockLevel + ", As Integer: " + lockLevelAsInt + ", Object: " + self)
        self.SetLockLevel(lockLevelAsInt)
    endif

    __initializeLockStates()
    __isInitialized = true

    Debug("["+ self +"] Lockable::Initialize", "Initialized Lockable ("+ "Locked: " + __isLocked +", Lock State: "+ __previousLockState + ", Lock Level: " + lockLevel + ")")
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
    if (self.IsLocked)
        return "Locked"
    endif

    if (self.IsClosed)
        return "Closed"
    else
        return "Open"
    endif
endFunction

; =========================================================
;                          public
; =========================================================



; =========================================================
;                          protected
; =========================================================

;/
    Determines whether this Lockable should have its Events processed.

    Used to handle only Lockables related to the mod, since the script is attached
    to the base objects.
/;
bool function _shouldProcessLockable() ; abstract
endFunction

; =========================================================
;                           private
; =========================================================

bool __isInitialized
bool __isLockInitialized

function __initializeLockStates()
    __previousLockState = self.GetOpenState()
    __wasLocked         = self.IsLocked
    __isLocked          = self.IsLocked
    __isLockInitialized = true

    ; Debug("["+ self +"] (private) Lockable::InitializeLockStates", "Initialized Lockable ("+ "Locked: " + __isLocked +", Lock State: "+ __previousLockState +")")
endFunction

function __determineLockLevel()
    int wearThresholdForCurrentLockLevel = self.GetPropertyOfTypeInt("Lock//Decay Options//Wear Thresholds//" + self.CurrentLockLevel)

    __lockLevelWear += 1

    if (self.LockLevelWear >= wearThresholdForCurrentLockLevel)
        __downgradeLock()
    endif
endFunction

; Probably temporary, need to find a way to downgrade based on the threshold and not the current lock
function __downgradeLock()
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

    Debug("["+ self +"] (private) Lockable::DowngradeLock", "Lock has been downgraded from " + previousLockLevel + " to " + self.CurrentLockLevel)
endFunction