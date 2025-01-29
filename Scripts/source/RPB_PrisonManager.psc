Scriptname RPB_PrisonManager extends Quest

import RPB_Utility
import RPB_Memory

; ==========================================================
;                      Script References
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

RPB_EventManager __eventManager
RPB_EventManager property EventManager
    RPB_EventManager function get()
        return API.EventManager
    endFunction
endProperty

RPB_SceneManager __sceneManager
RPB_SceneManager property SceneManager
    RPB_SceneManager function get()
        return API.SceneManager
    endFunction
endProperty

; ==========================================================
;                         Properties
; ==========================================================

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

bool property HasPrisonsWithPrisoners
    bool function get()
        return self.PrisonsWithPrisonersCount > 0
    endFunction
endProperty

; ==========================================================
;                  Shared Prison Properties
; ==========================================================

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
;                  Private Prison Properties
; ==========================================================

bool property PrisonInfamyRecognizedThresholdNotification auto
bool property PrisonInfamyKnownThresholdNotification auto

int __prisonsWithPrisonersCount
int property PrisonsWithPrisonersCount
    int function get()
        return __prisonsWithPrisonersCount
    endFunction
endProperty

; ==========================================================

function PrisonManager()
    __cellPackages_S_01         = RPB_Utility.GetCellPackageGroup("CellPackages_S_01")
    __cellPackages_M_01         = RPB_Utility.GetCellPackageGroup("CellPackages_M_01")
    __cellPackages_L_01         = RPB_Utility.GetCellPackageGroup("CellPackages_L_01")
    __cellPackages_XL_01        = RPB_Utility.GetCellPackageGroup("CellPackages_XL_01")
    __cellPackages_2XL_01       = RPB_Utility.GetCellPackageGroup("CellPackages_2XL_01")

    int cellPackageGroup_S      = FastArray("<RPB_PackageGroup>")
    int cellPackageGroup_M      = FastArray("<RPB_PackageGroup>")
    int cellPackageGroup_L      = FastArray("<RPB_PackageGroup>")
    int cellPackageGroup_XL     = FastArray("<RPB_PackageGroup>")
    int cellPackageGroup_2XL    = FastArray("<RPB_PackageGroup>")

    FastArray_AddForm(cellPackageGroup_S, __cellPackages_S_01)
    FastArray_AddForm(cellPackageGroup_M, __cellPackages_M_01)
    FastArray_AddForm(cellPackageGroup_L, __cellPackages_L_01)
    FastArray_AddForm(cellPackageGroup_XL, __cellPackages_XL_01)
    FastArray_AddForm(cellPackageGroup_2XL, __cellPackages_2XL_01)
    
    __cellPackageMapping = FastMap("<string>", retain = true)

    FastMap_SetObject(__cellPackageMapping, "S", cellPackageGroup_S)
    FastMap_SetObject(__cellPackageMapping, "M", cellPackageGroup_M)
    FastMap_SetObject(__cellPackageMapping, "L", cellPackageGroup_L)
    FastMap_SetObject(__cellPackageMapping, "XL", cellPackageGroup_XL)
    FastMap_SetObject(__cellPackageMapping, "2XL", cellPackageGroup_2XL)
endFunction

; ==========================================================
;                        Event Handlers
; ==========================================================

event OnPrisonConfigured(RPB_Prison apPrison)
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
    ; Check if there are prisoners currently in the Prison, maybe don't allow removal until then, etc (move Prison to a temp object, for example)

endEvent

event OnPrisonRegisteredPrisoner(RPB_Prison apPrison, RPB_Prisoner apPrisoner)
    self.AddPrisonerToPrisonRegistry(apPrisoner)

    ;/ const /; int PRISONERS_BEFORE_EVENT = (apPrison.Prisoners.Count - 1)

    if (PRISONERS_BEFORE_EVENT == 0)
        __prisonsWithPrisonersCount += 1
    endif
endEvent

