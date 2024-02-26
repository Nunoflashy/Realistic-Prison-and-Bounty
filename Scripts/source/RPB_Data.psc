scriptname RPB_Data hidden
{
    Script responsible of handling anything related to the data required for static configuration of the Holds.
}

import RPB_Utility

; ==========================================================
;                           MCM
; ==========================================================

string function MCM_GetRootPropertyOfTypeString(string asMcmObjectName, string asProperty) global
    int mcmConfig   = JValue.readFromFile(GetModDataDirectory() + "mcm.json") ; JMap&
    int mcmObject   = JMap.getObj(mcmConfig, asMcmObjectName) ; JMap&

    string rootProperty = JMap.getStr(mcmObject, asProperty)
    return rootProperty
endFunction

string[] function MCM_GetRootPropertyOfTypeStringArray(string asMcmObjectName, string asProperty) global
    int mcmConfig   = JValue.readFromFile(GetModDataDirectory() + "mcm.json") ; JMap&
    int mcmObject   = JMap.getObj(mcmConfig, asMcmObjectName) ; JMap&

    int rootProperty = JMap.getObj(mcmObject, asProperty)
    return JArray.asStringArray(rootProperty)
endFunction

int function MCM_GetOptionObject() global
    int mcmConfig   = JValue.readFromFile(GetModDataDirectory() + "mcm.json") ; JMap&
    int mcmObject   = JMap.getObj(mcmConfig, "Config") ; JMap&

    int obj = JMap.getObj(mcmObject, "Options")
    return obj
endFunction

int function MCM_GetDefaultsObject() global
    int mcmConfig   = JValue.readFromFile(GetModDataDirectory() + "mcm.json") ; JMap&
    int mcmObject   = JMap.getObj(mcmConfig, "Config") ; JMap&

    int defaultsObj = JMap.getObj(mcmObject, "Defaults")
    return defaultsObj
endFunction

int function MCM_GetMaximumsObject() global
    int mcmConfig   = JValue.readFromFile(GetModDataDirectory() + "mcm.json") ; JMap&
    int mcmObject   = JMap.getObj(mcmConfig, "Config") ; JMap&

    int obj = JMap.getObj(mcmObject, "Maximums")
    return obj
endFunction

string[] function MCM_GetChildPropertyOfTypeStringArray(string asMcmObjectName, string asChildName, string asProperty) global
    int mcmConfig   = JValue.readFromFile(GetModDataDirectory() + "mcm.json") ; JMap&
    int mcmObject   = JMap.getObj(mcmConfig, asMcmObjectName) ; JMap&
    int childObject = JMap.getObj(mcmObject, asChildName) ; JMap&

    int childProperty = JMap.getObj(childObject, asProperty)
    return JArray.asStringArray(childProperty)
endFunction

int function MCM_GetRootPropertyOfTypeObject(string asMcmObjectName, string asProperty) global
    int mcmConfig   = JValue.readFromFile(GetModDataDirectory() + "mcm.json") ; JMap&
    int mcmObject   = JMap.getObj(mcmConfig, asMcmObjectName) ; JMap&

    int rootProperty = JMap.getObj(mcmObject, asProperty)
    return rootProperty
endFunction

string function MCM_GetPrisonTemplate() global
    int mcmConfig   = JValue.readFromFile(GetModDataDirectory() + "mcm.json") ; JMap&
    int statsObj    = JMap.getObj(mcmConfig, "Stats") ; JMap&
    int prisonObj   = JMap.getObj(statsObj, "Prison")

    string prisonTemplate = JMap.getStr(prisonObj, "Template")

    return prisonTemplate
endFunction

; ==========================================================
;                        Serialization
; ==========================================================

string function GetModDataDirectory() global
    return "Data/RPB_Data/"
endFunction

string function GetDataFile() global
    return "data.json"
endFunction

;/
    Retrieves the root of a hold from the data file specified through @asHold.
    Alternatively, if no hold is specified, the root item of the data file is returned,
    containing every hold.

    string?  @asHold: The hold to retrieve.

    returns (JMap&): A reference to the root object containing all of the Holds, or the specified Hold if specified.
/;
int function GetRootObject(string asHold = "/") global
    int configFile
    bool rootIsLoaded = JDB.hasPath(".rpb_root.data")

    if (rootIsLoaded)
        configFile = JDB.solveObj(".rpb_root.data")
    else
        configFile = Unserialize()
    endif
    
    if (asHold == "/")
        return configFile ; Return the root item of the config file, no hold specified
    endif

    int holdRootItem = JMap.getObj(configFile, asHold)

    return holdRootItem
endFunction

;/
    Sets @apRootContainer to be the root container of the data.
/;
bool function SetRootContainer(int apRootContainer) global
    JDB.setObj("rpb_root.data", apRootContainer)
endFunction

;/
    Binds the container @apContainerToBind to the key @asKey to be the root of this path.
/;
bool function BindContainerToKey(string asKey, int apContainerToBind) global
    JDB.setObj(asKey, apContainerToBind)
endFunction

;/
    Writes the container @apContainer to the main data file.
/;
function Serialize(int apContainer) global
    JValue.writeToFile(apContainer, GetModDataDirectory() + GetDataFile())
endFunction

;/
    Reads all the data from the main data file into the returned object.

    returns (JMap&): A reference to the root object.
/;
int function Unserialize() global
    int unserializedData = JValue.readFromFile(GetModDataDirectory() + GetDataFile())
    SetRootContainer(unserializedData)

    return unserializedData
endFunction

;/
    Refreshes the root item currently stored in .rpb_root with the new content
    from the data file.
/;
int function RefreshRootObject() global
    return Unserialize()
endFunction

; Same as Unserialize()
int function LoadData() global
    return Unserialize()
endFunction

;/
    Saves the root object into the main data file.
/;
function SaveRoot() global
    int rootItem = GetRootObject()
    Serialize(rootItem)
endFunction

; ==========================================================
;                       Object Getters
; ==========================================================

;/
    Returns the object in the data file that holds the jail cell of a specific parent.

    JMap&           @apHoldJailObject: The reference to the jail object of the hold.
    RPB_JailCell    @akJailCell: The jail cell parent reference.

    returns (JMap&): A reference to the object containing the jail cell parent along with its properties.
/;
int function RawObject_GetJailCellParent(int apHoldJailObject, RPB_JailCell akJailCell) global
    int formMap_cellsDataContent    = JMap.getObj(apHoldJailObject, "Cells")                    ; JFormMap&
    int map_parentCellObject        = JFormMap.getObj(formMap_cellsDataContent, akJailCell)     ; JMap&

    Debug(none, "Data::RawObject_GetJailCellParent", GetContainerList(map_parentCellObject))

    return map_parentCellObject
endFunction

;/
    Checks if the object has the specified property.

    JMap&   @apObject: The reference to the object to check.
    string  @asPropertyName: The property to check the existence of in the object.

    returns (bool): Whether or not the property exists in this object.
/;
bool function RawObject_HasProperty(int apObject, string asPropertyName)
    return JMap.hasKey(apObject, asPropertyName)
endFunction

; ==========================================================
;                         Data Getters
; ==========================================================

;/
    Retrieves the jail object of a hold from the data file obtained from the hold's root object.

    JMap& @apHoldRootObject: The reference to the root object of this hold.

    returns (JMap&): The reference to the jail object of this Hold.
/;
int function Hold_GetJailObject(int apHoldRootObject) global
    return JMap.getObj(apHoldRootObject, "Jail") ; JMap&
endFunction

;/
    Retrieves the locations of a specific hold through its root object

    JMap& @apHoldRootObject: The reference to the root object of this hold.

    returns (Form[]): The locations of this Hold.
/;
Form[] function Hold_GetLocations(int apHoldRootObject) global
    int array_locations = JMap.getObj(apHoldRootObject, "Locations") ; JArray&
    return JArray.asFormArray(array_locations)
endFunction

;/
    Retrieves the hold's crime faction through its root object

    JMap& @apHoldRootObject: The reference to the root object of this hold.

    returns (Faction): This Hold's Crime Faction.
/;
Faction function Hold_GetCrimeFaction(int apHoldRootObject) global
    Form factionForm = JMap.getForm(apHoldRootObject, "Crime Faction")
    return factionForm as Faction
endFunction

;/
    Retrieves the city from the hold's root object.
    
    JMap& @apHoldRootObject: The reference to the root object of this hold.

    returns (string): The city of this Hold.
/;
string function Hold_GetCity(int apHoldRootObject) global
    string city = JMap.getStr(apHoldRootObject, "City")
    return city
endFunction

;/
    Retrieves the jail cells object of a Jail from the data file obtained from the jail's object.

    JMap& @apHoldJailObject: The reference to the jail object of this hold.

    returns (JFormMap&): The reference to the jail cells object of this Jail.
/;
int function Jail_GetCellsObject(int apHoldJailObject) global
    int formMap_jailCells = JMap.getObj(apHoldJailObject, "Cells") ; JFormMap&
    return formMap_jailCells
endFunction

;/
    Retrieves the configured guards for the prison.

    JMap&   @apHoldJailObject: The reference to the jail object.

    returns (Form[]): The guards of this prison.
/;
Form[] function Jail_GetGuards(int apHoldJailObject) global
    int array_guards = JMap.getObj(apHoldJailObject, "Guards") ; JArray& (Form[])
    return JArray.asFormArray(array_guards)
endFunction

;/
    Retrieves a root property of type bool from a Prison.

    JMap&           @apHoldJailObject: The reference to the jail object.
    string          @asProperty: The name of the property.

    returns (bool): A root property of type bool from the Prison.
