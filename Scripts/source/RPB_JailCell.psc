scriptname RPB_JailCell extends ObjectReference

import Math
import RealisticPrisonAndBounty_Util
import RealisticPrisonAndBounty_Config

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
        return __prison
    endFunction
endProperty

RPB_CellDoor __cellDoor
RPB_CellDoor property CellDoor
    RPB_CellDoor function get()
        return __cellDoor
    endFunction
endProperty

; The prisoners living in this cell
RPB_Prisoner[] __prisoners
RPB_Prisoner[] property Prisoners
    RPB_Prisoner[] function get()
        return self.GetPrisoners()
    endFunction
endProperty

; The beds inside this cell
Form[] __beds
Form[] property Beds
    Form[] function get()
        return __beds
    endFunction
endProperty

; Containers in the cell, such as Sacks, Wardrobes, Dressers, Chests, Bedside Tables...
Form[] __containers
Form[] property Containers
    Form[] function get()
        return __containers
    endFunction
endProperty

; Other miscellaneous props in a cell, such as buckets, plates, food, etc...
Form[] __otherProps
Form[] property OtherProps
    Form[] function get()
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
bool property AllowOvercrowding auto

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
        return __isMaleOnly || __isFemaleOnly
    endFunction
endProperty

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
float property CellRadius auto

; How many prisoners can this jail cell take (if AllowOvercrowding is false)
int property MaxPrisoners auto

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

; =========================================================
;                           Cell                        
; =========================================================

function SetAsFemaleOnly()
    __isFemaleOnly = true
    Debug(self, "JailCell::SetAsFemaleOnly", self + " has been set as a female only cell.")
endFunction

function SetAsMaleOnly()
    __isMaleOnly = true
    Debug(self, "JailCell::SetAsMaleOnly", self + " has been set as a male only cell.")
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

    Debug(self, "JailCell::RemoveGenderExclusiveness", self + " is no longer a gender exclusive cell.")
endFunction

; Scans the jail cell to update any properties accordingly
function Scan()

endFunction

ObjectReference function GetBedExcept(Form akBedBase, ObjectReference akCenterPoint, float afRadius, Form akExceptBed = none)
    int i = 0
    while (i < 20)
        ObjectReference scannedBed = Game.FindRandomReferenceOfTypeFromRef(akBedBase, akCenterPoint, afRadius)
        if (scannedBed.GetFormID() != akExceptBed.GetFormID())
            return scannedBed
        endif

        i += 1
    endWhile
endFunction

; Unreliable, since it can scan beds from other cells that are near one of the scanned beds in this cell. (this is because beds are not in the same place on all the cells, and the radius of the scan will get other beds from other cells.)
function ScanBeds()
    int bedExclusions   = JMap.object()
    int bedsScanned     = JArray.object()

    Form bedRollHay01 = Game.GetFormEx(0x1899D)
    FormList RPB_BedFormList = GetFormFromMod(0x1CDAA) as FormList

    int i = 0
    while (i < 5) ; 10 scans
        ObjectReference scannedBed = Game.FindRandomReferenceOfAnyTypeInListFromRef(RPB_BedFormList, self, self.CellRadius)

        if (scannedBed && !JMap.hasKey(bedExclusions, scannedBed.GetFormID()))
            self.MaxPrisoners += 1
            JMap.setForm(bedExclusions, scannedBed.GetFormID(), scannedBed)
            JArray.addForm(bedsScanned, scannedBed) ; Add the bed to this local array
            Debug(self, "[Prison: "+ self.Prison.City +"] JailCell::ScanBeds", "Scanned " + scannedBed + " (Name: "+ scannedBed.GetBaseObject().GetName() +") Bed in " + self + ", Max Prisoners for this Cell: " + self.MaxPrisoners)
        endif
        i += 1
    endWhile
    
    ; If there were beds caught in the scan, add it to the cell beds array
    if (JValue.count(bedsScanned) > 0)
        __beds = JArray.asFormArray(bedsScanned)
    endif

    Debug(self, "[Prison: "+ self.Prison.City +"] JailCell::ScanBeds", "Beds in " + self + ": " + self.Beds + " Beds.Length: " + self.Beds.Length)
    Debug(self, "[Prison: "+ self.Prison.City +"] JailCell::ScanBeds", "Finished bed scan for cell " + self + ", found " + JValue.count(bedExclusions) + " beds.")
