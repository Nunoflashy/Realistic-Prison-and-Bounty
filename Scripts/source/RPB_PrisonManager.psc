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

bool function WasPrisonConfigChanged(RPB_Prison apPrison)
    int holdRootObject = RPB_Data.GetRootObject(apPrison.Hold)
    RPB_Utility.Debug("Prison::WasConfigChanged", "Prison: " + apPrison.City + ", " + "holdRootObject: " + holdRootObject)
    RPB_Utility.Debug("Prison::WasConfigChanged", "Hold: " + apPrison.Hold + ", Faction: " + apPrison.PrisonFaction + ", City: " + apPrison.City)
    return true
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
            ; currentPrison.PrisonFaction = Game.GetFormEx(0x29DB0) as Faction ; temporary
            currentPrison.ConfigurePrison(currentPrison.PrisonLocation, Game.GetFormEx(0x29DB0) as Faction, currentPrison.Hold)
            RPB_Utility.DebugWithArgs("PrisonManager::GetPrison", asHold, "Hold: " + currentPrison.Hold + ", Faction: " + currentPrison.PrisonFaction + ", City: " + currentPrison.City)
            return currentPrison
        endif
        i += 1
    endWhile
endFunction

RPB_Prison[] function GetPrisons()
    
endFunction

int __global_prisonerList

function BindPrisonerToPrison(RPB_Prisoner akPrisoner, RPB_Prison akPrison) global
    ; if (!__global_prisonerList)
    ;     __global_prisonerList = JMap.object()
    ;     JValue.retain(__global_prisonerList)
    ; endif

    ; JMap.setInt(__global_prisonerList, akPrisoner.GetIdentifier(), akPrison.GetID())

    JDB.solveIntSetter(".rpb_hidden_config.prison.prisoner." + akPrisoner.GetIdentifier(), akPrison.GetID(), true)
endFunction

RPB_Prison function GetPrisonForBoundPrisoner(Actor akPrisonerActor)
    ; int prisonAliasID = JMap.getInt(__global_prisonerList, akPrisoner.GetIdentifier()) ; returns the ID of the Prison alias
    ; return self.GetAlias(prisonAliasID) as RPB_Prison
    int prisonAliasID = JDB.solveInt(".rpb_hidden_config.prison.prisoner." + akPrisonerActor.GetFormID()) ; returns the ID of the Prison alias
    return self.GetAlias(prisonAliasID) as RPB_Prison
endFunction

; RPB_Prison function GetPrisonForBoundPrisoner(RPB_Prisoner akPrisoner)
;     ; int prisonAliasID = JMap.getInt(__global_prisonerList, akPrisoner.GetIdentifier()) ; returns the ID of the Prison alias
;     ; return self.GetAlias(prisonAliasID) as RPB_Prison
;     int prisonAliasID = JDB.solveInt(".rpb_hidden_config.prison.prisoner." + akPrisoner.GetIdentifier()) ; returns the ID of the Prison alias
;     return self.GetAlias(prisonAliasID) as RPB_Prison
; endFunction