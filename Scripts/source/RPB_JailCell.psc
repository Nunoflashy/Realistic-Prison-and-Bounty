scriptname RPB_JailCell extends RPB_SerializableObjectReference

import Math
import RPB_Config
import RPB_Utility
import RPB_Memory

; ==========================================================
;                     Script References
; ==========================================================

RPB_API property API
    RPB_API function get()
        return Prison.API
    endFunction
endProperty

RPB_EventManager property EventManager
    RPB_EventManager function get()
        return API.EventManager
    endFunction
endProperty

; ==========================================================

string property Name
    string function get()
        return self.TryGetString("Name")
    endFunction
endProperty

RPB_Prison property Prison
    RPB_Prison function get()
        return __getPrison()
    endFunction
endProperty

RPB_CellDoor property CellDoor
    RPB_CellDoor function get()
        return __getCellDoor()
    endFunction
endProperty

Form[] __interiorMarkers
Form[] property InteriorMarkers
    Form[] function get()
        return __interiorMarkers
    endFunction
endProperty

Form[] __exteriorMarkers
Form[] property ExteriorMarkers
    Form[] function get()
        return __exteriorMarkers
    endFunction
endProperty

bool property HasInteriorMarkers
    bool function get()
        return self.InteriorMarkers.Length > 0
    endFunction
endProperty

bool property HasExteriorMarkers
    bool function get()
        return self.ExteriorMarkers.Length > 0
    endFunction
endProperty

Form[] property Prisoners
    Form[] function get()
        return FastArray_ToFormArray( \ 
            FastMap_Values(__prisonersInCell) \
        )
    endFunction
endProperty

Form[] property FemalePrisoners
    Form[] function get()
        return self.GetFemalePrisoners()
    endFunction
endProperty

Form[] property MalePrisoners
    Form[] function get()
        return self.GetMalePrisoners()
    endFunction
endProperty

; The beds inside this cell
Form[] __beds
Form[] property Beds
    Form[] function get()
        if (!__beds)
            __beds = self.GetConfigObjects("Beds")
        endif
        return __beds
    endFunction
endProperty

; Containers in the cell, such as Sacks, Wardrobes, Dressers, Chests, Bedside Tables...
Form[] __containers
Form[] property Containers
    Form[] function get()
        if (!__containers)
            __containers = self.GetConfigObjects("Containers")
        endif
        return __containers
    endFunction
endProperty

; Other miscellaneous props in a cell, such as buckets, plates, food, etc...
Form[] __otherProps
Form[] property OtherProps
    Form[] function get()
        if (!__otherProps)
            __otherProps = self.GetConfigObjects("Props")
        endif
        return __otherProps
    endFunction
endProperty

bool property HasPrisoners
    bool function get()
        return self.Prisoners.Length > 0
    endFunction
endProperty

bool property HasBeds
    bool function get()
        return __beds.Length > 0
    endFunction
endProperty

bool property HasContainers
    bool function get()
        return __containers.Length > 0
    endFunction
endProperty

bool property HasOtherProps
    bool function get()
        return __otherProps.Length > 0
    endFunction
endProperty

bool property IsEmpty
    bool function get()
        return self.PrisonerCount == 0
    endFunction
endProperty

bool property IsFull
    bool function get()
        return self.PrisonerCount >= self.MaxPrisoners
    endFunction
endProperty

bool property IsOvercrowded
    bool function get()
        return self.PrisonerCount > self.MaxPrisoners
    endFunction
endProperty

; Whether to allow more prisoners to live in this cell (despite there not being enough beds for all, this bypasses that.)
bool __allowOvercrowding
bool property AllowOvercrowding
    bool function get()
        if (!__allowOvercrowding)
            __allowOvercrowding = self.GetOptionOfTypeBool("Allow Overcrowding")
        endif

        return __allowOvercrowding
    endFunction
endProperty

bool property IsAvailable
    bool function get()
        return (self.PrisonerCount < self.MaxPrisoners) || self.AllowOvercrowding
    endFunction
endProperty

bool __isFemaleOnly
bool property IsFemaleOnly
    bool function get()
        return __isFemaleOnly
    endFunction
endProperty

bool __isMaleOnly
bool property IsMaleOnly
    bool function get()
        return __isMaleOnly
    endFunction
endProperty

bool property IsGenderExclusive
    bool function get()
        return IsMaleOnly || IsFemaleOnly
    endFunction
endProperty

; ==========================================================
;                       Private Getters
; ==========================================================

bool __scannedBeds
bool __scannedContainers
bool __scannedOtherProps

; ==========================================================

; The approximate size of this cell from the center point (this reference) as a radius
float __cellRadius
float property CellRadius
    float function get()
        if (!__cellRadius)
            __cellRadius = self.GetOptionOfTypeFloat("Scan//Interior Radius")
        endif

        return __cellRadius
    endFunction
endProperty

; The amount of times a scan should be performed
int __scanIterations
int property ScanIterations
    int function get()
        if (!__scanIterations)
            __scanIterations = self.GetOptionOfTypeInt("Scan//Iterations")
        endif

        return __scanIterations
    endFunction
endProperty

; How many prisoners can this jail cell take (if AllowOvercrowding is false)
int __maxPrisoners
int property MaxPrisoners
    int function get()
        if (!__maxPrisoners)
            if (self.HasOption("Maximum Prisoners"))
                __maxPrisoners = self.GetOptionOfTypeInt("Maximum Prisoners")
            endif
            
            if (!__maxPrisoners)
                ; Since there's no Max Prisoners property, make the max the same as the number of beds in the cell
                __maxPrisoners = self.GetConfigObjects("Beds").Length

                ; Default to 1 if no config found
                if (!__maxPrisoners)
                    __maxPrisoners = 1
                endif

            endif
        endif

        return __maxPrisoners
    endFunction
endProperty

string property DefaultPackageSize
    string function get()
        return "S"
    endFunction
endProperty

string __packageSize
string property PackageSize
    string function get()
        if (self.HasOption("Package"))
            __packageSize = self.GetOptionOfTypeString("Package")
            ; Debug("["+ ID +"] JailCell:PackageSize", "__packageSize: " + __packageSize)
        else
            DebugWarn("["+ ID +"] JailCell:PackageSize", "Returning default package size: S")
            return self.DefaultPackageSize
        endif

        return __packageSize
    endFunction
