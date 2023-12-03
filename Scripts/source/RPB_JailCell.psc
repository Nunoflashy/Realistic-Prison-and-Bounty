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

RPB_Guard property Guard
    RPB_Guard function get()
        return self.GetGuard()
    endFunction
endProperty

RPB_Prisoner[] __prisoners
RPB_Prisoner[] property Prisoners
    RPB_Prisoner[] function get()
        return self.GetPrisoners()
    endFunction
endProperty

bool __isEmpty
bool property IsEmpty
    bool function get()
        return __isEmpty
    endFunction
endProperty

bool __isAvailable
bool property IsAvailable
    bool function get()
        return __isAvailable
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

; ;/
;     Retrieves the door of this jail cell.
; /;
; RPB_CellDoor function GetCellDoor()

; endFunction


ObjectReference function GetMarker()
    
endFunction

;/
    Retrieves the guard this jail cell is assigned to
/;
RPB_Guard function GetGuard()

endFunction

ObjectReference[] function GetBeds()
    
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

function SetMaxPrisoners(int aiPrisonerCount)

endFunction

; Scans the jail cell to update any properties accordingly
function Scan()

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

    ; Start out as an empty cell
    __isEmpty = true

    ; Which means it is also available
    __isAvailable = true

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
    if (!self.IsEmpty)
        ; Don't do anything, cell is not empty which means the parameters have already been set most likely
        return
    endif

    if (self.PrisonerCount > 0)
        __isEmpty = false

        Form prisonerForm = JMap.getForm(__prisonersInCell, JMap.getNthKey(__prisonersInCell, 0)) ; Get the first prisoner
        RPB_Prisoner prisonerRef = Prison.GetPrisonerReference(prisonerForm as Actor)

        ; If the first prisoner will be/is stripped naked / to underwear, set this cell as gender exclusive for them if the cell is not yet gender exclusive
        if (!self.IsGenderExclusive && (prisonerRef.WillBeStrippedNaked || prisonerRef.WillBeStrippedToUnderwear) || (prisonerRef.IsStrippedNaked || prisonerRef.IsStrippedToUnderwear))
            self.SetExclusiveToPrisonerSex(prisonerRef)
        endif

    else
        ; No prisoners in this cell
        __isEmpty = true

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
        "\t Available: " + self.IsAvailable + "\n" + \
        "\t Gender Exclusive: " + self.IsGenderExclusive + string_if (self.IsGenderExclusive, " ("+ getGenderExclusivenessAsString +")") + "\n" + \
        "\t Prisoners: " + self.PrisonerCount + string_if (_hasPrisoners, " -> [\n"+ self.DEBUG_GetPrisoners() +"\t]") + "\n" + \
    "]"
endFunction