Scriptname RPB_PrisonManager extends Quest

import RPB_Utility

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

int actorToPrison

RPB_Prison function FindPrisonByPrisoner(Actor akPrisonerActor)
    string prisonHold = RPB_StorageVars.GetString(akPrisonerActor.GetFormID(), "PrisonManager")

    if (prisonHold)
        return self.GetPrison(prisonHold)
    endif

    return none
endFunction

event OnPrisonRegisteredPrisoner(RPB_Prison apPrison, RPB_Prisoner apPrisoner)
    RPB_StorageVars.SetString(apPrisoner.GetIdentifier(), apPrison.Hold, "PrisonManager")
endEvent

event OnPrisonUnregisteredPrisoner(RPB_Prison apPrison, RPB_Prisoner apPrisoner)
    self.RemovePrisonerFromPrisonRegistry(apPrisoner)
endEvent

function RemovePrisonerFromPrisonRegistry(RPB_Prisoner apPrisoner)
    RPB_StorageVars.DeleteVariable(apPrisoner.GetIdentifier(), "PrisonManager")
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

function ReloadPrisonConfig(RPB_Prison apPrison)
    Location prisonLocation = apPrison.GetRootPropertyOfTypeForm("Location") as Location
    string prisonName       = apPrison.GetRootPropertyOfTypeString("Name")

    apPrison.ConfigurePrison( \
        akLocation  = prisonLocation, \
        akFaction   = apPrison.PrisonFaction, \
        asHold      = apPrison.Hold, \
        asName      = prisonName \
    )

    Error("Some elements of the prison config could not be determined!", !prisonLocation || !prisonName)
endFunction

bool function InitializePrisonConfig(string asHold)
    int rootObject      = RPB_Data.GetRootObject(asHold) ; JMap&
    int prisonObject    = RPB_Data.Hold_GetJailObject(rootObject) ; JMap&

    Location prisonLocation = RPB_Prison.Global_GetRootPropertyOfTypeForm(prisonObject, "Location") as Location
    string prisonName       = RPB_Prison.Global_GetRootPropertyOfTypeString(prisonObject, "Name")
    Faction prisonFaction   = RPB_Data.Hold_GetCrimeFaction(rootObject)

    RPB_Prison prisonSlot = self.AvailableSlot

    if (!prisonSlot)
        Error("There are no Prison Slots available, cannot configure prison for " + asHold + "! (Prison: "+ prisonName +")")
        return false
    endif

    prisonSlot.ConfigurePrison( \
        akLocation  = prisonLocation, \
        akFaction   = prisonFaction, \
        asHold      = asHold, \
        asName      = prisonName \
    )

    return true
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
            ; RPB_Utility.DebugWithArgs("PrisonManager::GetPrison", asHold, "Hold: " + currentPrison.Hold + ", Faction: " + currentPrison.PrisonFaction + ", City: " + currentPrison.City)
            self.ReloadPrisonConfig(currentPrison)
            return currentPrison
        endif
        i += 1
    endWhile

    return none
endFunction

RPB_Prison function GetPrisonByID(int aiPrisonID)
    return self.GetNthAlias(aiPrisonID) as RPB_Prison
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