endProperty

int __prisonersInCell

int property PrisonerCount
    int function get()
        return Object_Size(__prisonersInCell)
    endFunction
endProperty

; ==========================================================

function JailCell()
    
endFunction

ReferenceAlias function GetSuitableCellPackage()
    return Prison.PrisonManager.GetCellPackageOfTypeEx(self.PackageSize)
endFunction

;/
    Randomly generates goodies such as Lockpicks and Keys for this Cell if applicable.
/;
function DetermineGoodies()
    Form lockpick = RPB_Utility.GetFormOfType("Lockpick")

    if (self.HasContainers)
        ObjectReference chosenContainer = self.Containers[Utility.RandomInt(0, self.Containers.Length - 1)] as ObjectReference
        chosenContainer.AddItem(lockpick, 1, true)
        Debug("[Prison: "+ self.Prison.Name +"] JailCell::DetermineGoodies", "Added 1 Lockpick to container " + chosenContainer + " ("+ chosenContainer.GetBaseObject().GetName() +")")
    endif

    if (self.HasOtherProps)
        ObjectReference chosenProp = self.OtherProps[Utility.RandomInt(0, self.OtherProps.Length - 1)] as ObjectReference
        chosenProp.PlaceAtMe(lockpick, 1)
        Debug("[Prison: "+ self.Prison.Name +"] JailCell::DetermineGoodies", "Placed 1 Lockpick near misc prop " + chosenProp + " ("+ chosenProp.GetBaseObject().GetName() +")")
    endif
endFunction

function DetermineMarkers()
    Form[] interiorChildMarkers = self.GetPropertyOfTypeFormArray("Interior")
    Form[] exteriorChildMarkers = self.GetPropertyOfTypeFormArray("Exterior")

    if (!exteriorChildMarkers)
        ; Important, these markers are used in Scenes, where the guard will be standing
        EventManager.SendError("Failed to determine exterior markers for " + ID, "["+ Prison.Name +"] ["+ ID +"] JailCell::DetermineMarkers")
        return
    endif

    if (!interiorChildMarkers)
        ; Not as important as Exterior, Main Interior is used most of the time, this is unused for now
        ; EventManager.SendWarning("Failed to determine interior markers for " + ID, "["+ Prison.Name +"] ["+ ID +"] JailCell::DetermineMarkers")
    endif

    int arrayInteriorChildMarkers = FastArray_FromFormArray(interiorChildMarkers)
    int arrayExteriorChildMarkers = FastArray_FromFormArray(exteriorChildMarkers)

    int arrayAllInteriorMarkers = FastArray("<Form>")
    int arrayAllExteriorMarkers = FastArray("<Form>")
    
    ; Add parent
    FastArray_AddForm(arrayAllInteriorMarkers, self)

    ; Merge the arrays
    FastArray_AddFromArray(arrayAllInteriorMarkers, arrayInteriorChildMarkers)
    FastArray_AddFromArray(arrayAllExteriorMarkers, arrayExteriorChildMarkers)

    ; Set properties
    __interiorMarkers       = FastArray_ToFormArray(arrayAllInteriorMarkers)
    __exteriorMarkers       = FastArray_ToFormArray(arrayAllExteriorMarkers)
endFunction

function RefreshOptions()
    __allowOvercrowding = false
    __cellRadius        = 0.0
    __scanIterations    = 0
    __maxPrisoners      = 0
    __packageSize       = none

    Array_ClearForms(__beds)
    Array_ClearForms(__containers)
    Array_ClearForms(__otherProps)

    ; TODO: Refresh cell doors options
endFunction

; =========================================================
;                           Cell                        
; =========================================================

function SetAsFemaleOnly()
    __isFemaleOnly = true
    Debug("JailCell::SetAsFemaleOnly", self + " has been set as a female only cell.")
endFunction

function SetAsMaleOnly()
    __isMaleOnly = true
    Debug("JailCell::SetAsMaleOnly", self + " has been set as a male only cell.")
endFunction

function SetExclusiveToPrisonerSex(RPB_Prisoner apPrisoner)
    if (apPrisoner.IsMale)
        self.SetAsMaleOnly()

    elseif (apPrisoner.IsFemale)
        self.SetAsFemaleOnly()
    endif
endFunction

function RemoveGenderExclusiveness()
    if (!__isFemaleOnly && !__isMaleOnly)
        return
    endif

    __isFemaleOnly  = false
    __isMaleOnly    = false

    ; Debug("JailCell::RemoveGenderExclusiveness", self + " is no longer a gender exclusive cell.")
endFunction

string function GetAcceptedGender()
    if (self.IsFemaleOnly)
        return "Female"
    elseif (self.IsMaleOnly)
        return "Male"
    else
        return "All"
    endif

endFunction

function ScanCellDoor(bool abForceAssignment = false)
    if (CellDoor && !abForceAssignment)
        return
    endif

    ObjectReference baseCellDoor = Prison.GetPropertyOfTypeForm("Base Cell Door") as ObjectReference
    RPB_CellDoor _cellDoor       = GetNearestJailDoorOfTypeEx(baseCellDoor, self, 4000) as RPB_CellDoor

    ; Not in the same cell (location), would happen when teleporting from a jail to another, for example.
    if (self.GetParentCell() != _cellDoor.GetParentCell())
        return
    endif

    if (_cellDoor)
        ; Bind the cell door to the jail cell
        self.BindCellDoor(_cellDoor)
        Debug("["+ self +"] JailCell::ScanCellDoor", "Could not find a configured cell door, scanning for the nearest one!")
        return
    endif

    Error("["+ self +"] JailCell::ScanCellDoor", "Could not assign a cell door to this jail cell!")
endFunction

