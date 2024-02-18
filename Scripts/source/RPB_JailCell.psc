scriptname RPB_JailCell extends ObjectReference

import Math
import RealisticPrisonAndBounty_Config
import RPB_Utility

; ==========================================================
;                     Script References
; ==========================================================

RealisticPrisonAndBounty_Config property Config
    RealisticPrisonAndBounty_Config function get()
        return Game.GetFormFromFile(0x3317, GetPluginName()) as RealisticPrisonAndBounty_Config
    endFunction
endProperty

RealisticPrisonAndBounty_ArrestVars property ArrestVars
    RealisticPrisonAndBounty_ArrestVars function get()
        return Config.ArrestVars
    endFunction
endProperty

RealisticPrisonAndBounty_MiscVars property MiscVars
    RealisticPrisonAndBounty_MiscVars function get()
        return Config.MiscVars
    endFunction
endProperty

; ==========================================================

RPB_Prison __prison
RPB_Prison property Prison
    RPB_Prison function get()
        if (!__prison)
            ErrorProperty("["+ self +"] JailCell::Prison", "Prison is null, this may result in undefined behavior!")
        endif

        return __prison
    endFunction
endProperty

RPB_CellDoor __cellDoor
RPB_CellDoor property CellDoor
    RPB_CellDoor function get()
        if (!__cellDoor)
            ErrorProperty("["+ self +"] JailCell::CellDoor", "Cell Door for Cell "+ self +" is null, this may result in undefined behavior!")
        endif

        return __cellDoor
    endFunction
endProperty

string property ID
    string function get()
        return self.GetRootPropertyOfTypeString("ID")
    endFunction
endProperty

RPB_JailCell property ParentInteriorMarker
    RPB_JailCell function get()
        return self
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

; The prisoners living in this cell
RPB_Prisoner[] __prisoners
Form[] property Prisoners
    Form[] function get()
        return JArray.asFormArray(JMap.allValues(__prisonersInCell))
        ; return self.GetPrisoners()
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

bool property HasBeds
    bool function get()
        return self.Beds.Length > 0
    endFunction
endProperty

bool property HasContainers
    bool function get()
        return self.Containers.Length > 0
    endFunction
endProperty

bool property HasOtherProps
    bool function get()
        return self.OtherProps.Length > 0
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

; Not yet used, since the caller needs a reference to Prisoner to pass to SetExclusiveToPrisonerSex
; Workaround might be to store the first prisoner reference just for this purpose, so we don't retrieve it twice and waste cycles/performance
bool property ShouldBeGenderExclusive
    bool function get()
        Form prisonerForm = JMap.getForm(__prisonersInCell, JMap.getNthKey(__prisonersInCell, 0)) ; Get the first prisoner
        RPB_Prisoner prisonerRef = Prison.GetPrisonerReference(prisonerForm as Actor)

        ; If the first prisoner will be/is stripped naked / to underwear, set this cell as gender exclusive for them if the cell is not yet gender exclusive
        return !self.IsGenderExclusive && (prisonerRef.WillBeStrippedNaked || prisonerRef.WillBeStrippedToUnderwear) || (prisonerRef.IsStrippedNaked || prisonerRef.IsStrippedToUnderwear)
    endFunction
endProperty


; The approximate size of this cell from the center point (this reference) as a radius
float __cellRadius
float property CellRadius
    float function get()
        if (!__cellRadius)
            __cellRadius = self.GetOptionOfTypeFloat("Interior Radius", "Scan")
        endif

        return __cellRadius
    endFunction
endProperty

; The amount of times a scan should be performed
int __scanIterations
int property ScanIterations
    int function get()
        if (!__scanIterations)
            __scanIterations = self.GetOptionOfTypeInt("Iterations", "Scan")
        endif

        return __scanIterations
    endFunction
endProperty

; How many prisoners can this jail cell take (if AllowOvercrowding is false)
int __maxPrisoners
int property MaxPrisoners
    int function get()
        if (!__maxPrisoners)
            __maxPrisoners = self.GetOptionOfTypeInt("Maximum Prisoners")

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

    function set(int value)
        int configOption = self.GetOptionOfTypeInt("Maximum Prisoners")

        if (configOption)
            LogProperty("JailCell::MaxPrisoners", "Property is retrieved from data file, make sure the value is supposed to be changing!")
        endif

        __maxPrisoners = value
    endFunction