/;
bool function Jail_GetRootPropertyOfTypeBool(int apHoldJailObject, string asProperty) global
    return Jail_GetRootPropertyOfTypeInt(apHoldJailObject, asProperty) as bool
endFunction

;/
    Retrieves a root property of type int from a Prison.

    JMap&           @apHoldJailObject: The reference to the jail object.
    string          @asProperty: The name of the property.

    returns (int): A root property of type int from the Prison.
/;
int function Jail_GetRootPropertyOfTypeInt(int apHoldJailObject, string asProperty) global
    return JMap.getInt(apHoldJailObject, asProperty)
endFunction

;/
    Retrieves a root property of type float from a Prison.

    JMap&           @apHoldJailObject: The reference to the jail object.
    string          @asProperty: The name of the property.

    returns (float): A root property of type float from the Prison.
/;
float function Jail_GetRootPropertyOfTypeFloat(int apHoldJailObject, string asProperty) global
    return JMap.getFlt(apHoldJailObject, asProperty)
endFunction

;/
    Retrieves a root property of type string from a Prison.

    JMap&           @apHoldJailObject: The reference to the jail object.
    string          @asProperty: The name of the property.

    returns (string): A root property of type string from the Prison.
/;
string function Jail_GetRootPropertyOfTypeString(int apHoldJailObject, string asProperty) global
    return JMap.getStr(apHoldJailObject, asProperty)
endFunction

;/
    Retrieves a root property of type Form from a Prison.

    JMap&           @apHoldJailObject: The reference to the jail object.
    Form            @asProperty: The name of the property.

    returns (Form): A root property of type Form from the Prison.
/;
Form function Jail_GetRootPropertyOfTypeForm(int apHoldJailObject, string asProperty) global
    return JMap.getForm(apHoldJailObject, asProperty)
endFunction


;/
    Retrieves a jail cell by its ID from a Prison.

    JMap&   @apHoldJailObject: The reference to the prison object.
    string  @asCellID: The ID of the jail cell.

    returns (RPB_JailCell): An RPB_JailCell instance that has this ID.
/;
RPB_JailCell function Jail_GetJailCellByID(int apHoldJailObject, string asCellID) global
    int prisonCellsObj  = JMap.getObj(apHoldJailObject, "Cells") ; JFormMap&
    int cellsObjects    = JFormMap.allValues(prisonCellsObj) ; JArray<JMap>
    int numberOfCells   = JValue.count(prisonCellsObj)

    int i = 0
    while (i < numberOfCells)
        int cellObj     = JArray.getObj(cellsObjects, i) ; JMap&
        string cellId   = JMap.getStr(cellObj, "ID")

        if (cellId == asCellID)
            Form cellForm = JFormMap.getNthKey(prisonCellsObj, i)
            return cellForm as RPB_JailCell
        endif
        i += 1
    endWhile

    return none
endFunction

;/
    Retrieves the parent Forms of the jail cells.

    JMap&   @apHoldJailObject: The reference to the jail object.

    returns (Form[]): All the jail cell parents.
/;
Form[] function GetJailCellParents(int apHoldJailObject) global
    int formMap_cellsDataContent    = JMap.getObj(apHoldJailObject, "Cells")        ; JFormMap&
    int array_cellsKeys             = JFormMap.allKeys(formMap_cellsDataContent)    ; JArray& (Form[])

    Form[] asFormArray = JArray.asFormArray(array_cellsKeys)

    return asFormArray
endFunction

;/
    Gets the child markers of this jail cell.

    JMap&   @apHoldJailObject: The reference to the jail object.
    Form    @akParentForm: The parent form of this jail cell.
    string  @asInteriorOrExterior: Whether to retrieve the Interior or Exterior child markers.

    returns (Form[]): The child markers of the jail cell.
/;
Form[] function GetJailCellChildren(int apHoldJailObject, Form akParentForm, string asInteriorOrExterior = "Interior") global
    if (asInteriorOrExterior != "Interior" && asInteriorOrExterior != "Exterior")
        return none
    endif

    int formMap_cells           = JMap.getObj(apHoldJailObject, "Cells")                    ; JFormMap&
    int map_cellDataContent     = JFormMap.getObj(formMap_cells, akParentForm)              ; JMap& - Get the cell object with this parent key
    int array_childrenAsObject  = JMap.getObj(map_cellDataContent, asInteriorOrExterior)    ; JArray& (Form[])

    Debug(none, "Config::GetJailCellChildMarkers", akParentForm + "'s " + asInteriorOrExterior +" Children: " + GetContainerList(array_childrenAsObject))

    Form[] childrenAsForms = JArray.asFormArray(array_childrenAsObject)
    return childrenAsForms
endFunction

;/
    Retrieves the property base object for a particular Jail Cell with the parameters specified.

    JFormMap&       @apPrisonCellsObject: The reference to the Cells object for the given Prison (Cells in the data file).
    RPB_JailCell    @akJailCell: The jail cell.
    string          @asPropertyCategory: The root category of the property.
    string[]?       @asArrPropertySubCategories: The nested categories within the root category for this property, if there are any.
    int?            @aiSubCategoriesLimitSize: The number of elements to take into account for the sub-categories if the array is bigger than desired.

    returns (JMap&): The base object specified through the parameters for this jail cell.
/;
int function JailCell_GetPropertyBaseObject(int apPrisonCellsObject, RPB_JailCell akJailCell, string asPropertyCategory = "null", string[] asArrPropertySubCategories = none, int aiSubCategoriesLimitSize = 0) global
    int map_cellDataContent     = JFormMap.getObj(apPrisonCellsObject, akJailCell) ; JMap& - Get the cell object with this parent key

    if (asPropertyCategory == "null")
        return map_cellDataContent ; this is the root object, no categories have been specified
    endif

    int map_propertyCategory    = JMap.getObj(map_cellDataContent, asPropertyCategory)
    int map_propertySubCategory = map_propertyCategory
    int map_finalPropertyObject = map_propertyCategory

    ; There are sub-categories to this property
    if (asArrPropertySubCategories.Length > 0)
        int desiredArraySize = int_if (aiSubCategoriesLimitSize > 0, Min(aiSubCategoriesLimitSize, asArrPropertySubCategories.Length) as int, asArrPropertySubCategories.Length)
        int i = 0
        while (i < desiredArraySize)
            string currentStoredCategory = asArrPropertySubCategories[i]
            if (currentStoredCategory)
                ; Iterate through the container recursively until we find the option
                map_propertySubCategory = JMap.getObj(map_propertySubCategory, currentStoredCategory)
            endif
            i += 1
        endWhile

        map_finalPropertyObject = map_propertySubCategory
    endif

    return map_finalPropertyObject
endFunction

;/
    Retrieves a root property of type bool from a Jail Cell.

    JFormMap&       @apPrisonCellsObject: The reference to the Cells object for the given Prison (Cells in the data file).
    RPB_JailCell    @akJailCell: The jail cell.
    string          @asProperty: The name of the property.

    returns (bool): A root property of type bool from the Jail Cell.
/;
bool function JailCell_GetRootPropertyOfTypeBool(int apPrisonCellsObject, RPB_JailCell akJailCell, string asProperty) global
    return JailCell_GetRootPropertyOfTypeInt(apPrisonCellsObject, akJailCell, asProperty) as bool
endFunction

;/
    Retrieves a root property of type int from a Jail Cell.

    JFormMap&       @apPrisonCellsObject: The reference to the Cells object for the given Prison (Cells in the data file).
    RPB_JailCell    @akJailCell: The jail cell.
    string          @asProperty: The name of the property.

    returns (int): A root property of type int from the Jail Cell.
/;
int function JailCell_GetRootPropertyOfTypeInt(int apPrisonCellsObject, RPB_JailCell akJailCell, string asProperty) global
    int map_cellDataContent     = JailCell_GetPropertyBaseObject(apPrisonCellsObject, akJailCell) ; JMap& - Get the cell object with this parent key
    int intProperty             = JMap.getInt(map_cellDataContent, asProperty)
    
    return intProperty
endFunction

;/
    Retrieves a root property of type float from a Jail Cell.

    JFormMap&       @apPrisonCellsObject: The reference to the Cells object for the given Prison (Cells in the data file).
    RPB_JailCell    @akJailCell: The jail cell.
    string          @asProperty: The name of the property.

    returns (float): A root property of type float from the Jail Cell.
/;
float function JailCell_GetRootPropertyOfTypeFloat(int apPrisonCellsObject, RPB_JailCell akJailCell, string asProperty) global
    int map_cellDataContent     = JailCell_GetPropertyBaseObject(apPrisonCellsObject, akJailCell) ; JMap& - Get the cell object with this parent key
    float floatProperty         = JMap.getFlt(map_cellDataContent, asProperty)
    
    return floatProperty
endFunction

;/
    Retrieves a root property of type string from a Jail Cell.

    JFormMap&       @apPrisonCellsObject: The reference to the Cells object for the given Prison (Cells in the data file).
    RPB_JailCell    @akJailCell: The jail cell.
    string          @asProperty: The name of the property.

    returns (string): A root property of type string from the Jail Cell.
/;
string function JailCell_GetRootPropertyOfTypeString(int apPrisonCellsObject, RPB_JailCell akJailCell, string asProperty) global
    int map_cellDataContent     = JailCell_GetPropertyBaseObject(apPrisonCellsObject, akJailCell) ; JMap& - Get the cell object with this parent key
    string stringProperty       = JMap.getStr(map_cellDataContent, asProperty)
    
    return stringProperty
endFunction