event OnPrisonUnregisteredPrisoner(RPB_Prison apPrison, RPB_Prisoner apPrisoner)
    self.RemovePrisonerFromPrisonRegistry(apPrisoner)

    ;/ const /; int PRISONERS_AFTER_EVENT = apPrison.Prisoners.Count

    if (PRISONERS_AFTER_EVENT == 0)
        __prisonsWithPrisonersCount -= 1
    endif
endEvent

; ==========================================================
;                      Prison Registry
; ==========================================================

; When 1:N Hold to Prisons, the value should be Prison's UUID and not the Hold
function AddPrisonerToPrisonRegistry(RPB_Prisoner apPrisoner)
    RPB_StorageVars.SetString(apPrisoner.GetIdentifier(), apPrisoner.Prison.Hold, "PrisonManager")
endFunction

function RemovePrisonerFromPrisonRegistry(RPB_Prisoner apPrisoner)
    RPB_StorageVars.DeleteVariable(apPrisoner.GetIdentifier(), "PrisonManager")
endFunction

; ==========================================================
;                          Queries
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
        i += 1
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

bool function IsSamePrison(RPB_Prison apPrisonOne, RPB_Prison apPrisonTwo) global
    return (apPrisonOne.Name == apPrisonTwo.Name) && (apPrisonOne.Hold == apPrisonTwo.Hold) && (apPrisonOne.PrisonFaction == apPrisonTwo.PrisonFaction)
endFunction

bool function IsValidPrison(RPB_Prison apPrison) global
    return apPrison && apPrison.Name != "" && apPrison.Hold != "" && apPrison.PrisonFaction != none
endFunction

;/
    Checks whether the Prison given by the object already exists in the Prison Registry.
    If the Hold object is passed, the verification will be more in depth and take the Hold into account.

    FastMap<string, any>    @apRootPrisonObject: The reference to the Prison Object.
    FastMap<string, any>?   @apRootHoldObject: The reference to the Hold Object.

    returns (bool): Whether the Prison from the given object already exists.
/;
bool function PrisonExists_FromObject(int apRootPrisonObject, int apRootHoldObject = 0)
    string name = RPB_Data.GetPropertyOfTypeString(apRootPrisonObject, "Name")

    int i = 0
    while (i < PrisonSlots)
        RPB_Prison prisonRef = self.GetNthPrison(i)
        bool condition = prisonRef.Name == name

        if (apRootHoldObject)
            Faction crimeFaction = RPB_Data.GetPropertyOfTypeForm(apRootHoldObject, "Crime Faction") as Faction
            string hold = crimeFaction.GetName()
        
            if (prisonRef.Hold == hold && prisonRef.Name == name && prisonRef.PrisonFaction == crimeFaction)
                return true
            endif

        elseif (prisonRef.Name == name)
            return true
        endif
        
        i += 1
    endWhile

    return false
endFunction

; ==========================================================

; ==========================================================
;                    Setters / Initializers
; ==========================================================

bool function InitializePrison(string asHold)
    int rootObject      = RPB_Data.GetRootObject(asHold) ; JMap&
    int prisonObject    = RPB_Data.Hold_GetJailObject(rootObject) ; JMap&

    RPB_Prison prisonSlot = self.GetEmptySlot() as RPB_Prison

    if (!prisonSlot)
        Error("There are no Prison Slots available, cannot configure prison for "+ asHold +".")
        self.OnPrisonInitializationFailed(prisonSlot, asHold, rootObject, prisonObject, "No Slots")
        return false
    endif

    if (!__initializePrisonInternal(prisonSlot, asHold, rootObject, prisonObject))
        return false
    endif

    self.OnPrisonConfigured(prisonSlot)
    return true
endFunction

; bool function InitializePrison(string asHold)
;     int rootObject      = RPB_Data.GetRootObject(asHold) ; JMap&
;     int prisonObject    = RPB_Data.Hold_GetJailObject(rootObject) ; JMap&