endProperty

int __prisonersInCell
Form[] property PrisonersInCell
    Form[] function get()
        
    endFunction
endProperty

int property PrisonerCount
    int function get()
        return JValue.count(__prisonersInCell)
    endFunction
endProperty

; ==========================================================

ObjectReference function GetCellObject(Keyword akPropType)

endFunction

function DetermineMarkers()
    Form[] interiorChildMarkers = RPB_Data.JailCell_GetChildren(Prison.GetDataObject("Cells"), self, "Interior")
    Form[] exteriorChildMarkers = RPB_Data.JailCell_GetChildren(Prison.GetDataObject("Cells"), self, "Exterior")

    Debug("[Prison: "+ self.Prison.City +"] JailCell::DetermineMarkers", "Cell: " + self + ", Main Marker: " + RPB_Data.JailCell_GetMainMarker(Prison.GetDataObject("Cells"), self))
    Debug("[Prison: "+ self.Prison.City +"] JailCell::DetermineMarkers", "Cell: " + self + ", interiorChildMarkers: " + interiorChildMarkers)
    Debug("[Prison: "+ self.Prison.City +"] JailCell::DetermineMarkers", "Cell: " + self + ", exteriorChildMarkers: " + exteriorChildMarkers)

    ; Convert to JArray
    int arrayInteriorChildMarkers = JArray.objectWithForms(interiorChildMarkers)
    int arrayExteriorChildMarkers = JArray.objectWithForms(exteriorChildMarkers)

    ; Debug("[Prison: "+ self.Prison.City +"] JailCell::DetermineMarkers", "arrayInteriorChildMarkers: " + GetContainerList(arrayInteriorChildMarkers))
    ; Debug("[Prison: "+ self.Prison.City +"] JailCell::DetermineMarkers", "arrayExteriorChildMarkers: " + GetContainerList(arrayExteriorChildMarkers))

    int arrayAllInteriorMarkers = JArray.object()
    int arrayAllExteriorMarkers = JArray.object()
    
    ; Add parent
    JArray.addForm(arrayAllInteriorMarkers, self)

    ; Merge the arrays
    JArray.addFromArray(arrayAllInteriorMarkers, arrayInteriorChildMarkers)
    JArray.addFromArray(arrayAllExteriorMarkers, arrayExteriorChildMarkers)

    ; Debug("[Prison: "+ self.Prison.City +"] JailCell::DetermineMarkers", "arrayAllInteriorMarkers: " + GetContainerList(arrayAllInteriorMarkers))
    ; Debug("[Prison: "+ self.Prison.City +"] JailCell::DetermineMarkers", "arrayAllExteriorMarkers: " + GetContainerList(arrayAllExteriorMarkers))

    ; Set properties
    __interiorMarkers       = JArray.asFormArray(arrayAllInteriorMarkers)
    __exteriorMarkers       = JArray.asFormArray(arrayAllExteriorMarkers)
    
    Debug("[Prison: "+ self.Prison.City +"] JailCell::DetermineMarkers", "InteriorMarkers: " + InteriorMarkers)
    Debug("[Prison: "+ self.Prison.City +"] JailCell::DetermineMarkers", "ExteriorMarkers: " + ExteriorMarkers)
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

function SetExclusiveToPrisonerSex(RPB_Prisoner akPrisoner)
    if (akPrisoner.IsMale)
        self.SetAsMaleOnly()

    elseif (akPrisoner.IsFemale)
        self.SetAsFemaleOnly()
    endif
endFunction

function RemoveGenderExclusiveness()
    if (!__isFemaleOnly && !__isMaleOnly)
        return
    endif

    __isFemaleOnly  = false
    __isMaleOnly    = false

    Debug("JailCell::RemoveGenderExclusiveness", self + " is no longer a gender exclusive cell.")
endFunction