;/
    Retrieves a root property of type Form from a Jail Cell.

    JFormMap&       @apPrisonCellsObject: The reference to the Cells object for the given Prison (Cells in the data file).
    RPB_JailCell    @akJailCell: The jail cell.
    string          @asProperty: The name of the property.

    returns (Form): A root property of type Form from the Jail Cell.
/;
Form function JailCell_GetRootPropertyOfTypeForm(int apPrisonCellsObject, RPB_JailCell akJailCell, string asProperty) global
    int map_cellDataContent     = JailCell_GetPropertyBaseObject(apPrisonCellsObject, akJailCell) ; JMap& - Get the cell object with this parent key
    Form formProperty           = JMap.getForm(map_cellDataContent, asProperty)

    return formProperty
endFunction

;/
    Retrieves a root property of type Form[] from a Jail Cell.

    JFormMap&       @apPrisonCellsObject: The reference to the Cells object for the given Prison (Cells in the data file).
    RPB_JailCell    @akJailCell: The jail cell.
    string          @asProperty: The name of the property.

    returns (Form[]): A root property of type Form[] from the Jail Cell.
/;
Form[] function JailCell_GetRootPropertyOfTypeFormArray(int apPrisonCellsObject, RPB_JailCell akJailCell, string asProperty) global
    int map_cellDataContent     = JailCell_GetPropertyBaseObject(apPrisonCellsObject, akJailCell) ; JMap& - Get the cell object with this parent key
    int propertyContainer       = JMap.getObj(map_cellDataContent, asProperty) ; any& <JContainer>

    if (JValue.isArray(propertyContainer))
        return JArray.asFormArray(propertyContainer)

    elseif (JValue.isFormMap(propertyContainer))
        return JFormMap.allKeysPArray(propertyContainer)
    endif

    return none
endFunction

;/
    Retrieves a root property of type string[] from a Jail Cell.

    JFormMap&       @apPrisonCellsObject: The reference to the Cells object for the given Prison (Cells in the data file).
    RPB_JailCell    @akJailCell: The jail cell.
    string          @asProperty: The name of the property.

    returns (string[]): A root property of type string[] from the Jail Cell.
/;
string[] function JailCell_GetRootPropertyOfTypeStringArray(int apPrisonCellsObject, RPB_JailCell akJailCell, string asProperty) global
    int map_cellDataContent = JailCell_GetPropertyBaseObject(apPrisonCellsObject, akJailCell) ; JMap& - Get the cell object with this parent key
    int propertyContainer   = JMap.getObj(map_cellDataContent, asProperty) ; any& <JContainer>

    if (JValue.isArray(propertyContainer))
        return JArray.asStringArray(propertyContainer)

    elseif (JValue.isMap(propertyContainer))
        return JMap.allKeysPArray(propertyContainer)
    endif

    return none
endFunction

;/
    Gets the main marker of this jail cell.

    JFormMap&       @apPrisonCellsObject: The reference to the Cells object for the given Prison (Cells in the data file).
    RPB_JailCell    @akJailCell: The parent form of this jail cell.
    string          @asInteriorOrExterior: Whether to retrieve the Interior or Exterior marker.

    returns (Form): The main marker of this jail cell.
/;
Form function JailCell_GetMainMarker(int apPrisonCellsObject, RPB_JailCell akJailCell, string asInteriorOrExterior = "Interior") global
    if (asInteriorOrExterior != "Interior" && asInteriorOrExterior != "Exterior")
        return none
    endif

    return JailCell_GetRootPropertyOfTypeForm(apPrisonCellsObject, akJailCell, "Main " + asInteriorOrExterior)
endFunction

;/
    Retrieves the parent Forms of the jail cells. 
    Each element is able to be cast to a RPB_JailCell.

    JFormMap&   @apPrisonCellsObject: The reference to the Cells object for the given Prison (Cells in the data file).
    bool        @abOnlyActiveCells: Whether to retrieve only Cells marked as active.

    returns (Form[]): All the jail cell parents.
/;
Form[] function JailCell_GetParents(int apPrisonCellsObject, bool abOnlyActiveCells = true) global
    int array_cellsKeys = JFormMap.allKeys(apPrisonCellsObject) ; JArray& (RPB_JailCell[])

    if (abOnlyActiveCells)
        int array_allCellObjects    = JFormMap.allValues(apPrisonCellsObject) ; JArray& (JMap[])
        int activeCells             = JArray.object()
    
        int i = 0
        while (i < JValue.count(array_allCellObjects))
            int currentJailCellObj = JArray.getObj(array_allCellObjects, i) ; JMap&
            bool isActiveCell      = JMap.getInt(currentJailCellObj, "Active") as bool
    
            if (isActiveCell)
                Form currentJailCellForm = JArray.getForm(array_cellsKeys, i)
                JArray.addForm(activeCells, currentJailCellForm)
            endif
            i += 1
        endWhile
    
        if (JValue.count(activeCells) <= 0)
            return none
        endif
    
        Form[] asFormArray  = JArray.asFormArray(activeCells)
        return asFormArray
    endif

    return JArray.asFormArray(array_cellsKeys)
endFunction

;/
    Gets the child markers of this jail cell.

    JFormMap&       @apPrisonCellsObject: The reference to the Cells object for the given Prison (Cells in the data file).
    RPB_JailCell    @akParentForm: The parent form of this jail cell.
    string          @asInteriorOrExterior: Whether to retrieve the Interior or Exterior child markers.

    returns (Form[]): The child markers of the jail cell.
/;
Form[] function JailCell_GetChildren(int apPrisonCellsObject, RPB_JailCell akJailCell, string asInteriorOrExterior = "Interior") global
    if (asInteriorOrExterior != "Interior" && asInteriorOrExterior != "Exterior")
        return none
    endif

    int map_cellDataContent     = JFormMap.getObj(apPrisonCellsObject, akJailCell)              ; JMap& - Get the cell object with this parent key
    int array_childrenAsObject  = JMap.getObj(map_cellDataContent, asInteriorOrExterior)        ; JArray& (Form[])

    Debug(none, "Data::JailCell_GetChildren", akJailCell + "'s " + asInteriorOrExterior +" Children: " + GetContainerList(array_childrenAsObject))

    Form[] childrenAsForms = JArray.asFormArray(array_childrenAsObject)
    return childrenAsForms
endFunction


;/
    Retrieves an option of type bool from a Jail Cell.

    JFormMap&       @apPrisonCellsObject: The reference to the Cells object for the given Prison (Cells in the data file).
    RPB_JailCell    @akJailCell: The jail cell.
    string          @asOption: The name of the Option.
    string          @asOptionCategory: The category of the Option.

    returns (bool): An Option of type bool.
/;
bool function JailCell_GetOptionOfTypeBool(int apPrisonCellsObject, RPB_JailCell akJailCell, string asOption, string asOptionCategory = "null") global
    int map_cellDataContent     = JFormMap.getObj(apPrisonCellsObject, akJailCell)      ; JMap& - Get the cell object with this parent key
    int map_options             = JMap.getObj(map_cellDataContent, "Options")           ; JMap& - The options for this cell
    int map_finalOptionObject   = map_options ; Default to main Options category

    if (asOptionCategory != "null")
        ; We got a sub option object (such as Scan), change the final object to retrieve the option from
        map_finalOptionObject = JMap.getObj(map_options, asOptionCategory)
    endif

    bool selectedOption = JMap.getInt(map_finalOptionObject, asOption) as bool ; The bool option

    return selectedOption
endFunction

;/
    Retrieves an option of type int from a Jail Cell.

    JFormMap&       @apPrisonCellsObject: The reference to the Cells object for the given Prison (Cells in the data file).
    RPB_JailCell    @akJailCell: The jail cell.
    string          @asOption: The name of the Option.
    string          @asOptionCategory: The category of the Option.

    returns (int): An Option of type int.
/;
int function JailCell_GetOptionOfTypeInt(int apPrisonCellsObject, RPB_JailCell akJailCell, string asOption, string asOptionCategory = "null") global
    int map_cellDataContent     = JFormMap.getObj(apPrisonCellsObject, akJailCell)      ; JMap& - Get the cell object with this parent key
    int map_options             = JMap.getObj(map_cellDataContent, "Options")           ; JMap& - The options for this cell
    int map_finalOptionObject   = map_options ; Default to main Options category

    if (asOptionCategory != "null")
        ; We got a sub option object (such as Scan), change the final object to retrieve the option from
        map_finalOptionObject = JMap.getObj(map_options, asOptionCategory)
    endif

    int selectedOption          = JMap.getInt(map_finalOptionObject, asOption)

    return selectedOption

    ; string[] subCategories = new string[1]
    ; subCategories[0] = asOptionCategory
    ; int optionBaseObject = JailCell_GetPropertyBaseObject(apPrisonCellsObject, akJailCell, "Options", subCategories)
endFunction

;/
    Retrieves an option of type float from a Jail Cell.

    JFormMap&       @apPrisonCellsObject: The reference to the Cells object for the given Prison (Cells in the data file).
    RPB_JailCell    @akJailCell: The jail cell.
    string          @asOption: The name of the Option.
    string          @asOptionCategory: The category of the Option.

    returns (float): An Option of type float.