; Unreliable, since it can scan beds from other cells that are near one of the scanned beds in this cell. (this is because beds are not in the same place on all the cells, and the radius of the scan will get other beds from other cells.)
function ScanBeds()
    int bedExclusions   = FastMap("<string>")
    int bedsScanned     = FastArray("<Form>")

    FormList RPB_BedFormList = GetFormFromMod(0x1CDAA) as FormList

    Debug("[Prison: "+ self.Prison.Name +"] JailCell::ScanBeds", "Scan Iterations: " + self.ScanIterations + ", Cell Radius: " + self.CellRadius)

    int i = 0
    while (i < self.ScanIterations)
        ObjectReference scannedBed = Game.FindRandomReferenceOfAnyTypeInListFromRef(RPB_BedFormList, self, self.CellRadius)

        if (scannedBed && !FastMap_HasKey(bedExclusions, scannedBed.GetFormID()))
            FastMap_SetForm(bedExclusions, scannedBed.GetFormID(), scannedBed)
            FastArray_AddForm(bedsScanned, scannedBed) ; Add the bed to this local array
            Debug("[Prison: "+ self.Prison.Name +"] JailCell::ScanBeds", "Scanned " + scannedBed + " (Name: "+ scannedBed.GetBaseObject().GetName() +") Bed in " + self + ", Max Prisoners for this Cell: " + self.MaxPrisoners)
        endif
        i += 1
    endWhile
    
    ; If there were beds caught in the scan, add it to the cell beds array
    if (Object_Size(bedsScanned) > 0)
        __beds = FastArray_ToFormArray(bedsScanned)
        __scannedBeds = true
        __maxPrisoners = Object_Size(bedsScanned)
    endif

    Debug("[Prison: "+ self.Prison.Name +"] JailCell::ScanBeds", "Beds in " + self + ": " + self.Beds)
endFunction

function ScanContainers()
    FormList RPB_ContainerFormList = GetFormFromMod(0x1CDAB) as FormList
    int containersAlreadyAdded  = FastMap("<string>")
    int containersScanned       = FastArray("<Form>")

    int i = 0
    while (i < self.ScanIterations)
        ObjectReference scannedContainer = Game.FindRandomReferenceOfAnyTypeInListFromRef(RPB_ContainerFormList, self, self.CellRadius)
        bool containerExistsInList = FastMap_HasKey(containersAlreadyAdded, scannedContainer.GetFormID())
        if (scannedContainer && !containerExistsInList)
            FastMap_SetForm(containersAlreadyAdded, scannedContainer.GetFormID(), scannedContainer)
            FastArray_AddForm(containersScanned, scannedContainer)
            Debug("[Prison: "+ self.Prison.Name +"] JailCell::ScanContainers", "Scanned " + scannedContainer + " (Name: "+ scannedContainer.GetBaseObject().GetName() +") container in " + self)
        endif
        i += 1
    endWhile

    if (Object_Size(containersScanned) > 0)
        __containers = FastArray_ToFormArray(containersScanned)
        __scannedContainers = true
    endif

    Debug("[Prison: "+ self.Prison.Name +"] JailCell::ScanContainers", "Containers in " + self + ": " + self.Containers + " Containers.Length: " + self.Containers.Length)
endFunction

function ScanMiscProps()
    FormList RPB_MiscPropsFormList = GetFormFromMod(0x1CDAC) as FormList
    int propsAlreadyAdded  = FastMap("<string>")
    int propsScanned       = FastArray("<Form>")

    int i = 0
    while (i < self.ScanIterations)
        ObjectReference scannedProp = Game.FindRandomReferenceOfAnyTypeInListFromRef(RPB_MiscPropsFormList, self, self.CellRadius)
        bool propExistsInList = FastMap_HasKey(propsAlreadyAdded, scannedProp.GetFormID())
        if (scannedProp && !propExistsInList)
            FastMap_SetForm(propsAlreadyAdded, scannedProp.GetFormID(), scannedProp)
            FastArray_AddForm(propsScanned, scannedProp)
            Debug("[Prison: "+ self.Prison.Name +"] JailCell::ScanMiscProps", "Scanned " + scannedProp + " (Name: "+ scannedProp.GetBaseObject().GetName() +") prop in " + self)
        endif
        i += 1
    endWhile

    if (Object_Size(propsScanned) > 0)
        __otherProps = FastArray_ToFormArray(propsScanned)
        __scannedOtherProps = true
    endif

    Debug("[Prison: "+ self.Prison.Name +"] JailCell::ScanMiscProps", "Props in " + self + ": " + self.OtherProps)
endFunction

ObjectReference function GetNthMarker(int aiIndex, string asInteriorOrExterior = "Interior")
    if (asInteriorOrExterior == "Interior")
        Form[] _interiorMarkers = self.InteriorMarkers
        if (_interiorMarkers.Length <= aiIndex)
            return _interiorMarkers[aiIndex] as ObjectReference
        else
            Error("Marker falls outside of the bounds of the array!")
            DebugError("JailCell::GetNthMarker", "Marker falls outside of the bounds of the array!")
        endif

    elseif (asInteriorOrExterior == "Exterior")
        Form[] _exteriorMarkers = self.ExteriorMarkers
        if (_exteriorMarkers.Length <= aiIndex)
            return _exteriorMarkers[aiIndex] as ObjectReference
        else
            Error("Marker falls outside of the bounds of the array!")
            DebugError("JailCell::GetNthMarker", "Marker falls outside of the bounds of the array!")
        endif
    endif

    return none
endFunction

ObjectReference function GetRandomMarker(string asInteriorOrExterior = "Interior")
    if (asInteriorOrExterior == "Interior")
        ; return self.GetNthMarker(Utility.RandomInt(0, self.InteriorMarkers.Length - 1), "Interior")
        return self.InteriorMarkers[Utility.RandomInt(0, self.InteriorMarkers.Length - 1)] as ObjectReference

    elseif (asInteriorOrExterior == "Exterior")
        ; return self.GetNthMarker(Utility.RandomInt(0, self.ExteriorMarkers.Length - 1), "Exterior")
        return self.ExteriorMarkers[Utility.RandomInt(0, self.ExteriorMarkers.Length - 1)] as ObjectReference
    endif

    return none
endFunction

; =========================================================
;                         Prisoners                        
; =========================================================

;/
    Checks whether this cell has a specific prisoner in it.

    RPB_Prisoner @apPrisoner: The prisoner to check for.

    returns (bool): true if the prisoner is in this cell, false otherwise.