; RPB_CellDoor function ScanCellDoor()
;     int jailBaseDoorIdForPrison = GetJailBaseDoorID(self.Prison.Hold) ; Base ID of any Door from this Prison
;     RPB_CellDoor _cellDoor      = GetNearestJailDoorOfType(jailBaseDoorIdForPrison, self, 4000) as RPB_CellDoor
;     return _cellDoor
; endFunction

function ScanCellDoor(bool abForceAssignment = false)
    if (CellDoor && !abForceAssignment)
        return
    endif

    Form baseCellDoor = Prison.GetRootPropertyOfTypeForm("Base Cell Door")

    int jailBaseDoorIdForPrison = GetJailBaseDoorID(self.Prison.Hold) ; Base ID of any Door from this Prison
    RPB_CellDoor _cellDoor      = GetNearestJailDoorOfTypeEx(baseCellDoor, self, 4000) as RPB_CellDoor

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
    int bedExclusions   = JMap.object()
    int bedsScanned     = JArray.object()

    Form bedRollHay01 = Game.GetFormEx(0x1899D)
    FormList RPB_BedFormList = GetFormFromMod(0x1CDAA) as FormList

    Debug("[Prison: "+ self.Prison.City +"] JailCell::ScanBeds", "Scan Iterations: " + self.ScanIterations + ", Cell Radius: " + self.CellRadius)


    int i = 0
    while (i < self.ScanIterations)
        ObjectReference scannedBed = Game.FindRandomReferenceOfAnyTypeInListFromRef(RPB_BedFormList, self, self.CellRadius)

        if (scannedBed && !JMap.hasKey(bedExclusions, scannedBed.GetFormID()))
            ; self.MaxPrisoners += 1
            JMap.setForm(bedExclusions, scannedBed.GetFormID(), scannedBed)
            JArray.addForm(bedsScanned, scannedBed) ; Add the bed to this local array
            Debug("[Prison: "+ self.Prison.City +"] JailCell::ScanBeds", "Scanned " + scannedBed + " (Name: "+ scannedBed.GetBaseObject().GetName() +") Bed in " + self + ", Max Prisoners for this Cell: " + self.MaxPrisoners)
        endif
        i += 1
    endWhile
    
    ; If there were beds caught in the scan, add it to the cell beds array
    if (JValue.count(bedsScanned) > 0)
        __beds = JArray.asFormArray(bedsScanned)
        __scannedBeds = true
        self.MaxPrisoners = JValue.count(bedsScanned)
    endif

    Debug("[Prison: "+ self.Prison.City +"] JailCell::ScanBeds", "Beds in " + self + ": " + self.Beds)
endFunction

function ScanContainers()
    FormList RPB_ContainerFormList = GetFormFromMod(0x1CDAB) as FormList
    int containersAlreadyAdded  = JMap.object()
    int containersScanned       = JArray.object()

    int i = 0
    while (i < self.ScanIterations)
        ObjectReference scannedContainer = Game.FindRandomReferenceOfAnyTypeInListFromRef(RPB_ContainerFormList, self, self.CellRadius)
        bool containerExistsInList = JMap.hasKey(containersAlreadyAdded, scannedContainer.GetFormID())
        if (scannedContainer && !containerExistsInList)
            JMap.setForm(containersAlreadyAdded, scannedContainer.GetFormID(), scannedContainer)
            JArray.addForm(containersScanned, scannedContainer)
            Debug("[Prison: "+ self.Prison.City +"] JailCell::ScanContainers", "Scanned " + scannedContainer + " (Name: "+ scannedContainer.GetBaseObject().GetName() +") container in " + self)
        endif
        i += 1
    endWhile

    if (JValue.count(containersScanned) > 0)
        __containers = JArray.asFormArray(containersScanned)
        __scannedContainers = true
    endif

    Debug("[Prison: "+ self.Prison.City +"] JailCell::ScanContainers", "Containers in " + self + ": " + self.Containers + " Containers.Length: " + self.Containers.Length)
endFunction