;     RPB_Prison prisonSlot = self.GetEmptySlot() as RPB_Prison

;     if (!prisonSlot)
;         Error("There are no Prison Slots available, cannot configure prison for "+ asHold +".")
;         self.OnPrisonInitializationFailed(prisonSlot, asHold, rootObject, prisonObject, "No Slots")
;         return false
;     endif

;     if (self.PrisonExists_FromObject(prisonObject))
;         return false
;     endif

;     if (!AssignPrisonHoldProperties(prisonSlot, asHold, rootObject))
;         return false
;     endif


;     prisonSlot.SetFallbackProperty("Name", prisonSlot.PrisonLocation.GetName())
;     prisonSlot.Active = true

;     self.AssignPrisonRootObject(prisonSlot, prisonObject)
;     self.AttachMonitoringObject(prisonSlot, prisonSlot.Monitor.MonitorOn)
;     self.OnPrisonConfigured(prisonSlot)
;     return true
; endFunction

bool function InitializePrisonInSlot(string asHold, int aiSlot)
    int rootObject      = RPB_Data.GetRootObject(asHold) ; JMap&
    int prisonObject    = RPB_Data.Hold_GetJailObject(rootObject) ; JMap&

    if (aiSlot > self.PrisonSlots)
        return false; Out of bounds
    endif

    RPB_Prison slotAlias = self.GetNthAlias(aiSlot) as RPB_Prison
    self.DeletePrison(slotAlias)

    if (!AssignPrisonHoldProperties(slotAlias, asHold, rootObject))
        return false
    endif

    slotAlias.SetFallbackProperty("Name", slotAlias.PrisonLocation.GetName())
    slotAlias.Active = true

    self.AssignPrisonRootObject(slotAlias, prisonObject)
    self.AttachMonitoringObject(slotAlias, slotAlias.Monitor.MonitorOn)
    self.OnPrisonConfigured(slotAlias)

    return true
endFunction

function InitializePrisons()
    int rootObject = RPB_Data.GetRootObject() ; JMap&
    string[] holds = JMap.allKeysPArray(rootObject)

    Debug("PrisonManager::InitializePrisons", "holds: " + holds)

    int i = 0
    while (i < holds.Length)
        self.InitializePrison(holds[i])
        i += 1
    endWhile

    Debug("PrisonManager::InitializePrisons", "Loop Finished")
endFunction

function ReloadPrisonConfig(RPB_Prison apPrison)
    int rootObject      = RPB_Data.GetRootObject(apPrison.Hold) ; JMap&
    int newPrisonObject = RPB_Data.GetPropertyOfTypeObject(rootObject, "Jail") ; JMap& ; Later change to Prison name when 1:N
    int oldPrisonObject = JValue.release(apPrison.GetSerializableRootObject())

    apPrison.SetLocalPropertyOfTypeInt("Root Object", newPrisonObject)
    JValue.retain(newPrisonObject, "PrisonManager::PrisonObjects")
endFunction
 
;/
    Attaches the monitoring object to the Prison, which is responsible for handling events such as
        - PrisonMonitor::OnCellAttach()
        - PrisonMonitor::OnCellDetach()

    as well as ensuring that the Prison Monitor is functional.
    If the monitoring object is null, a default monitoring object will be used.

    RPB_Prison       @apPrison: The Prison to attach the monitoring object to.
    ObjectReference? @akMonitoringObject: The ObjectReference to attach to the Prison.
/;
function AttachMonitoringObject(RPB_Prison apPrison, ObjectReference akMonitoringObject = none)
    ObjectReference monitoringObject        = akMonitoringObject
    ObjectReference defaultMonitoringObject = apPrison.JailCells[0] as ObjectReference
    
    if (!akMonitoringObject && !defaultMonitoringObject)
        EventManager.SendError("Could not attach a monitoring object to Prison " + apPrison.Name + ". (The monitoring object is null)", "PrisonManager::AttachMonitoringObject")
        return
    endif

    if (!akMonitoringObject && defaultMonitoringObject)
        monitoringObject = defaultMonitoringObject
        EventManager.SendInfo("Could not attach a monitoring object to Prison " + apPrison.Name + ". (using the default monitoring object).", "PrisonManager::AttachMonitoringObject")
    endif

    BindAliasTo(apPrison, monitoringObject)
