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
        return API.Config
    endFunction
endProperty

RPB_SceneManager __sceneManager
RPB_SceneManager property SceneManager
    RPB_SceneManager function get()
        return API.SceneManager
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

; ==========================================================
;                  Private Prison Properties
; ==========================================================

bool property PrisonInfamyRecognizedThresholdNotification auto
bool property PrisonInfamyKnownThresholdNotification auto

; ==========================================================

RPB_Prison function FindPrisonByPrisoner(Actor akPrisonerActor)
    string prisonHold = RPB_StorageVars.GetString(akPrisonerActor.GetFormID(), "PrisonManager")

    if (prisonHold)
        return self.GetPrison(prisonHold)
    endif

    return none
endFunction

; Might be deprecated, in the future a hold will have many prisons, 1:N
RPB_Prison function FindPrisonByHold(string asHold)

endFunction

;/
    RPB_PrisonList function FindPrisonsInCity(string asCity)
        
    endFunction
/;

function VerifyPrisonsIntegrity()
    ; return
    ; int root = RPB_Data.GetRootObjectInPath("Holds")
    ; int castleDourDungeonCell01 = RPB_Data.GetPrisonObject("Holds/Haafingar/Prisons/Castle Dour Dungeon/Cells/cell01.json")
    ; Debug("PrisonManager::VerifyPrisonsIntegrity", "castleDourDungeonCell01: " + GetContainerList(castleDourDungeonCell01))
    ; Debug("PrisonManager::VerifyPrisonsIntegrity", "Holds: " + RPB_Data.GetRootObjectInPath("Holds"))
    ; ; Debug("PrisonManager::VerifyPrisonsIntegrity", "root: " + GetContainerList(root))
    ; return
    Debug("PrisonManager::VerifyPrisonsIntegrity", "Verifying Prisons integrity...")

    int i = 0
    while (i < PrisonSlots)
        RPB_Prison prisonRef = self.GetNthAlias(i) as RPB_Prison
        if (prisonRef.Active)
            ReloadPrisonConfig(prisonRef)
            BindAliasTo(prisonRef, prisonRef.JailCells[0] as ObjectReference)
            ; prisonRef.SetupCells()
            ; prisonRef.EnsureFunctionalState()
        endif
        i += 1
    endWhile

    self.RemoveDuplicatePrisons()
endFunction

event OnPrisonConfigured(RPB_Prison apPrison)
    apPrison.Active = true
    apPrison.SetFallbackProperty("Name", apPrison.PrisonLocation.GetName())
    apPrison.SetupCells()
    Debug("PrisonManager::OnPrisonConfigured", "Initialized " + apPrison.Name + " for Hold " + apPrison.Hold)
endEvent

event OnPrisonInitializationFailed(RPB_Prison apPrisonSlot, string asHold, int apRootHoldObject, int apRootPrisonObject, string asReason = "")
    DebugError("PrisonManager::OnPrisonInitializationFailed", "Failed to initialize prison for " + asHold + " (slot: "+ apPrisonSlot.ID +")")
endEvent

event OnPrisonRemove(RPB_Prison apPrison)
    ; Check if there are prisoners currently in the Prison, maybe don't allow removal until then, etc (move Prison to a temp object, for example)
endEvent

event OnPrisonRemoved(RPB_Prison apPrison)

endEvent

event OnPrisonRegisteredPrisoner(RPB_Prison apPrison, RPB_Prisoner apPrisoner)
    RPB_StorageVars.SetString(apPrisoner.GetIdentifier(), apPrison.Hold, "PrisonManager")
endEvent

event OnPrisonUnregisteredPrisoner(RPB_Prison apPrison, RPB_Prisoner apPrisoner)
    self.RemovePrisonerFromPrisonRegistry(apPrisoner)
endEvent

function RemovePrisonerFromPrisonRegistry(RPB_Prisoner apPrisoner)
    RPB_StorageVars.DeleteVariable(apPrisoner.GetIdentifier(), "PrisonManager")
endFunction

; TODO: Refactor this and any function that configures prisons, since by adding two more they stop working entirely
RPB_Prison function GetAvailablePrisonSlot()
    int i = 0

    while (i < self.PrisonSlots)
        RPB_Prison currentPrisonAlias = self.GetNthAlias(i) as RPB_Prison
        if (!currentPrisonAlias.Active)
            return currentPrisonAlias ; Free slot, return this one
        endif
        i += 1
    endWhile

    return none
endFunction