function ScanMiscProps()
    FormList RPB_MiscPropsFormList = GetFormFromMod(0x1CDAC) as FormList
    int propsAlreadyAdded  = JMap.object()
    int propsScanned       = JArray.object()

    int i = 0
    while (i < self.ScanIterations)
        ObjectReference scannedProp = Game.FindRandomReferenceOfAnyTypeInListFromRef(RPB_MiscPropsFormList, self, self.CellRadius)
        bool propExistsInList = JMap.hasKey(propsAlreadyAdded, scannedProp.GetFormID())
        if (scannedProp && !propExistsInList)
            JMap.setForm(propsAlreadyAdded, scannedProp.GetFormID(), scannedProp)
            JArray.addForm(propsScanned, scannedProp)
            Debug("[Prison: "+ self.Prison.City +"] JailCell::ScanMiscProps", "Scanned " + scannedProp + " (Name: "+ scannedProp.GetBaseObject().GetName() +") prop in " + self)
        endif
        i += 1
    endWhile

    if (JValue.count(propsScanned) > 0)
        __otherProps = JArray.asFormArray(propsScanned)
        __scannedOtherProps = true
    endif

    Debug("[Prison: "+ self.Prison.City +"] JailCell::ScanMiscProps", "Props in " + self + ": " + self.OtherProps)
endFunction

ObjectReference function GetRandomMarker(string asInteriorOrExterior = "Interior")
    if (asInteriorOrExterior == "Interior")
        return self.InteriorMarkers[Utility.RandomInt(0, self.InteriorMarkers.Length - 1)] as ObjectReference

    elseif (asInteriorOrExterior == "Exterior")
        return self.ExteriorMarkers[Utility.RandomInt(0, self.ExteriorMarkers.Length - 1)] as ObjectReference
    endif

    return none
endFunction

; =========================================================
;                         Prisoners                        
; =========================================================

bool function HasPrisoners()

endFunction

bool function HasFemales(bool abStrictlyFemales = false)
    
endFunction

bool function HasMales(bool abStrictlyMales = false)
    
endFunction

;/
    Retrieves the prisoner(s) living in this jail cell.
/;
RPB_Prisoner[] function GetPrisoners()

endFunction

RPB_Prisoner[] function GetFemalePrisoners()

endFunction

RPB_Prisoner[] function GetMalePrisoners()
    
endFunction

function RemovePrisoner(RPB_Prisoner apPrisoner)
    if (apPrisoner)
        self.UnregisterPrisoner(apPrisoner)
        self.OnPrisonerLeave(apPrisoner)
    endif
endFunction

; =========================================================
;                          Events
; =========================================================

; Happens when the prisoner enters this cell (when they are added)
event OnPrisonerEnter(RPB_Prisoner akPrisoner)
    self.RegisterPrisoner(akPrisoner)
    self.DetermineCellParameters()

    Debug("JailCell::OnPrisonerEnter", "Cell Properties: " + self.DEBUG_GetCellProperties())
endEvent

; Happens when the prisoner leaves this cell (when they are removed)
event OnPrisonerLeave(RPB_Prisoner akPrisoner)
    ; self.UnregisterPrisoner(akPrisoner)
    self.DetermineCellParameters()

    Debug("JailCell::OnPrisonerLeave", "Cell Properties: " + self.DEBUG_GetCellProperties())
endEvent

; =========================================================
;                         Management
; =========================================================

; Probably gonna be unused, we'll see
int function GetDataObject(string asSubCategory = "null")
    int cellsObj    = Prison.GetDataObject("Cells")     ; JFormMap&
    int thisCellObj = JFormMap.getObj(cellsObj, self)   ; JMap&
    int returnedObj = thisCellObj

    if (asSubCategory != "null")
        returnedObj = JMap.getObj(thisCellObj, asSubCategory)
    endif

    return returnedObj
endFunction

bool function ShouldPerformScan(string asScanTarget)
    if (!self.HasOption("Iterations", "Scan") || !self.HasOption("Interior Radius", "Scan"))
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

;/
    Determines if this JailCell... this should be in CellDoor
/;
bool function IsRegisteredCellDoorInPrison(int aiCellDoorFormID)
    return true ; temporary
endFunction

bool function IsInitialized()
    return __prison && __cellDoor
endFunction