endFunction

function ScanContainers()
    FormList RPB_ContainerFormList = GetFormFromMod(0x1CDAB) as FormList
    int containersAlreadyAdded  = JMap.object()
    int containersScanned       = JArray.object()

    int i = 0
    while (i < 5)
        ObjectReference scannedContainer = Game.FindRandomReferenceOfAnyTypeInListFromRef(RPB_ContainerFormList, self, self.CellRadius)
        bool containerExistsInList = JMap.hasKey(containersAlreadyAdded, scannedContainer.GetFormID())
        if (scannedContainer && !containerExistsInList)
            JMap.setForm(containersAlreadyAdded, scannedContainer.GetFormID(), scannedContainer)
            JArray.addForm(containersScanned, scannedContainer)
            Debug(self, "[Prison: "+ self.Prison.City +"] JailCell::ScanContainers", "Scanned " + scannedContainer + " (Name: "+ scannedContainer.GetBaseObject().GetName() +") container in " + self)
        endif
        i += 1
    endWhile

    if (JValue.count(containersScanned) > 0)
        __containers = JArray.asFormArray(containersScanned)
    endif

    Debug(self, "[Prison: "+ self.Prison.City +"] JailCell::ScanContainers", "Containers in " + self + ": " + self.Containers + " Containers.Length: " + self.Containers.Length)
    Debug(self, "[Prison: "+ self.Prison.City +"] JailCell::ScanContainers", "Finished container scan for cell " + self + ", found " + JValue.count(containersScanned) + " containers.")
endFunction

function ScanMiscProps()
    FormList RPB_MiscPropsFormList = GetFormFromMod(0x1CDAC) as FormList
    int propsAlreadyAdded  = JMap.object()
    int propsScanned       = JArray.object()

    int i = 0
    while (i < 5)
        ObjectReference scannedProp = Game.FindRandomReferenceOfAnyTypeInListFromRef(RPB_MiscPropsFormList, self, self.CellRadius)
        bool propExistsInList = JMap.hasKey(propsAlreadyAdded, scannedProp.GetFormID())
        if (scannedProp && !propExistsInList)
            JMap.setForm(propsAlreadyAdded, scannedProp.GetFormID(), scannedProp)
            JArray.addForm(propsScanned, scannedProp)
            Debug(self, "[Prison: "+ self.Prison.City +"] JailCell::ScanMiscProps", "Scanned " + scannedProp + " (Name: "+ scannedProp.GetBaseObject().GetName() +") prop in " + self)
        endif
        i += 1
    endWhile

    if (JValue.count(propsScanned) > 0)
        __otherProps = JArray.asFormArray(propsScanned)
    endif

    Debug(self, "[Prison: "+ self.Prison.City +"] JailCell::ScanMiscProps", "Props in " + self + ": " + self.OtherProps + " OtherProps.Length: " + self.OtherProps.Length)
    Debug(self, "[Prison: "+ self.Prison.City +"] JailCell::ScanMiscProps", "Finished prop scan for cell " + self + ", found " + JValue.count(propsScanned) + " props.")
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

; =========================================================
;                          Events
; =========================================================

; Happens when the prisoner enters this cell (when they are added)
event OnPrisonerEnter(RPB_Prisoner akPrisoner)
    self.RegisterPrisoner(akPrisoner)
    self.DetermineCellParameters()

    Debug(self, "JailCell::OnPrisonerEnter", "Cell Properties: " + self.DEBUG_GetCellProperties())
endEvent

; Happens when the prisoner leaves this cell (when they are removed)
event OnPrisonerLeave(RPB_Prisoner akPrisoner)
    self.UnregisterPrisoner(akPrisoner)
    self.DetermineCellParameters()

    Debug(self, "JailCell::OnPrisonerLeave", "Cell Properties: " + self.DEBUG_GetCellProperties())
endEvent

; =========================================================
;                         Management
; =========================================================

;/
    Determines if this JailCell... this should be in CellDoor
/;
bool function IsRegisteredCellDoorInPrison(int aiCellDoorFormID)
    return true ; temporary
