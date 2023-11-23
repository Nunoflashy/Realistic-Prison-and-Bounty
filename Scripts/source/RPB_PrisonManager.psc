Scriptname RPB_PrisonManager extends Quest

int property PrisonSlots
    int function get()
        return self.GetNumAliases()
    endFunction
endProperty 

RPB_Prison property AvailableSlot
    RPB_Prison function get()
        return self.GetAvailablePrisonSlot()
    endFunction
endProperty

bool function AddPrison(RPB_Prison akPrison)

endFunction

bool function AddPrisonCell(RPB_Prison akPrison, RPB_JailCell akPrisonCell)
    ; akPrison.__addPrisonCell(akPrisonCell)
endFunction

RPB_Prison function GetAvailablePrisonSlot()
    int i = 0

    while (i < self.PrisonSlots)
        RPB_Prison currentPrisonAlias = self.GetNthAlias(i) as RPB_Prison
        if (!currentPrisonAlias.WasInitialized())
            return currentPrisonAlias ; Free slot, return this one
        endif
        i += 1
    endWhile

    return none
endFunction

bool function DeletePrison(RPB_Prison akPrison)

endFunction

;/
    Retrieves a Prison from the given Hold if it is known.

    string  @asHold: The hold to retrieve the prison from

    returns [RPB_Prison]: The RPB_Prison reference for this hold, or none if it does not exist.
/;
RPB_Prison function GetPrison(string asHold)
    int i = 0

    while (i < self.PrisonSlots)
        RPB_Prison currentPrison = self.GetNthAlias(i) as RPB_Prison
        if (currentPrison.Hold == asHold)
            return currentPrison
        endif
        i += 1
    endWhile
endFunction

RPB_Prison[] function GetPrisons()
    
endFunction