function Initialize(RPB_Prison apPrison)
    ; Link the actual Prison with this Jail Cell
    self.BindPrison(apPrison)

    ; int cellObj = self.GetDataObject()
    ; Debug("["+ self +"] JailCell::Initialize", "Jail Cell Config: " + GetContainerList(cellObj))

    string[] stringList = self.GetRootPropertyOfTypeStringArray("String List")
    Debug("JailCell::Initialize", "String List: " + stringList)

    ; RPB_CellDoor configuredCellDoor = self.GetRootPropertyOfTypeForm("Cell Door") as RPB_CellDoor
    RPB_CellDoor configuredCellDoor = self.GetRootPropertyOfTypeFormArray("Cell Doors")[0] as RPB_CellDoor ; Index is temporary, for now only use 1st cell door
    Debug("JailCell::Initialize", "configuredCellDoor: " + configuredCellDoor)


    if (configuredCellDoor)
        ; Bind the cell door to the jail cell
        self.BindCellDoor(configuredCellDoor)
    endif

    ; Determine all markers for this cell
    self.DetermineMarkers()
endFunction

function BindPrison(RPB_Prison akPrison)
    __prison = akPrison

    if (!self.Prison)
        Debug("["+ self +"] JailCell::BindPrison", "Could not bind the jail cell " + self + " to the Prison " + akPrison)
        return
    endif
endFunction

function BindCellDoor(RPB_CellDoor akCellDoor)
    ; Bind the cell door to this jail cell
    __cellDoor = akCellDoor

    ; Bind this jail cell to the cell door (to retrieve this from the cell door)
    akCellDoor.BindCell(self)

    ; Initialize the cell door properties
    akCellDoor.Initialize()

    Error("Could not bind cell door to the jail cell " + self, (!self.CellDoor && self.CellDoor != akCellDoor))
endFunction

;/
    Registers the passed in Prisoner to this Jail Cell,
    the value is stored as:
    Cell[FormID] = 0x14
/;
function RegisterPrisoner(RPB_Prisoner apPrisoner)
    if (!__prisonersInCell)
        __prisonersInCell = JMap.object()
        JValue.retain(__prisonersInCell)
    endif

    ; Helper.IntMap_SetForm(self.GetIdentifier(), apPrisoner.GetIdentifier(), apPrisoner.GetActor())
    JMap.setForm(__prisonersInCell, apPrisoner.GetIdentifier(), apPrisoner.GetActor())
    ; MiscVars.SetString("Cell[" + self.GetFormID() + "]", apPrisoner.GetIdentifier(), "Prison/Cells")

    ; Pass the reference to the Prisoner
    apPrisoner.SetForm("Cell", self, "Jail")
endFunction

function UnregisterPrisoner(RPB_Prisoner apPrisoner)
    JMap.removeKey(__prisonersInCell, apPrisoner.GetIdentifier())
endFunction

function DetermineCellParameters()
    ; if (!self.IsEmpty)
    ;     ; Don't do anything, cell is not empty which means the parameters have already been set most likely
    ;     return
    ; endif

    if (self.PrisonerCount > 0)
        Form prisonerForm = JMap.getForm(__prisonersInCell, JMap.getNthKey(__prisonersInCell, 0)) ; Get the first prisoner
        RPB_Prisoner prisonerRef = Prison.GetPrisonerReference(prisonerForm as Actor)

        ; If the first prisoner will be/is stripped naked / to underwear, set this cell as gender exclusive for them if the cell is not yet gender exclusive,
        ; this means that the first prisoner has not been stripped naked or to underwear.
        ; (Not implemented yet): We should probably make the first prisoner strip off (maybe in some condition, such as having more than a day left of sentence for example.)
        if (!self.IsGenderExclusive && (prisonerRef.WillBeStrippedNaked || prisonerRef.WillBeStrippedToUnderwear) || (prisonerRef.IsStrippedNaked || prisonerRef.IsStrippedToUnderwear))
            self.SetExclusiveToPrisonerSex(prisonerRef)
        endif

    else
        ; No prisoners in this cell
        ; Unset this cell as being female/male only, as it is now empty
        self.RemoveGenderExclusiveness()
    endif
endFunction

; =========================================================
;                         Data Config                      
; =========================================================