/;
float function JailCell_GetOptionOfTypeFloat(int apPrisonCellsObject, RPB_JailCell akJailCell, string asOption, string asOptionCategory = "null") global
    int map_cellDataContent     = JFormMap.getObj(apPrisonCellsObject, akJailCell)      ; JMap& - Get the cell object with this parent key
    int map_options             = JMap.getObj(map_cellDataContent, "Options")           ; JMap& - The options for this cell
    int map_finalOptionObject   = map_options ; Default to main Options category

    if (asOptionCategory != "null")
        ; We got a sub option object (such as Scan), change the final object to retrieve the option from
        map_finalOptionObject = JMap.getObj(map_options, asOptionCategory)
    endif

    float selectedOption          = JMap.getFlt(map_finalOptionObject, asOption)

    return selectedOption
endFunction

;/
    Retrieves an option of type string from a Jail Cell.

    JFormMap&       @apPrisonCellsObject: The reference to the Cells object for the given Prison (Cells in the data file).
    RPB_JailCell    @akJailCell: The jail cell.
    string          @asOption: The name of the Option.
    string          @asOptionCategory: The category of the Option.

    returns (string): An Option of type string.
/;
string function JailCell_GetOptionOfTypeString(int apPrisonCellsObject, RPB_JailCell akJailCell, string asOption, string asOptionCategory = "null") global
    int map_cellDataContent     = JFormMap.getObj(apPrisonCellsObject, akJailCell)      ; JMap& - Get the cell object with this parent key
    int map_options             = JMap.getObj(map_cellDataContent, "Options")           ; JMap& - The options for this cell
    int map_finalOptionObject   = map_options ; Default to main Options category

    if (asOptionCategory != "null")
        ; We got a sub option object (such as Scan), change the final object to retrieve the option from
        map_finalOptionObject = JMap.getObj(map_options, asOptionCategory)
    endif

    string selectedOption       = JMap.getStr(map_finalOptionObject, asOption)                ; The string option

    return selectedOption
endFunction

;/
    Retrieves an option of type Form from a Jail Cell.

    JFormMap&       @apPrisonCellsObject: The reference to the Cells object for the given Prison (Cells in the data file).
    RPB_JailCell    @akJailCell: The jail cell.
    string          @asOption: The name of the Option.
    string          @asOptionCategory: The category of the Option.

    returns (Form): An Option of type Form.
/;
Form function JailCell_GetOptionOfTypeForm(int apPrisonCellsObject, RPB_JailCell akJailCell, string asOption, string asOptionCategory = "null") global
    int map_cellDataContent     = JFormMap.getObj(apPrisonCellsObject, akJailCell)      ; JMap& - Get the cell object with this parent key
    int map_options             = JMap.getObj(map_cellDataContent, "Options")           ; JMap& - The options for this cell
    int map_finalOptionObject   = map_options ; Default to main Options category

    if (asOptionCategory != "null")
        ; We got a sub option object (such as Scan), change the final object to retrieve the option from
        map_finalOptionObject = JMap.getObj(map_options, asOptionCategory)
    endif

    Form selectedOption         = JMap.getForm(map_finalOptionObject, asOption)               ; The Form option

    return selectedOption
endFunction


bool function JailCell_HasLockDecayOptions(int apPrisonCellsObject, RPB_JailCell akJailCell) global
    int map_cellDataContent     = JFormMap.getObj(apPrisonCellsObject, akJailCell)      ; JMap& - Get the cell object with this parent key
    int map_options             = JMap.getObj(map_cellDataContent, "Options")           ; JMap& - The options for this cell
    int map_lockOptions         = JMap.getObj(map_options, "Lock")                      ; JMap& - The lock options for this cell
    int map_decayOptions        = JMap.getObj(map_lockOptions, "Decay Options")         ; JMap& - The lock decay options for this cell

    return !JValue.empty(map_decayOptions)
endFunction

bool function JailCell_HasLockDecayOption(int apPrisonCellsObject, RPB_JailCell akJailCell, string asOption, string asOptionCategory = "null") global
    int map_cellDataContent     = JFormMap.getObj(apPrisonCellsObject, akJailCell)      ; JMap& - Get the cell object with this parent key
    int map_options             = JMap.getObj(map_cellDataContent, "Options")           ; JMap& - The options for this cell
    int map_lockOptions         = JMap.getObj(map_options, "Lock")                      ; JMap& - The lock options for this cell
    int map_decayOptions        = JMap.getObj(map_lockOptions, "Decay Options")         ; JMap& - The lock decay options for this cell
    int map_finalOptionObject   = map_decayOptions

    if (asOptionCategory != "null")
        map_finalOptionObject = JMap.getObj(map_decayOptions, asOptionCategory)
    endif

    return JMap.hasKey(map_finalOptionObject, asOption) ; To be tested
endFunction

;/
    Retrieves the Objects of a Jail Cell, object type is specified through @asObjectCategory.

    JFormMap&       @apPrisonCellsObject: The reference to the Cells object for the given Prison (Cells in the data file).
    RPB_JailCell    @akJailCell: The jail cell.
    string          @asObjectCategory: The type of objects to check.

    returns (Form[]): The objects of a specific type.
/;
Form[] function JailCell_GetObjects(int apPrisonCellsObject, RPB_JailCell akJailCell, string asObjectCategory) global
    int map_cellDataContent     = JFormMap.getObj(apPrisonCellsObject, akJailCell)      ; JMap& - Get the cell object with this parent key
    int map_objects             = JMap.getObj(map_cellDataContent, "Objects")           ; JMap& - The Objects for this cell
    int array_finalObjectRef    = JMap.getObj(map_objects, asObjectCategory)            ; JArray& - The actual objects content

    Form[] selectedObjects = JArray.asFormArray(array_finalObjectRef)
    return selectedObjects
endFunction


;/
    Checks if a given jail cell has an option, determined by @asOptionCategory, optionally checking if the contents are empty or not.

    JFormMap&       @apPrisonCellsObject: The reference to the Cells object for the given Prison (Cells in the data file).
    RPB_JailCell    @akJailCell: The jail cell to check the existence of options.
    string          @asOption: The name of the option to check.
    string?         @asOptionCategory: The category of options to check.
    bool?           @abCheckEmptyContent: Whether to check for the options' empty content.

    returns (bool): Whether the jail cell has options of the specified type.
/;
bool function JailCell_HasOption(int apPrisonCellsObject, RPB_JailCell akJailCell, string asOption, string asOptionCategory = "null", bool abCheckEmptyContent = false) global
    int map_cellDataContent     = JFormMap.getObj(apPrisonCellsObject, akJailCell)      ; JMap& - Get the cell object with this parent key
    int map_options             = JMap.getObj(map_cellDataContent, "Options")           ; JMap& - The options for this cell
    int map_finalOptionObject   = map_options ; Default to main Options category

    if (asOptionCategory != "null")
        bool optionCategoryExists = JMap.hasKey(map_options, asOptionCategory)
        if (!optionCategoryExists)
            Error("Option category " + asOptionCategory + " does not exist for jail cell " + akJailCell + "!")
            DebugError("Data::HasJailCellOption", "Option category " + asOptionCategory + " does not exist for jail cell " + akJailCell + "!")
            return false
        endif

        ; We got a sub option object (such as Scan), change the final object to retrieve the option from
        map_finalOptionObject = JMap.getObj(map_options, asOptionCategory)

        if (abCheckEmptyContent)
            int subObjectsCategoryContainer = JMap.getObj(map_finalOptionObject, asOptionCategory)
            bool isEmpty = JValue.empty(subObjectsCategoryContainer)
    
            return map_finalOptionObject && !isEmpty
        endif
    endif

    ; Debug(none, "Data::HasJailCellOption", akJailCell + " Meets Criteria: " + (map_options && JMap.hasKey(map_finalOptionObject, asOption)) + " - map_options: " + map_options + ", JMap.hasKey(map_finalOptionObject, asOption):" + JMap.hasKey(map_finalOptionObject, asOption) + ", map_finalOptionObject: " + GetContainerList(map_finalOptionObject))

    return map_options && JMap.hasKey(map_finalOptionObject, asOption)
endFunction

;/
    Checks if a given jail cell has any type of object, determined by @asObjectCategory, optionally checking if the contents are empty or not.

    JFormMap&       @apPrisonCellsObject: The reference to the Cells object for the given Prison (Cells in the data file).
    RPB_JailCell    @akJailCell: The jail cell to check the existence of objects.
    string          @asObjectCategory: The type of objects to check.
    bool?           @abCheckEmptyContent: Whether to check for the objects' empty content.

    returns (bool): Whether the jail cell has objects of the specified type.
/;
bool function JailCell_HasObjects(int apPrisonCellsObject, RPB_JailCell akJailCell, string asObjectCategory, bool abCheckEmptyContent = false) global
    int map_cellDataContent     = JFormMap.getObj(apPrisonCellsObject, akJailCell)      ; JMap& - Get the cell object with this parent key
    int map_objects             = JMap.getObj(map_cellDataContent, "Objects")           ; JMap& - The Objects for this cell

    bool hasSubObjectsCategory  = JMap.hasKey(map_objects, asObjectCategory)

    if (abCheckEmptyContent)
        int subObjectsCategoryContainer = JMap.getObj(map_objects, asObjectCategory) ; JArray&
        bool isEmpty = JValue.empty(subObjectsCategoryContainer)

        ; Debug(none, "Data::JailCell_HasObjects", "Objects("+ subObjectsCategoryContainer +"): " + GetContainerList(subObjectsCategoryContainer))
        ; Debug(none, "Data::JailCell_HasObjects", "Empty:" + isEmpty + ", Returns: " + (map_objects && !isEmpty))

        return map_objects && !isEmpty
    endif

    return map_objects && hasSubObjectsCategory 
endFunction