endFunction

function AssignPrisonRootObject(RPB_Prison apPrison, int apRootObject)
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

; ==========================================================

; ==========================================================
;                        Destructors
; ==========================================================

bool function DeletePrison(RPB_Prison apPrison)
    Debug("["+ apPrison.Name +"] PrisonManager::DeletePrison", "Deleted Prison [Name: " + apPrison.Name + ", Hold: " + apPrison.Hold + ", Faction: " + apPrison.PrisonFaction + ", City: " + apPrison.City + "]")

    Utility.Wait(0.1)
    apPrison.Delete()
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

; ==========================================================
;                      Integrity Checking
; ==========================================================

; function VerifyPrisonsIntegrity()
;     ; return
;     ; int root = RPB_Data.GetRootObjectInPath("Holds")
;     ; int castleDourDungeonCell01 = RPB_Data.GetPrisonObject("Holds/Haafingar/Prisons/Castle Dour Dungeon/Cells/cell01.json")
;     ; Debug("PrisonManager::VerifyPrisonsIntegrity", "castleDourDungeonCell01: " + GetContainerList(castleDourDungeonCell01))
;     ; Debug("PrisonManager::VerifyPrisonsIntegrity", "Holds: " + RPB_Data.GetRootObjectInPath("Holds"))
;     ; ; Debug("PrisonManager::VerifyPrisonsIntegrity", "root: " + GetContainerList(root))
;     ; return
;     Debug("PrisonManager::VerifyPrisonsIntegrity", "Verifying Prisons integrity...")

;     int i = 0
;     while (i < PrisonSlots)
;         RPB_Prison prisonRef = self.GetNthAlias(i) as RPB_Prison
;         if (prisonRef.Active)
;             ; self.ReloadPrisonConfig(prisonRef)
;             ; AttachMonitoringObject(prisonRef, prisonRef.Monitor.MonitorOn)
;             ; prisonRef.SetupCells()
;             ; prisonRef.EnsureFunctionalState()
;         endif
;         i += 1
;     endWhile

;     self.RemoveDuplicatePrisons()
; endFunction

function VerifyIntegrity()
    return
    Debug("PrisonManager::VerifyIntegrity", "Verifying Prisons integrity...")
    ; self.ReloadPrisonConfig(self.GetPrison("Falkreath"))
    self.RemoveDuplicatePrisons()
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


; ==========================================================
;                       AI Cell Packages
; ==========================================================

Quest cellPackagesReference

Quest __cellPackages_S_01
Quest __cellPackages_M_01
Quest __cellPackages_L_01
Quest __cellPackages_XL_01
Quest __cellPackages_2XL_01

;/ FastMap<string, FastArray<Quest>> /; int __cellPackageMapping


;/
    Retrieves a Cell Package from the next available Cell Package Group.
    Optionally, retrieving a specific size of the package.

    string  @asCellPackageType: The size of the cell package.

    returns (ReferenceAlias): The actual cell package ReferenceAlias (with an AI Package bound to it).