;                       Root Properties                    
; =========================================================
bool function GetRootPropertyOfTypeBool(string asPropertyName)
    return RPB_Data.JailCell_GetRootPropertyOfTypeBool(Prison.GetDataObject("Cells"), self, asPropertyName)
endFunction

int function GetRootPropertyOfTypeInt(string asPropertyName)
    return RPB_Data.JailCell_GetRootPropertyOfTypeInt(Prison.GetDataObject("Cells"), self, asPropertyName)
endFunction

float function GetRootPropertyOfTypeFloat(string asPropertyName)
    return RPB_Data.JailCell_GetRootPropertyOfTypeFloat(Prison.GetDataObject("Cells"), self, asPropertyName)
endFunction

string function GetRootPropertyOfTypeString(string asPropertyName)
    return RPB_Data.JailCell_GetRootPropertyOfTypeString(Prison.GetDataObject("Cells"), self, asPropertyName)
endFunction

Form function GetRootPropertyOfTypeForm(string asPropertyName)
    return RPB_Data.JailCell_GetRootPropertyOfTypeForm(Prison.GetDataObject("Cells"), self, asPropertyName)
endFunction

string[] function GetRootPropertyOfTypeStringArray(string asPropertyName)
    return RPB_Data.JailCell_GetRootPropertyOfTypeStringArray(Prison.GetDataObject("Cells"), self, asPropertyName)
endFunction

Form[] function GetRootPropertyOfTypeFormArray(string asPropertyName)
    return RPB_Data.JailCell_GetRootPropertyOfTypeFormArray(Prison.GetDataObject("Cells"), self, asPropertyName)
endFunction

;                           Options                        
; =========================================================
bool function GetOptionOfTypeBool(string asOption, string asOptionCategory = "null")
    return RPB_Data.JailCell_GetOptionOfTypeBool(Prison.GetDataObject("Cells"), self, asOption, asOptionCategory)
endFunction

int function GetOptionOfTypeInt(string asOption, string asOptionCategory = "null")
    return RPB_Data.JailCell_GetOptionOfTypeInt(Prison.GetDataObject("Cells"), self, asOption, asOptionCategory)
endFunction

float function GetOptionOfTypeFloat(string asOption, string asOptionCategory = "null")
    return RPB_Data.JailCell_GetOptionOfTypeFloat(Prison.GetDataObject("Cells"), self, asOption, asOptionCategory)
endFunction

string function GetOptionOfTypeString(string asOption, string asOptionCategory = "null")
    return RPB_Data.JailCell_GetOptionOfTypeString(Prison.GetDataObject("Cells"), self, asOption, asOptionCategory)
endFunction

Form function GetOptionOfTypeForm(string asOption, string asOptionCategory = "null")
    return RPB_Data.JailCell_GetOptionOfTypeForm(Prison.GetDataObject("Cells"), self, asOption, asOptionCategory)
endFunction

bool function HasOption(string asOption, string asOptionCategory = "null")
    return RPB_Data.JailCell_HasOption(Prison.GetDataObject("Cells"), self, asOption, asOptionCategory)
endFunction

;                         Objects                          
; =========================================================
Form[] function GetConfigObjects(string asObjectCategory)
    return RPB_Data.JailCell_GetObjects(Prison.GetDataObject("Cells"), self, asObjectCategory)
endFunction

bool function HasObjects(string asObjectCategory)
    return RPB_Data.JailCell_HasObjects(Prison.GetDataObject("Cells"), self, asObjectCategory, true)
endFunction


string function GetIdentifier()
    return "Cell["+ self.GetFormID() +"]"
endFunction

bool function IsBoundToPrisoner(RPB_Prisoner akPrisoner)
    return MiscVars.GetReference("["+ akPrisoner.GetIdentifier() +"]Cell").GetFormID() == self.GetFormID()
endFunction

; =========================================================
;                         Cell Vars                       
; =========================================================

string function __getCellIdentifierVarKey(string asVarName)
    return "["+ self.GetFormID() +"]Cell::" + asVarName
endFunction

;                           Getters
bool function Cell_GetBool(string asVarName)
    string identifierKey = __getCellIdentifierVarKey(asVarName)
    return ArrestVars.GetBool(identifierKey)