;/
    Retrieves whether the option exists for a particular Cell Door with the parameters specified.

    JMap&           @apJailCellObject: The reference to the jail cell object that owns this cell door.
    RPB_CellDoor    @akCellDoor: The cell door reference.
    string          @asOption: The option to retrieve.
    string          @asOptionCategory: The category of the option.
    string[]?       @asArrOptionsSubCategories: The nested categories within the main category for this option, if there are any.
    int?            @aiSubCategoriesLimitSize: The number of elements to take into account for the sub-categories if the array is bigger than desired.

    returns (bool): Whether the specified option exists for this cell door.
/;
bool function CellDoor_HasOption(int apJailCellObject, RPB_CellDoor akCellDoor, string asOption, string asOptionCategory, string[] asArrOptionsSubCategories = none, int aiSubCategoriesLimitSize = 0) global
    int map_cellDoors           = JMap.getObj(apJailCellObject, "Cell Doors")           ; JFormMap& - The cell doors for this jail cell
    int map_cellDoor            = JFormMap.getObj(map_cellDoors, akCellDoor)            ; JMap&
    int map_optionCategory      = JMap.getObj(map_cellDoor, asOptionCategory)           ; JMap& - (e.g: Lock)
    int map_optionSubCategory   = map_optionCategory ; The same category to start off, assign another if it has children
    int map_finalOptionObject   = map_optionCategory

    ; Invalid category, doesn't exist
    if (JValue.empty(map_optionCategory))
        return false
    endif

    ; There are sub-categories to this option
    if (asArrOptionsSubCategories.Length > 0)
        int desiredArraySize = int_if (aiSubCategoriesLimitSize > 0, Min(aiSubCategoriesLimitSize, asArrOptionsSubCategories.Length) as int, asArrOptionsSubCategories.Length)

        int i = 0
        while (i < desiredArraySize)
            string currentStoredCategory = asArrOptionsSubCategories[i]
            if (currentStoredCategory)
                map_optionSubCategory = JMap.getObj(map_optionSubCategory, currentStoredCategory) ; (e.g: Decay Options for 1st iteration, Decay Thresholds for 2nd)
            endif
            i += 1
        endWhile

        map_finalOptionObject = map_optionSubCategory

        ; Invalid category, doesn't exist
        if (JValue.empty(map_finalOptionObject))
            return false
        endif
    endif

    return JMap.hasKey(map_finalOptionObject, asOption)
endFunction

;/
    Retrieves the options base object for a particular Cell Door with the parameters specified.

    JMap&           @apJailCellObject: The reference to the jail cell object that owns this cell door.
    RPB_CellDoor    @akCellDoor: The cell door reference.
    string          @asOptionCategory: The category of the option.
    string[]?       @asArrOptionsSubCategories: The nested categories within the main category for this option, if there are any.
    int?            @aiSubCategoriesLimitSize: The number of elements to take into account for the sub-categories if the array is bigger than desired.

    returns (JMap&): The object specified through the parameters for this cell door.
/;
int function CellDoor_GetOptionBaseObject(int apJailCellObject, RPB_CellDoor akCellDoor, string asOptionCategory, string[] asArrOptionsSubCategories = none, int aiSubCategoriesLimitSize = 0) global
    int map_cellDoors           = JMap.getObj(apJailCellObject, "Cell Doors")           ; JFormMap& - The cell doors for this jail cell
    int map_cellDoor            = JFormMap.getObj(map_cellDoors, akCellDoor)            ; JMap&
    int map_optionCategory      = JMap.getObj(map_cellDoor, asOptionCategory)           ; JMap& - (e.g: Lock)
    int map_optionSubCategory   = map_optionCategory ; The same category to start off, assign another if it has children
    int map_finalOptionObject   = map_optionCategory

    ; There are sub-categories to this option
    if (asArrOptionsSubCategories.Length > 0)
        int desiredArraySize = int_if (aiSubCategoriesLimitSize > 0, Min(aiSubCategoriesLimitSize, asArrOptionsSubCategories.Length) as int, asArrOptionsSubCategories.Length)

        int i = 0
        while (i < desiredArraySize)
            string currentStoredCategory = asArrOptionsSubCategories[i]
            if (currentStoredCategory)
                map_optionSubCategory = JMap.getObj(map_optionSubCategory, currentStoredCategory) ; (e.g: Decay Options for 1st iteration, Decay Thresholds for 2nd)
            endif
            i += 1
        endWhile

        map_finalOptionObject = map_optionSubCategory
    endif

    ; Debug(none, "Data::CellDoor_GetOptionBaseObject", "Cell Doors: " + GetContainerList(map_cellDoors))
    ; Debug(none, "Data::CellDoor_GetOptionBaseObject", "Cell Door: " + GetContainerList(map_cellDoor))
    ; Debug(none, "Data::CellDoor_GetOptionBaseObject", "Option Category: " + GetContainerList(map_optionCategory))
    ; Debug(none, "Data::CellDoor_GetOptionBaseObject", "Option Sub Category: " + GetContainerList(map_optionSubCategory))
    ; Debug(none, "Data::CellDoor_GetOptionBaseObject", "Option Final Object: " + GetContainerList(map_finalOptionObject))

    return map_finalOptionObject
endFunction

;/
    Retrieves an option of type bool from a Cell Door.

    JMap&           @apJailCellObject: The reference to the jail cell object that owns this cell door.
    RPB_CellDoor    @akCellDoor: The cell door reference.
    string          @asOption: The option to retrieve.
    string          @asOptionCategory: The category of the option.
    string[]?       @asArrOptionsSubCategories: The nested categories within the main category for this option, if there are any.
    int?            @aiSubCategoriesLimitSize: The number of elements to take into account for the sub-categories if the array is bigger than desired.

    returns (bool): The specified option of type bool for this cell door.
/;
bool function CellDoor_GetOptionOfTypeBool(int apJailCellObject, RPB_CellDoor akCellDoor, string asOption, string asOptionCategory, string[] asArrOptionsSubCategories = none, int aiSubCategoriesLimitSize = 0) global
    int optionBaseObject = CellDoor_GetOptionBaseObject(apJailCellObject, akCellDoor, asOptionCategory, asArrOptionsSubCategories, aiSubCategoriesLimitSize)
    return JMap.getInt(optionBaseObject, asOption) as bool
endFunction

;/
    Retrieves an option of type int from a Cell Door.

    JMap&           @apJailCellObject: The reference to the jail cell object that owns this cell door.
    RPB_CellDoor    @akCellDoor: The cell door reference.
    string          @asOption: The option to retrieve.
    string          @asOptionCategory: The category of the option.
    string[]?       @asArrOptionsSubCategories: The nested categories within the main category for this option, if there are any.
    int?            @aiSubCategoriesLimitSize: The number of elements to take into account for the sub-categories if the array is bigger than desired.

    returns (int): The specified option of type int for this cell door.
/;
int function CellDoor_GetOptionOfTypeInt(int apJailCellObject, RPB_CellDoor akCellDoor, string asOption, string asOptionCategory, string[] asArrOptionsSubCategories = none, int aiSubCategoriesLimitSize = 0) global
    int optionBaseObject = CellDoor_GetOptionBaseObject(apJailCellObject, akCellDoor, asOptionCategory, asArrOptionsSubCategories, aiSubCategoriesLimitSize)
    return JMap.getInt(optionBaseObject, asOption)
endFunction

;/
    Retrieves an option of type float from a Cell Door.

    JMap&           @apJailCellObject: The reference to the jail cell object that owns this cell door.
    RPB_CellDoor    @akCellDoor: The cell door reference.
    string          @asOption: The option to retrieve.
    string          @asOptionCategory: The category of the option.
    string[]?       @asArrOptionsSubCategories: The nested categories within the main category for this option, if there are any.
    int?            @aiSubCategoriesLimitSize: The number of elements to take into account for the sub-categories if the array is bigger than desired.

    returns (float): The specified option of type float for this cell door.
/;
float function CellDoor_GetOptionOfTypeFloat(int apJailCellObject, RPB_CellDoor akCellDoor, string asOption, string asOptionCategory, string[] asArrOptionsSubCategories = none, int aiSubCategoriesLimitSize = 0) global
    int optionBaseObject = CellDoor_GetOptionBaseObject(apJailCellObject, akCellDoor, asOptionCategory, asArrOptionsSubCategories, aiSubCategoriesLimitSize)
    return JMap.getFlt(optionBaseObject, asOption)
endFunction

;/
    Retrieves an option of type string from a Cell Door.

    JMap&           @apJailCellObject: The reference to the jail cell object that owns this cell door.
    RPB_CellDoor    @akCellDoor: The cell door reference.
    string          @asOption: The option to retrieve.
    string          @asOptionCategory: The category of the option.
    string[]?       @asArrOptionsSubCategories: The nested categories within the main category for this option, if there are any.
    int?            @aiSubCategoriesLimitSize: The number of elements to take into account for the sub-categories if the array is bigger than desired.

    returns (string): The specified option of type string for this cell door.
/;
string function CellDoor_GetOptionOfTypeString(int apJailCellObject, RPB_CellDoor akCellDoor, string asOption, string asOptionCategory, string[] asArrOptionsSubCategories = none, int aiSubCategoriesLimitSize = 0) global
    int optionBaseObject = CellDoor_GetOptionBaseObject(apJailCellObject, akCellDoor, asOptionCategory, asArrOptionsSubCategories, aiSubCategoriesLimitSize)
    return JMap.getStr(optionBaseObject, asOption)
endFunction