endFunction

bool function IsInitialized()
    return self.Prison && self.CellDoor
endFunction

function BindPrison(RPB_Prison akPrison)
    __prison = akPrison

    if (!self.Prison)
        Debug(self, "JailCell::BindPrison", "Could not bind the jail cell " + self + " to the Prison " + akPrison)
        return
    endif

    ; To be loaded depending on jail cell size
    self.CellRadius = 300

    ; Get the cell door belonging to this jail cell (by scanning for the nearest door of the type requested)
    int jailBaseDoorIdForPrison = GetJailBaseDoorID(self.Prison.Hold)
    ; RPB_CellDoor _cellDoor = GetNearestJailDoorOfType(jailBaseDoorIdForPrison, self, 4000) as RPB_CellDoor
    ObjectReference _cellDoor = GetNearestJailDoorOfType(jailBaseDoorIdForPrison, self, 4000)


    ; Bind the cell door to the jail cell
    self.BindCellDoor(_cellDoor as RPB_CellDoor)
endFunction

function BindCellDoor(RPB_CellDoor akCellDoor)
    ; Bind the cell door to this jail cell
    __cellDoor = akCellDoor

    ; Bind this jail cell to the cell door (to retrieve this from the cell door)
    akCellDoor.BindCell(self)
endFunction

;/
    Registers the passed in Prisoner to this Jail Cell,
    the value is stored as:
    Cell[FormID] = 0x14
/;
function RegisterPrisoner(RPB_Prisoner akPrisoner)
    if (!__prisonersInCell)
        __prisonersInCell = JMap.object()
        JValue.retain(__prisonersInCell)
    endif

    ; Helper.IntMap_SetForm(self.GetIdentifier(), akPrisoner.GetIdentifier(), akPrisoner.GetActor())
    JMap.setForm(__prisonersInCell, akPrisoner.GetIdentifier(), akPrisoner.GetActor())
    ; MiscVars.SetString("Cell[" + self.GetFormID() + "]", akPrisoner.GetIdentifier(), "Prison/Cells")
endFunction

function UnregisterPrisoner(RPB_Prisoner akPrisoner)
    JMap.removeKey(__prisonersInCell, akPrisoner.GetIdentifier())
endFunction

function DetermineCellParameters()
    ; if (!self.IsEmpty)
    ;     ; Don't do anything, cell is not empty which means the parameters have already been set most likely
    ;     return
    ; endif

    if (self.PrisonerCount > 0)
        Form prisonerForm = JMap.getForm(__prisonersInCell, JMap.getNthKey(__prisonersInCell, 0)) ; Get the first prisoner
        RPB_Prisoner prisonerRef = Prison.GetPrisonerReference(prisonerForm as Actor)

        ; If the first prisoner will be/is stripped naked / to underwear, set this cell as gender exclusive for them if the cell is not yet gender exclusive
        if (!self.IsGenderExclusive && (prisonerRef.WillBeStrippedNaked || prisonerRef.WillBeStrippedToUnderwear) || (prisonerRef.IsStrippedNaked || prisonerRef.IsStrippedToUnderwear))
            self.SetExclusiveToPrisonerSex(prisonerRef)
        endif

    else
        ; No prisoners in this cell
        ; Unset this cell as being female/male only, as it is now empty
        self.RemoveGenderExclusiveness()
    endif
endFunction

function DetermineCellAvailability()

endFunction

; bool function IsCellDoorBound()
;     return MiscVars.GetReference("Cell["+ self.GetFormID() +"]->Cell/Door") != none
; endFunction

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

        ; string sentenceInfo = Prison.DEBUG_GetPrisonerSentenceInfo(prisonerRef, true)
        ; outputPrisoners += "\t\t"+ prisonerRef.GetActor() + " " + prisonerRef.GetName() + " " + "(" + prisonerRef.GetSex(true) + ")" + string_if (prisonerRef.IsSentenceSet, ": " + sentenceInfo) + "\n"
        outputPrisoners += "\t\t"+ prisonerRef.GetActor() + " " + prisonerRef.GetName() + " " + "(" + prisonerRef.GetSex(true) + ")" + "\n"

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