/;
bool function HasPrisoner(RPB_Prisoner apPrisoner)
    return FastMap_HasKey(__prisonersInCell, apPrisoner.GetIdentifier())
endFunction

;/
    Checks whether this cell has prisoners of the specified gender.

    string  @asGender: The gender to check for.
    bool?   @abOnlySpecifiedGender: If true, only checks if all prisoners are of the specified gender.

    returns (bool): true if there are prisoners of the specified gender in this cell, false otherwise.
/;
bool function HasPrisonersOfGender(string asGender, bool abOnlySpecifiedGender = false)
    return RPB_Utility.HasActorsOfGenderInList(self.Prisoners, asGender, abOnlySpecifiedGender)
endFunction

;/
    Checks whether this cell has female prisoners.

    bool?   @abStrictlyFemales: If true, only checks if all prisoners are females.

    returns (bool): true if there are female prisoners in this cell, false otherwise.
/;
bool function HasFemales(bool abStrictlyFemales = false)
    return RPB_Utility.HasFemalesInList(self.Prisoners, abStrictlyFemales)
endFunction

;/
    Checks whether this cell has male prisoners.

    bool?   @abStrictlyMales: If true, only checks if all prisoners are males.

    returns (bool): true if there are male prisoners in this cell, false otherwise.
/;
bool function HasMales(bool abStrictlyMales = false)
    return RPB_Utility.HasMalesInList(self.Prisoners, abStrictlyMales)
endFunction

; Retrieves the female prisoners living in this jail cell.
Form[] function GetFemalePrisoners()
    return RPB_Utility.GetFemalesInList(self.Prisoners)
endFunction

; Retrieves the male prisoners living in this jail cell.
Form[] function GetMalePrisoners()
    return RPB_Utility.GetMalesInList(self.Prisoners)
endFunction

function RemovePrisoner(RPB_Prisoner apPrisoner)
    if (apPrisoner)
        self.UnregisterPrisoner(apPrisoner)
    endif
endFunction

; =========================================================
;                          Events
; =========================================================

event OnPrisonerRegister(RPB_Prisoner apPrisoner)
    if (!self.CellDoor)
        RPB_CellDoor configuredCellDoor = self.GetPropertyOfTypeFormArray("Cell Doors")[0] as RPB_CellDoor ; Index is temporary, for now only use 1st cell door
        self.BindCellDoor(configuredCellDoor)
        Debug("["+ ID +"] JailCell::OnPrisonerRegister", "Rebinding Cell Door!")
    endif
    self.DetermineCellParameters()
    Debug("JailCell::OnPrisonerRegister", "Cell Properties: " + self.DEBUG_GetCellProperties())
endEvent

event OnPrisonerUnregister(RPB_Prisoner apPrisoner)
    self.DetermineCellParameters()
    ; Debug("JailCell::OnPrisonerUnregister", "Cell Properties: " + self.DEBUG_GetCellProperties())
    Debug("("+ ID +") JailCell::OnPrisonerUnregister", "Unregistered Prisoner: " + apPrisoner.Name)
endEvent

event OnPrisonerOpenCellDoor(RPB_CellDoor akCellDoor, RPB_Prisoner apPrisoner)
    if (akCellDoor.EscapeTriggerDoor)
        apPrisoner.SetEscaped()
    endif

    Debug("["+ self +"] JailCell::OnPrisonerOpenCellDoor", apPrisoner + " has opened one of their jail cell doors: " + akCellDoor)
endEvent

event OnGuardOpenCellDoor(RPB_CellDoor akCellDoor, Actor akGuard)

endEvent

; =========================================================
;                       Trigger Events
; =========================================================

event OnTriggerEnter(ObjectReference akObjectRef)
    Debug("["+ self +"] JailCell::OnTriggerEnter", "Prisoner entered the trigger")
endEvent

event OnTriggerLeave(ObjectReference akObjectRef)
    Debug("["+ self +"] JailCell::OnTriggerLeave", "Prisoner left the trigger")
endEvent

; =========================================================
;                         Management
; =========================================================

; string function Rules(string rule)
;     return \ 
;         "required: [Cell Doors, Lock//Level]," + \
;         "string: [Lock//Level]," + \
;         "Form[]: [Cell Doors]," + \
; endFunction

bool function ShouldPerformScan(string asScanTarget)
    if (!self.HasOption("Scan//Iterations") || !self.HasOption("Scan//Interior Radius"))
        ; Iterations and Radius not configured, cannot perform scan
        return false
    endif

    if (asScanTarget == "Beds")
        return !self.HasObjects("Beds") && !self.HasOption("Maximum Prisoners")

    elseif (asScanTarget == "Containers")
        return !self.HasObjects("Containers")

    elseif (asScanTarget == "Props")
        return !self.HasObjects("Props")
    endif

    Error("JailCell::ShouldPerformScan", "Unable to perform scan for the jail cell, the scan target " + asScanTarget + " is invalid!")
    return false
endFunction

string function GetName()
    return "Jail Cell"
endFunction

bool function IsInitialized()
    return __prison && __cellDoor
endFunction

function Initialize(RPB_Prison apPrison)
    ; self.SetFallbackID(self)
    ; self.SetFallbackName(self)
    ; Set the persistent Prison UUID
    ; RPB_StorageVars.SetStringOnReference("Prison UUID", self, apPrison.UUID)

    ; if (self.GetFormID() == GetFormFromMod(0x25F49).GetFormID())
    ;     Debug("["+ apPrison.Name +"] ["+ self +"] JailCell::Initialize", "Contents: " + GetContainerList(self.GetSerializableRootObject()))

    ;     return
    ; endif

    self.RefreshOptions()
    ; Link the actual Prison with this Jail Cell
    self.BindPrison(apPrison)

    RPB_CellDoor configuredCellDoor = self.GetPropertyOfTypeFormArray("Cell Doors")[0] as RPB_CellDoor ; Index is temporary, for now only use 1st cell door

    if (configuredCellDoor)
        ; Bind the cell door to the jail cell
        self.BindCellDoor(configuredCellDoor)
    endif

    self.DisableOwnership()

    ; Determine all markers for this cell
    self.DetermineMarkers()
endFunction