;/
    Retrieves an option of type Form from a Cell Door.

    JMap&           @apJailCellObject: The reference to the jail cell object that owns this cell door.
    RPB_CellDoor    @akCellDoor: The cell door reference.
    string          @asOption: The option to retrieve.
    string          @asOptionCategory: The category of the option.
    string[]?       @asArrOptionsSubCategories: The nested categories within the main category for this option, if there are any.
    int?            @aiSubCategoriesLimitSize: The number of elements to take into account for the sub-categories if the array is bigger than desired.

    returns (Form): The specified option of type Form for this cell door.
/;
Form function CellDoor_GetOptionOfTypeForm(int apJailCellObject, RPB_CellDoor akCellDoor, string asOption, string asOptionCategory, string[] asArrOptionsSubCategories = none, int aiSubCategoriesLimitSize = 0) global
    int optionBaseObject = CellDoor_GetOptionBaseObject(apJailCellObject, akCellDoor, asOptionCategory, asArrOptionsSubCategories, aiSubCategoriesLimitSize)
    return JMap.getForm(optionBaseObject, asOption)
endFunction

;/
    Retrieves an option of type int[] from a Cell Door.

    JMap&           @apJailCellObject: The reference to the jail cell object that owns this cell door.
    RPB_CellDoor    @akCellDoor: The cell door reference.
    string          @asOption: The option to retrieve.
    string          @asOptionCategory: The category of the option.
    string[]?       @asArrOptionsSubCategories: The nested categories within the main category for this option, if there are any.
    int?            @aiSubCategoriesLimitSize: The number of elements to take into account for the sub-categories if the array is bigger than desired.

    returns (int[]): The specified option of type int[] for this cell door.
/;
int[] function CellDoor_GetOptionOfTypeIntArray(int apJailCellObject, RPB_CellDoor akCellDoor, string asOption, string asOptionCategory, string[] asArrOptionsSubCategories = none, int aiSubCategoriesLimitSize = 0) global
    int optionBaseObject    = CellDoor_GetOptionBaseObject(apJailCellObject, akCellDoor, asOptionCategory, asArrOptionsSubCategories, aiSubCategoriesLimitSize)
    int optionContainer     = JMap.getObj(optionBaseObject, asOption) ; any& <JContainer>

    if (JValue.isArray(optionContainer))
        return JArray.asIntArray(optionContainer)

    elseif (JValue.isFormMap(optionContainer))
        return JIntMap.allKeysPArray(optionContainer)
    endif

    return none
endFunction

;/
    Retrieves an option of type float[] from a Cell Door.

    JMap&           @apJailCellObject: The reference to the jail cell object that owns this cell door.
    RPB_CellDoor    @akCellDoor: The cell door reference.
    string          @asOption: The option to retrieve.
    string          @asOptionCategory: The category of the option.
    string[]?       @asArrOptionsSubCategories: The nested categories within the main category for this option, if there are any.
    int?            @aiSubCategoriesLimitSize: The number of elements to take into account for the sub-categories if the array is bigger than desired.

    returns (float[]): The specified option of type float[] for this cell door.
/;
float[] function CellDoor_GetOptionOfTypeFloatArray(int apJailCellObject, RPB_CellDoor akCellDoor, string asOption, string asOptionCategory, string[] asArrOptionsSubCategories = none, int aiSubCategoriesLimitSize = 0) global
    int optionBaseObject    = CellDoor_GetOptionBaseObject(apJailCellObject, akCellDoor, asOptionCategory, asArrOptionsSubCategories, aiSubCategoriesLimitSize)
    int optionContainer     = JMap.getObj(optionBaseObject, asOption) ; any& <JContainer>

    if (JValue.isArray(optionContainer))
        return JArray.asFloatArray(optionContainer)
    endif

    return none
endFunction

;/
    Retrieves an option of type Form[] from a Cell Door.

    JMap&           @apJailCellObject: The reference to the jail cell object that owns this cell door.
    RPB_CellDoor    @akCellDoor: The cell door reference.
    string          @asOption: The option to retrieve.
    string          @asOptionCategory: The category of the option.
    string[]?       @asArrOptionsSubCategories: The nested categories within the main category for this option, if there are any.
    int?            @aiSubCategoriesLimitSize: The number of elements to take into account for the sub-categories if the array is bigger than desired.

    returns (Form[]): The specified option of type Form[] for this cell door.
/;
Form[] function CellDoor_GetOptionOfTypeFormArray(int apJailCellObject, RPB_CellDoor akCellDoor, string asOption, string asOptionCategory, string[] asArrOptionsSubCategories = none, int aiSubCategoriesLimitSize = 0) global
    int optionBaseObject    = CellDoor_GetOptionBaseObject(apJailCellObject, akCellDoor, asOptionCategory, asArrOptionsSubCategories, aiSubCategoriesLimitSize)
    int optionContainer     = JMap.getObj(optionBaseObject, asOption) ; any& <JContainer>

    if (JValue.isArray(optionContainer))
        return JArray.asFormArray(optionContainer)

    elseif (JValue.isFormMap(optionContainer))
        return JFormMap.allKeysPArray(optionContainer)
    endif

    return none
endFunction

;/
    Retrieves an option of type string[] from a Cell Door.

    JMap&           @apJailCellObject: The reference to the jail cell object that owns this cell door.
    RPB_CellDoor    @akCellDoor: The cell door reference.
    string          @asOption: The option to retrieve.
    string          @asOptionCategory: The category of the option.
    string[]?       @asArrOptionsSubCategories: The nested categories within the main category for this option, if there are any.
    int?            @aiSubCategoriesLimitSize: The number of elements to take into account for the sub-categories if the array is bigger than desired.

    returns (string[]): The specified option of type string[] for this cell door.
/;
string[] function CellDoor_GetOptionOfTypeStringArray(int apJailCellObject, RPB_CellDoor akCellDoor, string asOption, string asOptionCategory, string[] asArrOptionsSubCategories = none, int aiSubCategoriesLimitSize = 0) global
    int optionBaseObject    = CellDoor_GetOptionBaseObject(apJailCellObject, akCellDoor, asOptionCategory, asArrOptionsSubCategories, aiSubCategoriesLimitSize)
    int optionContainer     = JMap.getObj(optionBaseObject, asOption) ; any& <JContainer>

    if (JValue.isArray(optionContainer))
        return JArray.asStringArray(optionContainer)

    elseif (JValue.isFormMap(optionContainer))
        return JMap.allKeysPArray(optionContainer)
    endif

    return none
endFunction

;/
    Retrieves the hold's jail release markers, whether they're Teleport or Escort markers depends on @asTeleportOrEscort.

    JMap&   @apHoldJailObject: The reference to the jail object.
    string  @asTeleportOrEscort: Whether to retrieve Teleport or Escort markers.

    returns (Form[]): The jail release markers with the parameters specified.
/;
Form[] function Jail_GetReleaseMarkers(int apHoldJailObject, string asTeleportOrEscort) global
    if (asTeleportOrEscort != "Teleport" && asTeleportOrEscort != "Escort")
        return none
    endif

    int map_release             = JMap.getObj(apHoldJailObject, "Release")      ; JMap&
    int array_releaseMarkers    = JMap.getObj(map_release, asTeleportOrEscort)  ; JArray& (Form[]) - Either Teleport or Escort, retrieve array accordingly

    return JArray.asFormArray(array_releaseMarkers)
endFunction

;/
    Retrieves the prisoner containers from the hold's jail through the jail item.

    int     @apHoldJailObject: The reference to the jail item of the hold.
    string  @asPrisonerContainerType: The type of prisoner container to get, options are: Belongings, Evidence.

    returns (Form[]): The prisoner containers of the specified type for this jail.
/;
Form[] function Jail_GetPrisonerContainers(int apHoldJailObject, string asPrisonerContainerType = "Belongings") global
    if (asPrisonerContainerType != "Belongings" && asPrisonerContainerType != "Evidence")
        return none
    endif

    int map_prisonerContainers          = JMap.getObj(apHoldJailObject, "Prisoner Containers")          ; JMap&
    int array_prisonerContainersOfType  = JMap.getObj(map_prisonerContainers, asPrisonerContainerType)  ; JArray&

    ; Debug(none, "Data::Jail_GetPrisonerContainers", "map_prisonerContainers: " + GetContainerList(map_prisonerContainers) + ", array_prisonerContainersOfType: " + GetContainerList(array_prisonerContainersOfType))


    return JArray.asFormArray(array_prisonerContainersOfType)
endFunction
; Form[] function Jail_GetPrisonerContainers(int apHoldJailObject) global
;     int array_prisonerContainers  = JMap.getObj(apHoldJailObject, "Prisoner Containers") ; JArray&
;     return JArray.asFormArray(array_prisonerContainers)
; endFunction


string[] function Jail_GetScenes(int apHoldJailObject)

endFunction

int function Jail_GetSceneProbability(int apHoldJailObject, string asSceneName)
    
endFunction


; ==========================================================
;                         Data Setters
; ==========================================================

bool function RemoveJailGuard(int apHoldJailObject, Form akGuard) global
    int guardsArray = JMap.getObj(apHoldJailObject, "Guards") ; JArray&
    bool hasElement = JArray.findForm(guardsArray, akGuard) != -1

    if (!hasElement)
        ; No element found, don't remove anything
        return false
    endif

    JArray.eraseForm(guardsArray, akGuard)

    return true
endFunction

bool function AddJailGuard(int apHoldJailObject, Form akGuard) global
    int guardsArray = JMap.getObj(apHoldJailObject, "Guards") ; JArray&
    bool hasElement = JArray.findForm(guardsArray, akGuard) != -1

    if (hasElement)
        ; Guard already exists, don't add anything
        return false
    endif

    JArray.addForm(guardsArray, akGuard)

    return true