ReferenceAlias function GetEmptySlot()
    int i = 0
    while (i < self.PrisonSlots)
        RPB_Prison slot = self.GetNthAlias(i) as RPB_Prison
        if (!slot.Active)
            return slot
        endif
    endWhile

    return none
endFunction

int function GetNumberOfAvailableSlots()
    int availableSlots = 0

    int i = 0
    while (i < self.PrisonSlots)
        RPB_Prison currentPrisonAlias = self.GetNthAlias(i) as RPB_Prison
        if (!currentPrisonAlias.Active)
            availableSlots += 1
        endif
        i += 1
    endWhile

    return availableSlots
endFunction

bool function IsValidPrison(RPB_Prison apPrison) global
    return apPrison && apPrison.Name != "" && apPrison.Hold != "" && apPrison.PrisonFaction != none
endFunction

; bool function ValidateRootPrisonObject(int apRootObject) global
;     bool hasCells = \
;         RPB_Data.HasProperty(apRootObject, "Cells")


;     bool isValid = \
;         RPB_Data.HasProperty(apRootObject, "Location") && \
;         RPB_Data.HasProperty(apRootObject, "Name") && \
;         RPB_Data.HasProperty(apRootObject, "Prisoner Containers//Belongings") && \
;         RPB_Data.HasProperty(apRootObject, "Prisoner Containers//Evidence") && \
;         RPB_Data.HasProperty(apRootObject, "Markers//Jail//Teleport") && \
;         RPB_Data.HasProperty(apRootObject, "Markers//Jail//Escort") && \
;         RPB_Data.HasProperty(apRootObject, "Markers//Release//Teleport") && \
;         RPB_Data.HasProperty(apRootObject, "Markers//Release//Escort") && \
; endFunction

bool function DeletePrison(RPB_Prison apPrison)
    Debug("["+ apPrison.Name +"] PrisonManager::DeletePrison", "Deleted Prison [Name: " + apPrison.Name + ", Hold: " + apPrison.Hold + ", Faction: " + apPrison.PrisonFaction + ", City: " + apPrison.City + "]")

    Utility.Wait(0.1)
    apPrison.Delete()
endFunction

function AssignPrisonRootObject(RPB_Prison apPrison, int apRootObject) global
    if (apPrison.GetSerializableRootObject() != 0)
        DebugError("PrisonManager::AssignPrisonRootObject", "["+ apPrison.UUID +"] " + apPrison.Name + " already has a root object, aborting!")
        return
    endif

    apPrison.SetLocalPropertyOfTypeInt("Root Object", apRootObject)
    JValue.retain(apRootObject, "PrisonManager::PrisonObjects")
endFunction

bool function AssignPrisonHoldProperties(RPB_Prison apPrison, string asHold, int apHoldRootObject) global
    Faction crimeFaction = RPB_Data.GetPropertyOfTypeForm(apHoldRootObject, "Crime Faction") as Faction

    if (crimeFaction == none)
        return false
    endif

    apPrison.SetLocalPropertyOfTypeString("Hold", asHold)
    apPrison.SetLocalPropertyOfTypeForm("Crime Faction", crimeFaction)

    return true
endFunction

function ReloadPrisonConfig(RPB_Prison apPrison)
    int rootObject      = RPB_Data.GetRootObject(apPrison.Hold) ; JMap&
    int newPrisonObject = RPB_Data.GetPropertyOfTypeObject(rootObject, "Jail") ; JMap& ; Later change to Prison name when 1:N
    int oldPrisonObject = JValue.release(apPrison.GetSerializableRootObject())

    apPrison.SetLocalPropertyOfTypeInt("Root Object", newPrisonObject)
    JValue.retain(newPrisonObject, "PrisonManager::PrisonObjects")
endFunction

function UninitializePrisons()
    int i = 0
    while (i < self.PrisonSlots)
        RPB_Prison possiblePrison = self.GetNthAlias(i) as RPB_Prison
        if (IsValidPrison(possiblePrison) && possiblePrison.Active)
            self.DeletePrison(possiblePrison)
        endif
        i += 1
    endWhile
endFunction

int function UninitializeNthPrison(int index)
    RPB_Prison possiblePrison = self.GetNthPrison(index)
    if (IsValidPrison(possiblePrison))
        self.DeletePrison(possiblePrison)
    endif
endFunction

