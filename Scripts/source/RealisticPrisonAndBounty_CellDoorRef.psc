Scriptname RealisticPrisonAndBounty_CellDoorRef extends ReferenceAlias  

import RealisticPrisonAndBounty_Util
import RealisticPrisonAndBounty_Config

RealisticPrisonAndBounty_Jail property jail
    RealisticPrisonAndBounty_Jail function get()
        return Game.GetFormFromFile(0x3DF8, GetPluginName()) as RealisticPrisonAndBounty_Jail
    endFunction
endProperty

ObjectReference property this
    ObjectReference function get()
        return self.GetReference()
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

event OnActivate(ObjectReference akActionRef)

endEvent

event OnLockStateChanged()
    if (this.isLocked())
        jail.OnCellDoorLocked(this, none)
    else
        jail.OnCellDoorUnlocked(this, none)
    endif
endEvent

event OnOpen(ObjectReference akActionRef)
    jail.OnCellDoorOpen(this, akActionRef as Actor)
endevent

event OnClose(ObjectReference akActionRef)
    jail.OnCellDoorClosed(this, akActionRef as Actor)
endevent