function Uninitialize()
    Debug("[Prison: "+ Name +"] Cell::Uninitialize", "Unitializing jail cell: " + self)

    self.RefreshOptions()
    __prison    = none
    __cellDoor  = none ; Later needs to handle 1:N
endFunction

function BindPrison(RPB_Prison apPrison)
    __prison = apPrison

    if (!self.Prison)
        Debug("["+ self +"] JailCell::BindPrison", "Could not bind the jail cell " + self + " to the Prison " + apPrison)
        return
    endif

    ; Bind the UUID persistently, __prison is a weak ref, it will be reset by Skyrim after 10 days (maybe not anymore with the Respawn flag unchecked for the cells in CK)
    self.SetLocalPropertyOfTypeString("Prison UUID", apPrison.UUID)
endFunction

function BindCellDoor(RPB_CellDoor akCellDoor)
    if (!akCellDoor)
        return
    endif

    ; Bind the cell door to this jail cell
    __cellDoor = akCellDoor

    ; Bind this jail cell to the cell door (to retrieve this from the cell door)
    akCellDoor.BindCell(self)

    ; Initialize the cell door properties
    akCellDoor.Initialize()

    Error("Could not bind cell door to the jail cell " + self, (!self.CellDoor && self.CellDoor != akCellDoor))
endFunction

function DisableOwnership()
    Form[] _beds = self.Beds

    int i = 0
    while (i < _beds.Length)
        ObjectReference bed = _beds[i] as ObjectReference
        if (bed && bed.GetActorOwner() != none)
            bed.SetActorOwner(none)
            string bedName = bed.GetBaseObject().GetName()
            Debug("["+ Prison.Name +"] ["+ ID +"] JailCell::DisableOwnership", bed + " (" + bedName + ") is now unoccupied.")
        endif
        i += 1
    endWhile
endFunction

;/
    Registers the passed in Prisoner to this Jail Cell,
    the value is stored as:
    Cell[FormID] = 0x14
/;
function RegisterPrisoner(RPB_Prisoner apPrisoner)
     ; Retaining in memory may be a problem, after this Reference is lost (10d+ passes), it will not be released and the handle will be lost.
    __prisonersInCell = Object_CreateIfNotExists(__prisonersInCell, FastMap("<string>", retain = true))

    FastMap_SetForm(__prisonersInCell, apPrisoner.GetIdentifier(), apPrisoner.GetActor())

    ; Pass the reference to the Prisoner
    apPrisoner.SetForm("Cell", self, "Jail")

    self.OnPrisonerRegister(apPrisoner)
endFunction

function UnregisterPrisoner(RPB_Prisoner apPrisoner)
    FastMap_RemoveKey(__prisonersInCell, apPrisoner.GetIdentifier())
    self.OnPrisonerUnregister(apPrisoner)
endFunction

function DetermineCellParameters()
    if (self.PrisonerCount > 0)
        Form prisonerForm = FastMap_GetForm(__prisonersInCell, FastMap_GetNthKey(__prisonersInCell, 0)) ; Get the first prisoner reference
        RPB_Prisoner prisonerRef = Prison.GetPrisonerReference(prisonerForm as Actor)

        ; If the first prisoner will be/is stripped naked / to underwear, set this cell as gender exclusive for them if the cell is not yet gender exclusive,
        ; this means that the first prisoner has not been stripped naked or to underwear.
        ; (Not implemented yet): We should probably make the first prisoner strip off (maybe in some condition, such as having more than a day left of sentence for example.)
        if (!self.IsGenderExclusive && ((prisonerRef.WillBeStrippedNaked || prisonerRef.WillBeStrippedToUnderwear) || (prisonerRef.IsStrippedNaked || prisonerRef.IsStrippedToUnderwear)))
            self.SetExclusiveToPrisonerSex(prisonerRef)
        endif

    else
        ; No prisoners in this cell
        ; Unset this cell as being female/male only, as it is now empty
        self.RemoveGenderExclusiveness()
    endif
endFunction

event OnInit()
    ; Debug("["+ self +"] JailCell::OnInit", "Initialized " + self)
    ; Debug("["+ self +"] JailCell::OnInit", "Initialized Cell: (ID: " + self.ID + ") (Name: "+ self.Name +") (" + self + ") (Markers: "+ self.InteriorMarkers +") (Prison: "+ self.Prison +") (Prisoners: "+ self.Prisoners +") (CellDoor: "+ self.CellDoor +")")
    ; Debug("["+ self +"] JailCell::OnInit", "Initialized Cell: (Prison: " + self.Prison + ")")
    ; Debug("["+ self +"] JailCell::OnInit", "Initialized Cell: (CellDoor: " + self.CellDoor + ")")

endEvent


; =========================================================
;                    NPC Sanity Checking                      
; =========================================================
;/
    Should only happen the first time the player visits the NPC prisoner
    and at some points where an AI Package is overridden, such as the Solitude execution scene for the NPC's there
    if they were to be imprisoned.

    NPC Sanity checking is used because Skyrim NPC's have caveats to them which prevents the prison system to work without flaws as it would for the player.
    For instance, NPC's can execute AI packages at any time if they have scripted events (such as the Solitude opening execution scene), which, in this case,
    makes them walk to the place, essentially leaving the prison.

    Another problem is with NPC clothing, NPC's have their clothes set up at the Actor level, which means that they will recover them as soon as the Player has unloaded the cell (out of the area).
    This means that for an NPC that has been stripped off their clothing for example, they will recover it when the Player leaves, which defeats the purpose of stripping.
    To get around this, these sanity checks essentially remove their clothing again, as well as perform any additional checking that ensures that they keep the state they had at the time of their
    incarceration.
/;

float __npcSanityCheckPreCheckUpdateTime
float __npcSanityCheckPostCheckUpdateTime
int   __npcSanityCheckUpdateTries
float __npcSanityCheckElapsedTime
bool __npcSanityCheckIsCellAttachedOrDetached
bool __npcSanityCheckAllPrisoners
bool __npcSanityCheckReset
RPB_Prisoner __npcSanityCheckSelectedPrisoner