bool function InitializePrison(string asHold)
    int rootObject      = RPB_Data.GetRootObject(asHold) ; JMap&
    int prisonObject    = RPB_Data.Hold_GetJailObject(rootObject) ; JMap&

    RPB_Prison prisonSlot = self.GetEmptySlot() as RPB_Prison

    if (!prisonSlot)
        Error("There are no Prison Slots available, cannot configure prison for "+ asHold +".")
        self.OnPrisonInitializationFailed(prisonSlot, asHold, rootObject, prisonObject, "No Slots")
        return false
    endif

    ; if (!PrisonExists()) ; TODO: Check if prison exists with given parameters before adding and initialiazing

    if (AssignPrisonHoldProperties(prisonSlot, asHold, rootObject))
        AssignPrisonRootObject(prisonSlot, prisonObject)
        self.OnPrisonConfigured(prisonSlot)

        return true
    endif

    return false
endFunction

bool function InitializePrisonInSlot(string asHold, int aiSlot)
    int rootObject      = RPB_Data.GetRootObject(asHold) ; JMap&
    int prisonObject    = RPB_Data.Hold_GetJailObject(rootObject) ; JMap&

    if (aiSlot > self.PrisonSlots)
        return false; Out of bounds
    endif

    RPB_Prison slotAlias = self.GetNthAlias(aiSlot) as RPB_Prison
    self.DeletePrison(slotAlias)

    if (AssignPrisonHoldProperties(slotAlias, asHold, rootObject))
        AssignPrisonRootObject(slotAlias, prisonObject)
        self.OnPrisonConfigured(slotAlias)

        return true
    endif

    return false
endFunction

function InitializePrisons()
    int rootObject = RPB_Data.GetRootObject() ; JMap&
    string[] holds = JMap.allKeysPArray(rootObject)

    int i = 0
    while (i < holds.Length)
        self.InitializePrison(holds[i])
        i += 1
    endWhile
endFunction

Alias[] function GetPrisons()
    int i = 0
    int activePrisons = 0
    while (i < PrisonSlots)
        RPB_Prison prison = self.GetNthAlias(i) as RPB_Prison
        if (prison.Active && IsValidPrison(prison))
            activePrisons += 1
        endif
        i += 1
    endWhile

    Alias[] prisonArray = Utility.CreateAliasArray(activePrisons)

    i = 0
    while (i < activePrisons)
        RPB_Prison prison = self.GetNthAlias(i) as RPB_Prison
        prisonArray[i] = prison
        i += 1
    endWhile

    return prisonArray
endFunction

;/
    Retrieves a Prison from the given Hold if it is known.

    string  @asHold: The hold to retrieve the prison from

    returns [RPB_Prison]: The RPB_Prison reference for this hold, or none if it does not exist.
/;
; RPB_Prison function GetPrison(string asHold)
;     int i = 0

;     while (i < self.PrisonSlots)
;         RPB_Prison currentPrison = self.GetNthAlias(i) as RPB_Prison
;         ; Info("Hold: " + currentPrison.Hold + ", Faction: " + currentPrison.PrisonFaction + ", City: " + currentPrison.City)
;         if (currentPrison.Hold == asHold)
;             ; RPB_Utility.DebugWithArgs("PrisonManager::GetPrison", asHold, "Hold: " + currentPrison.Hold + ", Faction: " + currentPrison.PrisonFaction + ", City: " + currentPrison.City)
;             self.ReloadPrisonConfig(currentPrison)
;             Debug("PrisonManager::GetPrison", "Returned currentPrison.Name: "+ currentPrison.Name +", currentPrison.ID: " + currentPrison.ID + " (Nth Alias: "+ (currentPrison as Alias).GetID() +") ")

;             return currentPrison
;         endif
;         i += 1
;     endWhile

;     return none
; endFunction

RPB_Prison function GetPrison(string asHold)
    int i = 0

    while (i < self.PrisonSlots)
        RPB_Prison currentPrison = self.GetNthAlias(i) as RPB_Prison
        if (currentPrison.Hold == asHold)
            return currentPrison
        endif
        i += 1
    endWhile

    return none
endFunction

; TODO: Add support for multiple prisons in each Hold,
; Returns a Alias[], each element is castable to RPB_Prison
Alias[] function GetPrisonsForHold(string asHold)
    int i = 0
    int holdPrisonsCount = 0
    while (i < PrisonSlots)
        RPB_Prison prison = self.GetNthAlias(i) as RPB_Prison
        if (prison.Active && IsValidPrison(prison) && prison.Hold == asHold)
            holdPrisonsCount += 1
        endif
        i += 1
    endWhile

    Alias[] prisonRefs = Utility.CreateAliasArray(holdPrisonsCount)
    
    i = 0
    while (i < holdPrisonsCount)
        RPB_Prison prisonRef = self.GetNthAlias(i) as RPB_Prison
        prisonRefs[i] = prisonRef
        i += 1
    endWhile

    return prisonRefs
