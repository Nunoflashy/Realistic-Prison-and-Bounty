scriptname RPB_CellDoor extends RPB_Lockable

import Math
import RPB_Utility
import RPB_Config

; ==========================================================
;                     Script References
; ==========================================================


RPB_JailCell __jailCell
RPB_JailCell property JailCell
    RPB_JailCell function get()
        return __jailCell
    endFunction
endProperty

bool property EscapeTriggerDoor
    bool function get()
        return true ; Change later to be a dynamic option in the config file.
    endFunction
endProperty



; ==========================================================

; =========================================================
;                         Functions
; =========================================================



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


; =========================================================
;                         Data Config                      
; =========================================================

int function GetSerializableRootObject()
    return RPB_Data.GetPropertyOfTypeObject(JailCell.GetSerializableRootObject(), "Cell Doors//" + self)
endFunction