;/
    Registers this jail cell for NPC sanity checking, ensuring they remain there.

    float?          @afPreCheckUpdateTime: The update window upon registering the event.
    float?          @afPostCheckUpdateTime: The update window after the event has been registered, until it is unregistered.
    RPB_Prisoner?   @apPrisoner: The prisoner to register for sanity checking, if none, all prisoners in the jail cell will be registered.
/;
function RegisterForSanityChecking(float afPreCheckUpdateTime = 4.0, float afPostCheckUpdateTime = 1.0, int aiUpdateTries = 10, RPB_Prisoner apPrisoner = none)
    __npcSanityCheckPostCheckUpdateTime = afPostCheckUpdateTime
    __npcSanityCheckAllPrisoners        = apPrisoner == none
    __npcSanityCheckSelectedPrisoner    = apPrisoner
    __npcSanityCheckReset               = false
    __npcSanityCheckPreCheckUpdateTime  = afPreCheckUpdateTime

    GotoState("NPC_SanityChecking")
    RegisterForSingleUpdate(afPreCheckUpdateTime)
endFunction

;/
    Resets this jail cell from NPC sanity checking, ensuring a clean state for next check.
/;
function ResetSanityChecking()
    __npcSanityCheckPostCheckUpdateTime = 0.0
    __npcSanityCheckAllPrisoners        = false
    __npcSanityCheckSelectedPrisoner    = none
    __npcSanityCheckReset               = false

    ; Debug(self +" JailCell::ResetSanityChecking", "Sanity checking state has been reset.")
    ; Trace(self +" JailCell::ResetSanityChecking", \
    ;     "\n\t __npcSanityCheckPostCheckUpdateTime: "    + __npcSanityCheckPostCheckUpdateTime + \
    ;     "\n\t __npcSanityCheckAllPrisoners: "           + __npcSanityCheckAllPrisoners + \
    ;     "\n\t __npcSanityCheckSelectedPrisoner: "       + __npcSanityCheckSelectedPrisoner + \
    ;     "\n\t __npcSanityCheckReset: "                  + __npcSanityCheckReset \
    ; )
endFunction

;/
    Performs the actions when OnCellAttach() / OnAttachedToCell() and OnCellDetach() / OnDetachedFromCell() events happen.
/;
function __onCellAttachAndDetachEvent()
    if (__npcSanityCheckIsCellAttachedOrDetached)
        return
    endif

    int i = 0
    while (i < Prisoners.Length)
        apPrisoner.EnableAI(!apPrisoner.IsFarFromPlayer())

        RPB_Prisoner apPrisoner = Prison.AwaitPrisonerReference(Prisoners[i] as Actor)
        if (apPrisoner.IsImprisoned)
            apPrisoner.EnableAI(!apPrisoner.IsFarFromPlayer())
            
            apPrisoner.NPC_UpdateStripping()
            apPrisoner.NPC_UpdateClothing()
            apPrisoner.NPC_UpdateUnderwear()

            ; Debug("("+ ID +") (-) JailCell::OnCellAttachAndDetachEvent", "("+ apPrisoner.GetActor() +")")

            if (apPrisoner.ShouldBeInCell && !apPrisoner.IsInCell)
                apPrisoner.MoveTo(self)                                           ; Move the prisoner to this jail cell
                apPrisoner.NPC_BindToCell()                                       ; Prisoner should already be bound to cell, but just in case they aren't
                RegisterForSingleUpdate(__npcSanityCheckPostCheckUpdateTime)      ; Keep updating until the prisoner is in the cell
                ; isStateValid = false
            endif
        endif
        i += 1
    endWhile

    ; Debug("("+ ID +") (-) JailCell::OnCellAttachAndDetachEvent", "Prisoners: " + Prisoners)

    ; self.RegisterForSanityChecking(0.1)
    ; self.PerformPrisonersSanityCheck()
    __lock_onCellAttachAndDetachEvents()
endFunction

;/
    Ensures only one of the events is happening at the given time,
    so as to not overlap checks and actions.
/;
function __lock_onCellAttachAndDetachEvents()
    __npcSanityCheckIsCellAttachedOrDetached = true
    Utility.Wait(__npcSanityCheckPostCheckUpdateTime) ; Ensure a lock of the time configured for post event delay
    __npcSanityCheckIsCellAttachedOrDetached = false
endFunction

; When the player leaves the location of this jail cell
event OnCellDetach()
    __onCellAttachAndDetachEvent()
endEvent

; When the player is in the same cell as this jail cell
event OnCellAttach()
    ; Debug("["+ self +"] JailCell::OnCellAttach", "Cell: (ID: " + self.ID + ") (" + self + ") (Markers: "+ self.InteriorMarkers +") (Prison: "+ self.Prison.Name +") (Prisoners: "+ self.Prisoners +") (CellDoor: "+ self.CellDoor +")")
    __onCellAttachAndDetachEvent()
endEvent

; When this jail cell is in the same cell as the player
event OnAttachedToCell()
    __onCellAttachAndDetachEvent()
endEvent

; When this jail cell is not in the cell the player is in
event OnDetachedFromCell()
    __onCellAttachAndDetachEvent()
endEvent

bool function PerformPrisonerSanityCheck(RPB_Prisoner apPrisoner)
    return __performPrisonerSanityCheck(apPrisoner)
endFunction

bool function PerformPrisonersSanityCheck()
    __npcSanityCheckAllPrisoners = true
    return __performPrisonersSanityCheck()
endFunction

bool function __shouldSanityCheckAllPrisoners()
    return !self.IsEmpty && __npcSanityCheckAllPrisoners && __npcSanityCheckSelectedPrisoner == none
endFunction

bool function __shouldSanityCheckSinglePrisoner()
    return !self.IsEmpty && !__npcSanityCheckAllPrisoners && __npcSanityCheckSelectedPrisoner != none
endFunction