endFunction

RPB_Prison function GetNthPrison(int index)
    RPB_Prison currentPrisonSlot = self.GetNthAlias(index) as RPB_Prison
    if (currentPrisonSlot.Active && IsValidPrison(currentPrisonSlot))
        return currentPrisonSlot
    endif

    return none
endFunction

RPB_Prison function GetPrisonByID(int aiPrisonID)
    return self.GetNthAlias(aiPrisonID) as RPB_Prison
endFunction

; Later cache the Prisons by UUID
RPB_Prison function GetPrisonByUUID(string uuid)
    int i = 0
    while (i < PrisonSlots)
        RPB_Prison prison = self.GetNthPrison(i)
        if (prison.UUID == uuid)
            return prison
        endif
        i += 1
    endWhile

    return none
endFunction

bool function PrisonExists(string asHold, string asName, Faction akCrimeFaction)
    int i = 0
    while (i < PrisonSlots)
        RPB_Prison prisonRef = self.GetNthPrison(i)
        if (prisonRef.Hold == asHold && prisonRef.Name == asName && prisonRef.PrisonFaction == akCrimeFaction)
            return true
        endif
        i += 1
    endWhile

    return false
endFunction

bool function IsSamePrison(RPB_Prison apPrisonOne, RPB_Prison apPrisonTwo) global
    return (apPrisonOne.Name == apPrisonTwo.Name) && (apPrisonOne.Hold == apPrisonTwo.Hold) && (apPrisonOne.PrisonFaction == apPrisonTwo.PrisonFaction)
endFunction

int function GetActivePrisonCount()
    int activePrisonCount = 0

    int i = 0
    while (i < PrisonSlots)
        RPB_Prison prisonRef = self.GetNthPrison(i)
        if (prisonRef)
            activePrisonCount += 1
        endif
        i += 1
    endWhile

    return activePrisonCount
endFunction

function RemoveDuplicatePrisons()
    int i = 0
    int j = 0

    while (i < PrisonSlots)
        RPB_Prison currentPrison = self.GetNthAlias(i) as RPB_Prison
        if (currentPrison)
            j = (i + 1)
            while (j < PrisonSlots)
                RPB_Prison prisonToCheck = self.GetNthAlias(j) as RPB_Prison
                if (IsValidPrison(prisonToCheck) && IsSamePrison(currentPrison, prisonToCheck))
                    Debug("PrisonManager::RemoveDuplicatePrisons", "Found duplicate Prison in slot "+ j +": ["+ prisonToCheck.Name +"], already exists in slot: " + i)
                    self.DeletePrison(prisonToCheck)
                endif
                j += 1
            endWhile
        endif
        i += 1
    endWhile
endFunction

; ==========================================================
;                       AI Cell Packages
; ==========================================================

Quest cellPackagesReference

ReferenceAlias function GetCellPackageOfType(string asCellPackageType)
    if (!cellPackagesReference)
        cellPackagesReference = RPB_Utility.CellPackages()
    endif
    
    int availablePackages = cellPackagesReference.GetNumAliases()

    int i = 0
    while (i < availablePackages)
        string packageName

        if (i >= 100)
            packageName = asCellPackageType + "_0" + i

        elseif (i >= 10)
            packageName = asCellPackageType + "_00" + i

        else
            packageName = asCellPackageType + "_000" + i
        endif

        ReferenceAlias currentPackage = self.GetCellPackageByName(packageName)

        if (currentPackage.GetReference() == none)
            DebugWithArgs("PrisonManager::GetCellPackageOfType", asCellPackageType, "Retrieving Cell Package: " + packageName)
            return currentPackage
        endif

        i += 1
    endWhile

    DebugWarn("PrisonManager:GetCellPackageOfType", "There are no available AI Cell packages to assign!")
    Warn("There are no available AI Cell packages to assign!")
    return none
endFunction

ReferenceAlias function GetCellPackageByIndex(int aiCellPackageIndex)
    if (!cellPackagesReference)
        cellPackagesReference = RPB_Utility.CellPackages()
    endif    

    return cellPackagesReference.GetNthAlias(aiCellPackageIndex) as ReferenceAlias
endFunction

ReferenceAlias function GetCellPackageByName(string asCellPackageName)
    if (!cellPackagesReference)
        cellPackagesReference = RPB_Utility.CellPackages()
    endif    

    return cellPackagesReference.GetAliasByName(asCellPackageName) as ReferenceAlias
endFunction