endFunction

int function Cell_GetInt(string asVarName)
    string identifierKey = __getCellIdentifierVarKey(asVarName)
    return ArrestVars.GetInt(identifierKey)
endFunction

float function Cell_GetFloat(string asVarName)
    string identifierKey = __getCellIdentifierVarKey(asVarName)
    return ArrestVars.GetFloat(identifierKey)
endFunction

string function Cell_GetString(string asVarName)
    string identifierKey = __getCellIdentifierVarKey(asVarName)
    return ArrestVars.GetString(identifierKey)
endFunction

Form function Cell_GetForm(string asVarName)
    string identifierKey = __getCellIdentifierVarKey(asVarName)
    return ArrestVars.GetForm(identifierKey)
endFunction

ObjectReference function Cell_GetReference(string asVarName)
    string identifierKey = __getCellIdentifierVarKey(asVarName)
    return ArrestVars.GetReference(identifierKey)
endFunction

Actor function Cell_GetActor(string asVarName)
    string identifierKey = __getCellIdentifierVarKey(asVarName)
    return ArrestVars.GetActor(identifierKey)
endFunction

;                           Setters
function Cell_SetBool(string asVarName, bool abValue)

endFunction

function Cell_SetInt(string asVarName, int aiValue, int aiMinValue = 0, int aiMaxValue = 0)

endFunction

function Cell_ModInt(string asVarName, int aiValue)

endFunction

function Cell_SetFloat(string asVarName, float afValue)

endFunction

function Cell_ModFloat(string asVarName, float afValue)

endFunction

function Cell_SetString(string asVarName, string asValue)

endFunction

function Cell_SetForm(string asVarName, Form akValue)

endFunction

function Cell_SetReference(string asVarName, ObjectReference akValue)

endFunction

function Cell_SetActor(string asVarName, Actor akValue)

endFunction

; =========================================================
;                          Debug                      
; =========================================================

string function DEBUG_GetPrisoners()
    string outputPrisoners = ""
    int i = 0
    while (i < JValue.count(__prisonersInCell))
        Form prisonerForm = JMap.getForm(__prisonersInCell, JMap.getNthKey(__prisonersInCell, i))
        RPB_Prisoner prisonerRef = Prison.GetPrisonerReference(prisonerForm as Actor)

        if (prisonerRef)
            ; string sentenceInfo = Prison.DEBUG_GetPrisonerSentenceInfo(prisonerRef, true)
            ; outputPrisoners += "\t\t"+ prisonerRef.GetActor() + " " + prisonerRef.GetName() + " " + "(" + prisonerRef.GetSex(true) + ")" + string_if (prisonerRef.IsSentenceSet, ": " + sentenceInfo) + "\n"
            outputPrisoners += "\t\t"+ prisonerRef.GetActor() + " " + prisonerRef.GetName() + " " + "(" + prisonerRef.GetSex(true) + ")" + "\n"
            endif
        i += 1
    endWhile

    return outputPrisoners
endFunction

string function DEBUG_GetCellProperties()
    string getGenderExclusivenessAsString = string_if (self.IsFemaleOnly, "Female Only", string_if(self.IsMaleOnly, "Male Only"))

    bool _hasPrisoners = self.PrisonerCount > 0

    return "[\n" + \
        "\t Cell: " + self + "\n" + \
        "\t Door: " + self.CellDoor + "\n" + \
        "\t Empty: " + self.IsEmpty + "\n" + \
        "\t Full: " + self.IsFull + "\n" + \
        "\t Overcrowded: " + self.IsOvercrowded + "\n" + \
        "\t Available: " + self.IsAvailable + "\n" + \
        "\t Gender Exclusive: " + self.IsGenderExclusive + string_if (self.IsGenderExclusive, " ("+ getGenderExclusivenessAsString +")") + "\n" + \
        "\t Maximum Prisoners: " + self.MaxPrisoners + "\n" + \
        "\t Prisoners: " + self.PrisonerCount + string_if (_hasPrisoners, " -> [\n"+ self.DEBUG_GetPrisoners() +"\t]") + "\n" + \
    "]"
endFunction