bool function __performPrisonerSanityCheck(RPB_Prisoner apPrisoner)
    if (!apPrisoner || !apPrisoner.IsNPC())
        return false
    endif

    bool isStateValid = true

    ; Debug("("+ ID +") (-) JailCell::PerformPrisonerSanityCheck", "("+ apPrisoner.GetActor() +") Cell Package: " + apPrisoner.CellPackage)
    ; Debug("("+ ID +") (-) JailCell::PerformPrisonerSanityCheck", "("+ apPrisoner.GetActor() +") NPC_Underwear: " + apPrisoner.NPC_Underwear)
    ; Debug("("+ ID +") (-) JailCell::PerformPrisonerSanityCheck", "("+ apPrisoner.GetActor() +") Outfit: " + apPrisoner.PrisonOutfit)

    if (apPrisoner.IsImprisoned)
        apPrisoner.EnableAI(!apPrisoner.IsFarFromPlayer())
        
        apPrisoner.NPC_UpdateStripping()
        apPrisoner.NPC_UpdateClothing()
        apPrisoner.NPC_UpdateUnderwear()

        if (apPrisoner.ShouldBeInCell && !apPrisoner.IsInCell)
            apPrisoner.MoveTo(self)                                           ; Move the prisoner to this jail cell
            apPrisoner.NPC_BindToCell()                                       ; Prisoner should already be bound to cell, but just in case they aren't
            RegisterForSingleUpdate(__npcSanityCheckPostCheckUpdateTime)      ; Keep updating until the prisoner is in the cell
            isStateValid = false
        endif
    endif

    DebugWithArgs("(-) " + self + " JailCell::PerformPrisonerSanityCheck", apPrisoner.Name , "Sanity check complete for " + apPrisoner.Name + ", state is valid.", isStateValid)
    ; DebugWithArgs(self +" JailCell::__performPrisonerSanityCheck", apPrisoner.Name, \
    ;     "\n\t __npcSanityCheckPostCheckUpdateTime: "    + __npcSanityCheckPostCheckUpdateTime + \
    ;     "\n\t __npcSanityCheckAllPrisoners: "           + __npcSanityCheckAllPrisoners + \
    ;     "\n\t __npcSanityCheckSelectedPrisoner: "       + __npcSanityCheckSelectedPrisoner + \
    ;     "\n\t __npcSanityCheckReset: "                  + __npcSanityCheckReset + \
    ;     "\n\t apPrisoner.IsImprisoned: "                + apPrisoner.IsImprisoned + \
    ;     "\n\t isStateValid: "                           + isStateValid \
    ; )

    return isStateValid
endFunction

bool function __performPrisonersSanityCheck()
    ; Dont need to sanity check empty cells
    if (self.IsEmpty)
        return false
    endif

    ; Not registered to check all prisoners
    if (!__npcSanityCheckAllPrisoners)
        return false
    endif

    bool havePrisonersPassedSanityCheck = true

    int i = 0
    while (i < self.PrisonerCount)
        Actor prisonerRef                   = self.Prisoners[i] as Actor
        RPB_Prisoner prisoner               = prison.AwaitPrisonerReference(prisonerRef)
        bool hasPrisonerPassedSanityCheck   =  self.__performPrisonerSanityCheck(prisoner)
        ; Debug("{NPC_SanityChecking} "+ self +" JailCell::__performPrisonersSanityCheck", "[Prisoner: "+ prisoner.Name +"] Location: " + prisoner.GetCurrentCell())

        if (!hasPrisonerPassedSanityCheck)
            havePrisonersPassedSanityCheck = false
        endif
        i += 1
    endWhile

    ; Trace("{NPC_SanityChecking} "+ self +" JailCell::__performPrisonersSanityCheck", \
    ;     "\n\t __npcSanityCheckPostCheckUpdateTime: "    + __npcSanityCheckPostCheckUpdateTime + \
    ;     "\n\t __npcSanityCheckAllPrisoners: "           + YesNo(__npcSanityCheckAllPrisoners) + \
    ;     "\n\t __npcSanityCheckSelectedPrisoner: "       + __npcSanityCheckSelectedPrisoner + \
    ;     "\n\t __npcSanityCheckReset: "                  + __npcSanityCheckReset + \
    ;     "\n\t havePrisonersPassedSanityCheck: "         + YesNo(havePrisonersPassedSanityCheck) \
    ; )

    return havePrisonersPassedSanityCheck
endFunction

state NPC_SanityChecking
    event OnUpdate()
        ; Debug("["+ ID +"] {NPC_SanityChecking} JailCell::OnUpdate", "Updating... Time for update: " + __npcSanityCheckPreCheckUpdateTime)
        bool hasCheckedSuccessfully = \ 
            (__shouldSanityCheckAllPrisoners() && __performPrisonersSanityCheck()) || \
            (__shouldSanityCheckSinglePrisoner() && __performPrisonerSanityCheck(__npcSanityCheckSelectedPrisoner))

        if (hasCheckedSuccessfully)
            __npcSanityCheckReset = true ; Toggle the flag to reset the sanity check variables to ensure a clean state
            ; Debug("{NPC_SanityChecking} "+ self +" JailCell::OnUpdate", "Updating...")
            GotoState("")
        endif
    endEvent

    event OnEndState()
        if (__npcSanityCheckReset)
            self.ResetSanityChecking()
        endif
    endEvent
endState

; =========================================================
;                       Serialization                      
; =========================================================

int function GetSerializableRootObject()
    ; TODO: Commented, but we need to find a way to hot-reload the object, so changes can be made
    ; int rootObject      = RPB_Data.GetRootObject(Prison.Hold) ; JMap&
    ; int prisonObject    = RPB_Data.Hold_GetJailObject(rootObject) ; JMap&
    ; return RPB_Data.GetPropertyOfTypeObject(prisonObject, "Cells//" + self)

    return Prison.Children("Cells//" + self)
endFunction

bool function HasOption(string asOption)
    return self.HasProperty("Options//" + asOption)
endFunction

;                           Options                        
; =========================================================
bool function GetOptionOfTypeBool(string asOption)
    return self.GetPropertyOfTypeBool("Options//" + asOption)
endFunction

int function GetOptionOfTypeInt(string asOption)
    return self.GetPropertyOfTypeInt("Options//" + asOption)
endFunction

float function GetOptionOfTypeFloat(string asOption)
    return self.GetPropertyOfTypeFloat("Options//" + asOption)
endFunction

string function GetOptionOfTypeString(string asOption)
    return self.GetPropertyOfTypeString("Options//" + asOption)
endFunction

Form function GetOptionOfTypeForm(string asOption)
    return self.GetPropertyOfTypeForm("Options//" + asOption)