endFunction

bool function ReplaceJailGuard(int apHoldJailObject, Form akOldGuard, Form akNewGuard) global
    if (RemoveJailGuard(apHoldJailObject, akOldGuard))
        return AddJailGuard(apHoldJailObject, akNewGuard)
    endif

    return false
endFunction

bool function AddHoldLocation(Form akLocation, int apHoldRootObject) global
    int locationsArray = JMap.getObj(apHoldRootObject, "Locations")
    JArray.addForm(locationsArray, akLocation)

    return JArray.findForm(locationsArray, akLocation)
endFunction

bool function AddJailCellMarker(Form akMarker, int apHoldJailObject, string asInteriorOrExterior, bool abSaveData = true) global
    if (asInteriorOrExterior != "Interior" && asInteriorOrExterior != "Exterior")
        return none
    endif

    int cellsMap    = JMap.getObj(apHoldJailObject, "Cells") ; Map with both Exterior and Interior markers
    int cellTypeMap = JMap.getObj(cellsMap, asInteriorOrExterior) ; The map holding all of the jail cell arrays, key is the parent FormID and the value is an array containing all of the markers belonging to said parent

    akMarker = Game.GetForm(0x3C9FE) ; temporary, to test

    int markerId        = akMarker.GetFormID() ; The jail cell identifier
    int markersArray    = JMap.getObj(cellTypeMap, markerId) ; The array holding all of the jail cells belonging to parent (format is CellID: []) where [] = markersArray

    ; Create array if it doesn't exist yet
    if (!markersArray)
        markersArray = JArray.object()
    endif

    bool itemExists = JArray.findForm(markersArray, akMarker) != -1

    if (!itemExists)
        ; Add the actual form to the array that contains all forms belonging to this parent
        JArray.addForm(markersArray, akMarker)
    endif

    JMap.setObj(cellTypeMap, markerId, markersArray) ; Add the marker to the jail cell's marker array

    string debugInfo = GetContainerList(cellsMap)
    Debug(none, "Config::AddJailCellMarker", debugInfo)

    ; self.AddJailCellToParent(markersArray, Game.GetForm(0x14))
    int parentArray = RawObject_GetJailCellParent(apHoldJailObject, akMarker as RPB_JailCell) ; To be tested after the refactor to JFormMap
    AddJailCellToParent(parentArray, Game.GetForm(0x14))

    if (abSaveData)
        RPB_Data.SaveRoot()
    endif

    return JArray.findForm(markersArray, akMarker) != -1
endFunction

bool function AddJailCellToParent(int apJailCellParentItem, Form akJailCellMarker) global ; Might not be working after the refactor
    ; apJailCellParentItem = The identifier of the jail cell, for example, for Interior markers: Haafingar.Interior.0x3880 (Array)

    bool itemExists = JArray.findForm(apJailCellParentItem, akJailCellMarker) != -1

    if (!itemExists && JValue.isArray(apJailCellParentItem))
        JArray.addForm(apJailCellParentItem, akJailCellMarker)
    endif
endFunction

bool function AddJailPrisonerContainer(Form akPrisonerContainer, int apHoldJailObject)
    int prisonerContainersArray = JMap.getObj(apHoldJailObject, "Prisoner Containers")
    JArray.addForm(prisonerContainersArray, akPrisonerContainer)

    return JArray.findForm(prisonerContainersArray, akPrisonerContainer)
endFunction

bool function Hold_SetCity(int apHoldRootObject, string asCity)
    JMap.setStr(apHoldRootObject, "City", asCity)
endFunction

bool function Hold_SetCrimeFaction(int apHoldRootObject, Faction akCrimeFaction)
    JMap.setForm(apHoldRootObject, "Crime Faction", akCrimeFaction)
endFunction


; ==========================================================
;                           private
; ==========================================================

;   JArray& (RPB_JailCell[]) @apCellKeysArray: The array containing every parent jail cell key 
Form[] function private_JailCell_GetActiveParents(int apPrisonCellsObject, int apCellKeysArray) global
    int array_allCellObjects = JFormMap.allValues(apPrisonCellsObject) ; JArray& (JMap[])

    int activeCells = JArray.object()
    ; Debug(none, "Data::JailCell_GetActiveParents","Values: " + GetContainerList(array_allCellObjects))

    int i = 0
    while (i < JValue.count(array_allCellObjects))
        int currentJailCellObj = JArray.getObj(array_allCellObjects, i) ; JMap&
        bool isActiveCell      = JMap.getInt(currentJailCellObj, "Active") as bool

        if (isActiveCell)
            Form currentJailCellForm = JArray.getForm(apCellKeysArray, i)
            JArray.addForm(activeCells, currentJailCellForm)
        endif
        i += 1
    endWhile

    if (JValue.count(activeCells) <= 0)
        return none
    endif

    Form[] asFormArray  = JArray.asFormArray(activeCells)
    return asFormArray
endFunction


; ==========================================================
;                           Unused
; ==========================================================

;/
    Retrieves the Hold's jail parent markers for the cells, whether Interior or Exterior depending on the param through the jail item.

    int     @apHoldJailObject: The reference to the jail item of the Hold.
    string  @asInteriorOrExterior: Whether to retrieve Interior or Exterior markers.
/;
Form[] function GetJailCellParentMarkers(int apHoldJailObject, string asInteriorOrExterior = "Interior") global
    if (asInteriorOrExterior != "Interior" && asInteriorOrExterior != "Exterior")
        return none
    endif

    int cellsMap    = JMap.getObj(apHoldJailObject, "Cells")
    int cellArrays  = JMap.getObj(cellsMap, asInteriorOrExterior) ; Since asInteriorOrExterior will now either be Interior or Exterior

    ; int testFormMap = JFormMap.object()
    ; int testArray = JArray.object()
    ; int testArray2 = JArray.object()
    ; int secondArray = JArray.object()
    ; int interiorMap = JMap.object()

    ; JArray.addForm(testArray, Game.GetFormEx(0x36897))
    ; JArray.addForm(testArray, GetFormFromMod(0x3879))

    ; JArray.addForm(testArray2, GetFormFromMod(0x3879))
    ; JArray.addForm(testArray2, GetFormFromMod(0x3880))

    ; JFormMap.setObj(testFormMap, Game.GetFormEx(0x36897), testArray)
    ; JFormMap.setObj(testFormMap, GetFormFromMod(0x3879), testArray2)

    ; JMap.setObj(interiorMap, "Interior", testFormMap)

    ; JValue.writeToFile(interiorMap, "Data/RPB_Data/test_structure2.json")

    ; Debug(none, "Config::GetJailCellParentMarkers", "Test Form Map: " + GetContainerList(testFormMap))

    ; SaveRoot()

    ; int parentCells = JArray.object()

    ; Debug(none, "Config::GetJailCellParentMarkers", "Cell Arrays: " + GetContainerList(cellArrays))

    ; int i = 0
    ; while (i < JValue.count(cellArrays))
    ;     string cellArrayMapKey  = JMap.getNthKey(cellArrays, i)
    ;     int currentCellArray    = JMap.getObj(cellArrays, cellArrayMapKey) ; Array
    ;     Form parentCell         = JArray.getForm(currentCellArray, 0) ; Always get the 1st element, we only want the parents of each one
    ;     bool isCellValid        = (parentCell as RPB_JailCell) != none ; parent must have RPB_JailCell script attached

    ;     if (isCellValid)
    ;         JArray.addForm(parentCells, parentCell)
    ;     endif
        
    ;     i += 1
    ; endWhile


    ; int i = 0
    ; while (i < JValue.count(cellArrays))
    ;     Form parentCell  = JFormMap.getNthKey(cellArrays, i)
    ;     bool isCellValid = (parentCell as RPB_JailCell) != none ; parent must have RPB_JailCell script attached

    ;     if (isCellValid)
    ;         JArray.addForm(parentCells, parentCell)
    ;     endif
        
    ;     i += 1
    ; endWhile

    Form[] parentCells = JFormMap.allKeysPArray(cellArrays)

    Debug(none, "Config::GetJailCellParentMarkers", "Parent Cells: " + parentCells)

    return parentCells
endFunction

;/
    Retrieves the Hold's jail child markers for the cells, whether Interior or Exterior depending on the param through the jail item.

    int     @apHoldJailObject: The reference to the jail item of the Hold.
    string  @asInteriorOrExterior: Whether to retrieve Interior or Exterior markers.
/;
Form[] function GetJailCellChildMarkers(int apHoldJailObject, Form akParentForm, string asInteriorOrExterior = "Interior") global
    if (asInteriorOrExterior != "Interior" && asInteriorOrExterior != "Exterior")
        return none
    endif

    int cellsMap = JMap.getObj(apHoldJailObject, "Cells")
    int cellArrays  = JMap.getObj(cellsMap, asInteriorOrExterior)
    int selectedCellArray = JFormMap.getObj(cellArrays, akParentForm)

    int children = selectedCellArray

    Debug(none, "Config::GetJailCellChildMarkers", akParentForm + "'s " + asInteriorOrExterior +" Children: " + GetContainerList(children))

    Form[] childrenAsForms = JArray.asFormArray(children)

    return childrenAsForms


    ; ; Debug(none, "Config::GetJailCellChildMarkers", "cellArrays " + GetContainerList(cellArrays))
    ; Debug(none, "Config::GetJailCellChildMarkers", "selectedCellArray " + GetContainerList(selectedCellArray))

    ; int childCells = JArray.object()

    ; int i = 0 
    ; while (i < JValue.count(selectedCellArray))
    ;     Form currentChildCell = JArray.getForm(selectedCellArray, i)

    ;     if ((currentChildCell.GetFormID() != aiParentFormID) && (currentChildCell != none))
    ;         JArray.addForm(childCells, currentChildCell)
    ;     endif

    ;     ; if (currentChildCell != none)
    ;     ;     JArray.addForm(childCells, currentChildCell)
    ;     ; endif

    ;     i += 1
    ; endWhile

    ; Debug(none, "Config::GetJailCellChildMarkers", "Cell Arrays: " + GetContainerList(childCells))

    ; return JArray.asFormArray(childCells)
