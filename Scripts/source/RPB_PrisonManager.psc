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

; ==========================================================
;                  Shared Prison Properties
; ==========================================================

RPB_API __api
RPB_API property API
    RPB_API function get()
        if (__api)
            return __api
        endif

        __api = RPB_API.GetSelf()
        return __api
    endFunction
endProperty

RPB_Config __config
RPB_Config property Config
    RPB_Config function get()
        if (__config)
            return __config
        endif

        __config = RPB_API.GetConfig()
        return __config
    endFunction
endProperty

RPB_SceneManager __sceneManager
RPB_SceneManager property SceneManager
    RPB_SceneManager function get()
        return API.SceneManager
        if (__sceneManager)
            return __sceneManager
        endif

        __sceneManager = RPB_API.GetSceneManager()
        return __sceneManager
    endFunction
endProperty

Message __serveTimeMessage
Message property ServeTimeMessage
    Message function get()
        if (__serveTimeMessage)
            return __serveTimeMessage
        endif

        __serveTimeMessage = RPB_Utility.ServeTimeMessage()
        return __serveTimeMessage
    endFunction
endProperty

; ==========================================================

int actorToPrison

RPB_Prison function FindPrisonByPrisoner(Actor akPrisonerActor)
    string prisonHold = RPB_StorageVars.GetString(akPrisonerActor.GetFormID(), "PrisonManager")

    if (prisonHold)
        return self.GetPrison(prisonHold)
    endif

    return none
endFunction

RPB_Prison function FindPrisonByHold(string asHold)

endFunction

;/
    RPB_PrisonList function FindPrisonsInCity(string asCity)
        
    endFunction
/;

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
        Trace("PrisonManager::GetAvailablePrisonSlot", "["+ currentPrisonAlias.Name +"] Is Initialized: " + currentPrisonAlias.WasInitialized())
        if (!currentPrisonAlias.Initialized)
            return currentPrisonAlias ; Free slot, return this one
        endif
        i += 1
    endWhile

    return none
endFunction

int function GetNumberOfAvailableSlots()
    int availableSlots = 0

    int i = 0
    while (i < self.PrisonSlots)
        RPB_Prison currentPrisonAlias = self.GetNthAlias(i) as RPB_Prison
        if (!currentPrisonAlias.WasInitialized())
            availableSlots += 1
        endif
        i += 1
    endWhile

    return availableSlots
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

function UninitializePrisons()
    int i = 0
    while (i < self.PrisonSlots)
        RPB_Prison possiblePrison = self.GetNthAlias(i) as RPB_Prison
        if (possiblePrison && possiblePrison.WasInitialized())
            possiblePrison.Uninitialize()
            ; RPB_StorageVars.SetBool("Prison::" + i, false, "PrisonManager")
        endif
        i += 1
    endWhile
endFunction

int function UninitializePrisonByID(int aiPrisonID)
    RPB_Prison possiblePrison = self.GetNthAlias(aiPrisonID) as RPB_Prison
    possiblePrison.Uninitialize()
endFunction

bool function InitializePrisonConfig(string asHold)
    int rootObject      = RPB_Data.GetRootObject(asHold) ; JMap&
    int prisonObject    = RPB_Data.Hold_GetJailObject(rootObject) ; JMap&

    Location prisonLocation = RPB_Prison.Global_GetRootPropertyOfTypeForm(prisonObject, "Location") as Location
    string prisonName       = RPB_Prison.Global_GetRootPropertyOfTypeString(prisonObject, "Name")
    Faction prisonFaction   = RPB_Data.Hold_GetCrimeFaction(rootObject)

    RPB_Prison prisonSlot = self.AvailableSlot

    ; Trace("PrisonManager::InitializePrisonConfig", "{\n"+ \
    ;     "prisonLocation: " + prisonLocation + "\n" + \
    ;     "prisonName: " + prisonName + "\n" + \
    ;     "prisonFaction: " + prisonFaction + "\n" + \
    ;     "prisonSlot: " + prisonSlot + "\n" + \
    ;     "Prison Slots: " + self.PrisonSlots + "\n" \
    ;  +"}")

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
        ; Info("Hold: " + currentPrison.Hold + ", Faction: " + currentPrison.PrisonFaction + ", City: " + currentPrison.City)
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


; RPB_Prison function GetPrisonForBoundPrisoner(RPB_Prisoner akPrisoner)
;     ; int prisonAliasID = JMap.getInt(__global_prisonerList, akPrisoner.GetIdentifier()) ; returns the ID of the Prison alias
;     ; return self.GetAlias(prisonAliasID) as RPB_Prison
;     int prisonAliasID = JDB.solveInt(".rpb_hidden_config.prison.prisoner." + akPrisoner.GetIdentifier()) ; returns the ID of the Prison alias
;     return self.GetAlias(prisonAliasID) as RPB_Prison
; endFunction