/;
ReferenceAlias function GetCellPackageOfTypeEx(string asCellPackageType = "S")
    self.PrisonManager()
    Form[] cellPackageGroupsOfSize = self.GetCellPackageGroupsOfSize(asCellPackageType)

    if (!cellPackageGroupsOfSize)
        EventManager.SendError("There are no Cell Package Groups of size: " + asCellPackageType, "PrisonManager::GetCellPackageOfTypeEx")
        Debug("PrisonManager::GetCellPackageOfTypeEx", "Cell Package Type: " + asCellPackageType + " | Cell Package Groups: " + cellPackageGroupsOfSize)
        return none
    endif
    
    Quest selectedCellPackageGroup = none
    int availablePackagesOfGroup = 0

    int i = 0
    bool break = false
    while (i < cellPackageGroupsOfSize.Length || !break)
        selectedCellPackageGroup = cellPackageGroupsOfSize[i] as Quest

        Debug("PrisonManager::GetCellPackageOfTypeEx", "["+ i +"] Cell Package Type: " + asCellPackageType + " | Cell Package Group: " + selectedCellPackageGroup)

        if (selectedCellPackageGroup != none)
            availablePackagesOfGroup = selectedCellPackageGroup.GetNumAliases()

            if (availablePackagesOfGroup > 0)
                break = true
            endif
        endif
        i += 1
    endWhile

    if (selectedCellPackageGroup == none)
        EventManager.SendError("Could not select a Cell Package Group of size: " + asCellPackageType, "PrisonManager::GetCellPackageOfTypeEx")
        return none
    endif

    i = 0
    while (i < availablePackagesOfGroup)
        string packageName

        if (i >= 100)
            packageName = asCellPackageType + "_0" + i

        elseif (i >= 10)
            packageName = asCellPackageType + "_00" + i

        else
            packageName = asCellPackageType + "_000" + i
        endif

        ReferenceAlias currentPackage = self.GetCellPackageByNameEx(selectedCellPackageGroup, packageName)

        if (currentPackage.GetReference() == none)
            DebugWithArgs("PrisonManager::GetCellPackageOfTypeEx", asCellPackageType, "Retrieving Cell Package: " + packageName + " (Nth Alias: "+ (currentPackage as Alias).GetID() +")")
            return currentPackage
        endif

        i += 1
    endWhile

    EventManager.SendWarning("There are no available AI Cell packages to assign!", "PrisonManager::GetCellPackageOfTypeEx")
    return none
endFunction

ReferenceAlias function GetCellPackageByNameEx(Quest akCellPackageGroup, string asCellPackageName)
    return akCellPackageGroup.GetAliasByName(asCellPackageName) as ReferenceAlias
endFunction

ReferenceAlias function GetCellPackageByIndexEx(Quest akCellPackageGroup, int aiCellPackageIndex)
    return akCellPackageGroup.GetNthAlias(aiCellPackageIndex) as ReferenceAlias
endFunction

;/
    Retrieves all of the PackageGroups of a specific size.

    string  @asCellPackageSize: The size of the cell package.

    returns (Form[]): The array of cell package groups of the specified size.
/;
Form[] function GetCellPackageGroupsOfSize(string asCellPackageSize)
    ; TODO: Validate if package group size exists (S, M, L, XL, 2XL)

    int cellPackageGroupsOfSize = \
    FastMap_GetObject( \ 
        __cellPackageMapping, \
        asCellPackageSize \
    )

    Debug("PrisonManager::GetCellPackageGroupsOfSize", "Cell Package Size: " + asCellPackageSize + " | Cell Package Groups: " + FastArray_ToFormArray(cellPackageGroupsOfSize))

    return FastArray_ToFormArray(cellPackageGroupsOfSize)
endFunction


; ==========================================================
;                         private
; ==========================================================

bool function __initializePrisonInternal(RPB_Entity apEntity, string asHold, int apHoldRootObject, int apPrisonRootObject)
    if (self.PrisonExists_FromObject(apPrisonRootObject))
        return false
    endif

    if (!AssignPrisonHoldProperties(apEntity as RPB_Prison, asHold, apHoldRootObject))
        return false
    endif

    RPB_Prison prison = apEntity as RPB_Prison

    prison.SetFallbackProperty("Name", prison.PrisonLocation.GetName())
    prison.Active = true

    self.AssignPrisonRootObject(prison, apPrisonRootObject)
    self.AttachMonitoringObject(prison, prison.Monitor.MonitorOn)

    return true
endFunction

; Calls only the CTOR
event OnInit()
    self.PrisonManager()
endEvent