endFunction

; bool function AddJailCellMarker(Form akMarker, int apHoldJailObject, string asInteriorOrExterior)
;     if (asInteriorOrExterior != "Interior" && asInteriorOrExterior != "Exterior")
;         return none
;     endif

;     int rootItem = self.GetRootItem()

;     string hold = JMap.getNthKey(apHoldJailObject, 0)

;     int cellsMap    = JMap.getObj(apHoldJailObject, "Cells")
;     int cellTypeMap = JMap.getObj(cellsMap, asInteriorOrExterior)

;     akMarker = Game.GetForm(0x3C9FE)

;     int markerId        = akMarker.GetFormID() ; The jail cell identifier
;     int markersArray    = JMap.getObj(cellTypeMap, markerId) ; The map holding all of the jail cells (format is CellID: []) since arrays are stored here for each key

;     int newMarkersArray = JArray.object()
;     JArray.addForm(newMarkersArray, akMarker)

;     JArray.addForm(cellTypeMap, akMarker)
;     JMap.setObj(cellTypeMap, markerId, newMarkersArray) ; Add the marker to the jail cell's marker array

;     string debugInfo = GetContainerList(cellsMap)
;     Debug(none, "Config::AddJailCellMarker", debugInfo)
;     Debug(none, "Config::AddJailCellMarker", "Hold: " + hold)

;     JDB.solveObjSetter(".rpb_root.Haafingar.Jail.Cells.Interior", cellTypeMap)

;     self.Serialize(rjson")

;     ; return true
;     return JArray.findForm(markersArray, akMarker) != -1
; endFunction

function testSerializeAll() global
    ; miscVars.SetForm("Jail::Release::Teleport[Haafingar]", Game.GetFormEx(0x3EF19))
    ; miscVars.AddFormToArray("Locations[Eastmarch]", Game.GetForm(0x00018A57))
    ; miscVars.AddFormToArray("Locations[Eastmarch]", Game.GetForm(0x0001676A))

    ; int cellsMapFile = RPB_Data.Unserialize("RPB_Cells.json")
    int cellsMapFile = RPB_Data.Unserialize()
    int eastmarchArray = JMap.getObj(cellsMapFile, "Eastmarch") ; JArray (Form[])

    int locationsMap = JMap.object()
    int locationsArray = JArray.object()

    int crimeFactionMap = JMap.object()

    int jailMap = JMap.object()
    int jailArray = JArray.object()

    int cellsMap = JMap.object()
    int cellsArray = JArray.object()

    int releaseMarkersMap = JMap.object()
    int releaseMarkersArray = JArray.object()

    int prisonerContainerMap = JMap.object()
    int prisonerContainerArray = JArray.object()

    ; Jail
    cellsArray = JValue.deepCopy(eastmarchArray)
    JMap.setObj(cellsMap, "Cells", cellsArray)

    JArray.addForm(releaseMarkersArray, Game.GetFormEx(0x3EF19))
    JMap.setObj(releaseMarkersMap, "Release", releaseMarkersArray)

    JArray.addForm(prisonerContainerArray, Game.GetFormEx(0x3EF19))
    JMap.setObj(prisonerContainerMap, "PrisonerContainers", prisonerContainerArray)

    JArray.addObj(jailArray, cellsMap)
    JArray.addObj(jailArray, releaseMarkersMap)
    JArray.addObj(jailArray, prisonerContainerMap)
    ; End Jail

    JArray.addForm(locationsArray, Game.GetForm(0x00018A57))
    JArray.addForm(locationsArray, Game.GetForm(0x0001676A))

    JMap.setObj(locationsMap, "Locations", locationsArray)
    JMap.setForm(crimeFactionMap, "CrimeFaction", Game.GetForm(0x000267E3))


    JMap.setObj(jailMap, "Jail", jailArray)
    
    JArray.addObj(eastmarchArray, locationsMap)
    JArray.addObj(eastmarchArray, crimeFactionMap)
    JArray.addObj(eastmarchArray, jailMap)
    ; int cityMap = JMap.object()
    ; JMap.setStr(cityMap, "City", "Windhelm")
    ; JArray.addObj(eastmarchArray, cityMap)
    ; RPB_Data.Serialize"RPB_Data.json")
    RPB_Data.Serialize(cellsMapFile)
endFunction

Form[] function GetJailMarkers(string asHold) global
    ; Later the arrays must be dynamic and create one for each hold that exists (easy)
    ; int whiterunCells   = JArray.object()
    ; int windhelmCells   = JArray.object()
    ; int falkreathCells  = JArray.object()
    ; int solitudeCells   = JArray.object()
    ; int morthalCells    = JArray.object()
    ; int riftenCells     = JArray.object()
    ; int dawnstarCells   = JArray.object()

    ; int cellsMap        = JMap.object()

    ; JArray.addForm(whiterunCells, GetFormFromMod(0x3885)) ; Jail Cell 01
    ; JArray.addForm(whiterunCells, GetFormFromMod(0x3886)) ; Jail Cell 02
    ; JArray.addForm(whiterunCells, GetFormFromMod(0x3887)) ; Jail Cell 03
    ; JArray.addForm(whiterunCells, GetFormFromMod(0x3888)) ; Jail Cell 04 (Alik'r Cell)

    ; ; missing Winterhold markers

    ; JArray.addForm(windhelmCells, Game.GetForm(0x58CF8)) ; Jail Cell 01
    ; JArray.addForm(windhelmCells, GetFormFromMod(0x388A)) ; Jail Cell 02
    ; JArray.addForm(windhelmCells, GetFormFromMod(0x388B)) ; Jail Cell 03
    ; JArray.addForm(windhelmCells, GetFormFromMod(0x388C)) ; Jail Cell 04

    ; JArray.addForm(falkreathCells, Game.GetForm(0x3EF07)) ; Jail Cell 01

    ; JArray.addForm(solitudeCells, Game.GetForm(0x36897)) ; Jail Cell 01 (Original)
    ; JArray.addForm(solitudeCells, GetFormFromMod(0x3880)) ; Jail Cell 02
    ; JArray.addForm(solitudeCells, GetFormFromMod(0x3879)) ; Jail Cell 03
    ; JArray.addForm(solitudeCells, GetFormFromMod(0x3881)) ; Jail Cell 04
    ; JArray.addForm(solitudeCells, GetFormFromMod(0x3882)) ; Jail Cell 05
    ; JArray.addForm(solitudeCells, GetFormFromMod(0x3883)) ; Jail Cell 06
    ; JArray.addForm(solitudeCells, GetFormFromMod(0x3884)) ; Jail Cell 07 (Bjartur Cell)

    ; JArray.addForm(morthalCells, Game.GetForm(0x3EF08)) ; Jail Cell 01

    ; ; missing The Reach markers (Markarth)

    ; JArray.addForm(riftenCells, Game.GetForm(0x6128D)) ; Jail Cell 01 (Original)
    ; JArray.addForm(riftenCells, GetFormFromMod(0x388D)) ; Jail Cell 02 (Threki the Innocent)
    ; JArray.addForm(riftenCells, GetFormFromMod(0x388E)) ; Jail Cell 03
    ; JArray.addForm(riftenCells, GetFormFromMod(0x388F)) ; Jail Cell 04 (Sibbi's Cell [RESERVED])
    ; JArray.addForm(riftenCells, GetFormFromMod(0x3890)) ; Jail Cell 05
    ; JArray.addForm(riftenCells, GetFormFromMod(0x3893)) ; Jail Cell 06
    ; JArray.addForm(riftenCells, GetFormFromMod(0x3894)) ; Jail Cell 07
    ; JArray.addForm(riftenCells, GetFormFromMod(0x3895)) ; Jail Cell 08

    ; JArray.addForm(dawnstarCells, GetFormFromMod(0x3896)) ; Jail Cell 01

    ; JMap.setObj(cellsMap, "Whiterun", whiterunCells)
    ; JMap.setObj(cellsMap, "Eastmarch", windhelmCells)
    ; JMap.setObj(cellsMap, "Falkreath", falkreathCells)
    ; JMap.setObj(cellsMap, "Haafingar", solitudeCells)
    ; JMap.setObj(cellsMap, "Hjaalmarch", morthalCells)
    ; JMap.setObj(cellsMap, "The Rift", riftenCells)
    ; JMap.setObj(cellsMap, "The Pale", dawnstarCells)

    ; int cellsMapFile = JValue.readFromFile("testcell.json")
    ; int cellsMapFile = RPB_Data.Unserialize("RPB_Cells.json")
    int cellsMapFile = RPB_Data.Unserialize()

    int holdArray = JMap.getObj(cellsMapFile, asHold)
    ; int holdArray = JMap.getObj(cellsMap, asHold)

    
    ; JValue.writeToFile(cellsMapFile, self.ModDataDirectory + "RPB_Cells.json")
    ; RPB_Data.Serialize"RPB_Cells.json")
    RPB_Data.Serialize(cellsMapFile)

    testSerializeAll()

    return JArray.asFormArray(holdArray)

endFunction