endFunction

;                         Objects                          
; =========================================================
Form[] function GetConfigObjects(string asObjectCategory)
    return self.GetPropertyOfTypeFormArray("Objects//" + asObjectCategory)
endFunction

bool function HasObjects(string asObjectCategory, bool abCheckEmpty = true)
    return self.HasProperty("Objects//" + asObjectCategory, abCheckEmpty)
endFunction

string function GetIdentifier()
    return "Cell["+ self.GetFormID() +"]"
endFunction

; =========================================================
;                          private                      
; =========================================================

;/
    Fetches the Prison weak reference from the Prison UUID in storage.

    This reference (and any reference that is a member of this script), will be reset to null
    after 10+ in-game days have passed due to the way Skyrim deletes them.

    By setting it from the persistent storage, it is always able to be retrieved.
/;
RPB_Prison function __fetchPrisonWeakReference()
    string prisonUUID = self.GetLocalPropertyOfTypeString("Prison UUID")

    if (!prisonUUID)
        DebugError("(-) ["+ self +"] JailCell::FetchPrisonWeakReference", "Prison UUID is null, this may result in undefined behavior!")
        return none
    endif

    return RPB_API.GetPrisonManager().GetPrisonByUUID(prisonUUID)
endFunction

RPB_Prison __prison
RPB_Prison function __getPrison()
    if (__prison)
        return __prison
    endif

    __prison = __fetchPrisonWeakReference()

    if (__prison)
        return __prison
    endif

    DebugError("["+ self +"] JailCell::Prison", "Prison is null, this may result in undefined behavior!")
    return none
endFunction

RPB_CellDoor __cellDoor
RPB_CellDoor function __getCellDoor()
    if (__cellDoor)
        return __cellDoor
    endif

    __cellDoor = self.GetPropertyOfTypeFormArray("Cell Doors")[0] as RPB_CellDoor
    self.BindCellDoor(__cellDoor)

    if (__cellDoor)
        return __cellDoor
    endif

    DebugError("["+ Prison.Name +"] ["+ self +"] JailCell::CellDoor", "Cell Door for " + self.ID + " (" + self + ") is null, this may result in undefined behavior!")
    return none
endFunction

; =========================================================
;                          Debug                      
; =========================================================

string function DEBUG_ShowPrisonerSentenceInfo(RPB_Prisoner apPrisoner)
    string sentenceFormatted    = Prison.GetSentenceFormatted(apPrisoner)
    string sentence = string_if (!apPrisoner.IsUndeterminedSentence, sentenceFormatted, "N/A")

    return sentence
endFunction

string function DEBUG_GetPrisoners()
    string outputPrisoners = ""
    int i = 0
    while (i < Prisoners.Length)
        Form ref = Prisoners[i]
        RPB_Prisoner prisonerRef = Prison.GetPrisonerReference(ref as Actor)
        ; string sentence = DEBUG_ShowPrisonerSentenceInfo(prisonerRef)
        ; Debug("["+ ID +"] JailCell::DEBUG_GetPrisoners", "Sentence: " + sentence)
        if (prisonerRef)
            ; string sentenceInfo = Prison.DEBUG_GetPrisonerSentenceInfo(prisonerRef, true)
            ; outputPrisoners += "\t\t"+ prisonerRef.GetActor() + " " + prisonerRef.GetName() + " " + "(" + prisonerRef.GetSex(true) + ")" + string_if (prisonerRef.IsSentenceSet, ": " + sentenceInfo) + "\n"
            ; outputPrisoners += "\t\t"+ prisonerRef.GetActor() + " " + prisonerRef.GetName() + " " + "(" + prisonerRef.GetSex(true) + ")" + string_if (prisonerRef.IsSentenceSet, ": " + sentence) + "\n"
            outputPrisoners += "\t\t"+ prisonerRef.GetActor() + " " + prisonerRef.GetName() + " " + "(" + prisonerRef.GetSex(true) + ")" + "\n"
            endif
        i += 1
    endWhile
    ; while (i < Object_Size(__prisonersInCell))
    ;     Form prisonerForm = FastMap_GetForm(__prisonersInCell, FastMap_GetNthKey(__prisonersInCell, i))
    ;     RPB_Prisoner prisonerRef = Prison.GetPrisonerReference(prisonerForm as Actor)

    ;     if (prisonerRef)
    ;         ; string sentenceInfo = Prison.DEBUG_GetPrisonerSentenceInfo(prisonerRef, true)
    ;         ; outputPrisoners += "\t\t"+ prisonerRef.GetActor() + " " + prisonerRef.GetName() + " " + "(" + prisonerRef.GetSex(true) + ")" + string_if (prisonerRef.IsSentenceSet, ": " + sentenceInfo) + "\n"
    ;         outputPrisoners += "\t\t"+ prisonerRef.GetActor() + " " + prisonerRef.GetName() + " " + "(" + prisonerRef.GetSex(true) + ")" + "\n"
    ;         endif
    ;     i += 1
    ; endWhile

    return outputPrisoners
endFunction

string function DEBUG_GetCellProperties()
    string getGenderExclusivenessAsString = string_if (self.IsFemaleOnly, "Female Only", string_if(self.IsMaleOnly, "Male Only"))

    return "[\n" + \
        "\t Cell: " + self.ID + " (" + self + ")" + "\n" + \
        "\t Door: " + self.CellDoor + "\n" + \
        "\t Empty: " + self.IsEmpty + "\n" + \
        "\t Full: " + self.IsFull + "\n" + \
        "\t Overcrowded: " + self.IsOvercrowded + " (Allow Overcrowding: "+ self.AllowOvercrowding +")" + "\n" + \
        "\t Available: " + self.IsAvailable + "\n" + \
        "\t Gender Exclusive: " + self.IsGenderExclusive + string_if (self.IsGenderExclusive, " ("+ getGenderExclusivenessAsString +")") + "\n" + \
        "\t Maximum Prisoners: " + self.MaxPrisoners + "\n" + \
        "\t Prisoners: " + self.PrisonerCount + string_if (self.HasPrisoners, " -> [\n"+ self.DEBUG_GetPrisoners() +"\t]") + "\n" + \
    "]"
endFunction