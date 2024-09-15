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


; =========================================================
;                          Events
; =========================================================

; Don't init Cell Doors, let Jail Cells handle them
event OnInit() ; overrides
endEvent

event OnActivate(ObjectReference akActionRef)
    if (!_shouldProcessLockable())
        return
    endif

endEvent

event OnOpen(ObjectReference akActionRef)
    if (!_shouldProcessLockable())
        return
    endif

    
    Actor akOpener = akActionRef as Actor
    Form[] cellPrisoners = JailCell.Prisoners
    
    Debug("["+ self +"] CellDoor::OnOpen", akOpener + " opened cell door " + self + ", which belongs to jail cell " + self.JailCell)
    int i = 0
    while (i < cellPrisoners.Length)
        if (akOpener == cellPrisoners[i])
            ; Get the Prisoner from the cell attached to this door (right now it's retrieving from the Prison, so all prisoners will be retrieved, not ideal)
            RPB_Prisoner prisoner = JailCell.Prison.AwaitPrisonerReference(akOpener)
            JailCell.OnPrisonerOpenCellDoor(self, prisoner)
        endif
        i += 1
    endWhile

    Debug("["+ self +"] CellDoor::OnOpen", akOpener + " opened cell door " + self + ", which belongs to jail cell " + self.JailCell)
endEvent

event OnClose(ObjectReference akActionRef)
    if (!_shouldProcessLockable())
        return
    endif

    Debug("["+ self +"] CellDoor::OnClose", akActionRef + " closed cell door " + self + ", which belongs to jail cell " + self.JailCell)
endEvent

; =========================================================
;                           public                      
; =========================================================

function BindCell(RPB_JailCell akJailCell)
    __jailCell = akJailCell
endFunction

; =========================================================
;                         protected                      
; =========================================================

; Only process this cell door if it's bound to a jail cell
bool function _shouldProcessLockable() ; overrides
    return self.JailCell != none
endFunction

; =========================================================
;                         Data Config                      
; =========================================================

int function GetSerializableRootObject()
    return RPB_Data.GetPropertyOfTypeObject(JailCell.GetSerializableRootObject(), "Cell Doors//" + self)
endFunction
