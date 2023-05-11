Scriptname RealisticPrisonAndBounty_Util hidden

;/ 
    Logger
/;

string function ModName() global
    return "Realistic Prison and Bounty"
endFunction

function Trace(Form script, string caller, string logInfo, bool condition = true, bool hideCall = false) global
    if (!condition)
        return
    endif

    string scriptInfo = string_if (script as Quest, (script as Quest).GetID())

    if (caller == "" || hideCall)
        ; We didn't pass any function name nor a state scope, let the log be anonymous
        debug.trace("[" + ModName() + "] " +  "TRACE: " + scriptInfo + logInfo)
        return
    endif

    caller += "()"

    string scriptState = script.GetState()
    if (scriptState != "")
        string scopedState = scriptState + "::" + caller

        ; Since the caller was appended to the scoped state, the caller becomes part of the state
        caller = scopedState
    endif
    debug.trace("["+ ModName() +"<"+ scriptInfo +">] " + "TRACE: " + caller + " -> " + logInfo)
endfunction

function Debug(Form script, string caller, string logInfo, bool condition = true, bool hideCall = false) global
    if (!condition)
        return
    endif

    if (caller == "" || hideCall)
        ; We didn't pass any function name nor a state scope, let the log be anonymous
        debug.trace("[" + ModName() + "] " +  "DEBUG: " + logInfo)
        return
    endif

    caller += "()"

    string scriptState = script.GetState()
    if (scriptState != "")
        string scopedState = scriptState + "::" + caller

        ; Since the caller was appended to the scoped state, the caller becomes part of the state
        caller = scopedState
    endif
    debug.trace("["+ ModName() +"] " + "DEBUG: " + caller + " -> " + logInfo)

    ; With caller from a state:     [ModName] INFO: State::OnUpdateGameTime() -> Message
    ; With caller from empty state: [ModName] INFO: OnUpdateGameTime() -> Message
    ; Without caller:               [ModName] INFO: Message
endFunction

function Info(Form script, string caller, string logInfo, bool condition = true, bool hideCall = false) global
    if (condition)
        debug.trace("[" + ModName() + "] " +  "INFO: " + logInfo)
    endif
endfunction

function Warn(Form script, string caller, string logInfo, bool condition = true, bool hideCall = false) global
    if (condition)
        debug.trace("[" + ModName() + "] " +  "WARN: " + logInfo)
    endif
endfunction

function Error(Form script, string caller, string logInfo, bool condition = true, bool hideCall = false) global
    if (condition)
        debug.trace("[" + ModName() + "] " +  "ERROR: " + logInfo)
    endif
endfunction

function Fatal(Form script, string caller, string logInfo, bool condition = true, bool hideCall = false) global
    if (condition)
        debug.trace("[" + ModName() + "] " +  "FATAL: " + logInfo)
    endif
endfunction

function LogProperty(Form script, string prop, string logInfo, int logLevel = 0) global
    string logLvl  = "PROPERTY:"

    if(prop == "")
        ; We didn't pass any function name nor a state scope, let the log be anonymous
        debug.trace("[" + ModName() + "] " +  logLvl + " " + logInfo)
    else
        if(script.GetState() != "")
            ; We are currently in a state, let the caller know
            string scopedState = script.GetState() + "::" + prop

            ; Since the caller was appended to the scoped state, the caller becomes part of the state
            prop = scopedState
        endif
        debug.trace("[" + ModName() + "] " +  logLvl + " " + prop + " -> " + logInfo)
    endif

    ; With property from a state:     [ModName] INFO: State::MyProperty -> Message
    ; With property from empty state: [ModName] INFO: MyProperty -> Message
    ; Without property:               [ModName] INFO: Message
endFunction

function LogPropertyNull(Form script, string prop, int logLevel = 1) global
    LogProperty(script, prop, "Property is null!", logLevel)
endfunction

function LogPropertyNullIf(Form script, string prop, bool condition, int logLevel = 1) global
    if(condition)
        LogProperty(script, prop, "Property is null!", logLevel)
    endif
endfunction

function LogPropertyIf(Form script, string prop, string logInfo, bool condition, int logLevel = 0) global
    if(condition)
        LogProperty(script, prop, logInfo, logLevel)
    endif
endfunction

; //////////////////////////

;/
    Gets whether or not aiChance is in the specified range

    @aiValue: the value to check
    @aiMin: the minimum starting point
    @aiMax: the range specified

    returns true if aiValue is in the range
    returns false if it's not
/;
bool function IsWithin(int aiValue, int aiMin, int aiMax, bool abMinInclusive = true, bool abMaxInclusive = true) global
    return bool_if(abMinInclusive && abMaxInclusive, (aiValue >= aiMin && aiValue <= aiMax), \
            bool_if(abMinInclusive, (aiValue >= aiMin && aiValue < aiMax), \
            bool_if(abMaxInclusive, (aiValue > aiMin && aiValue <= aiMax))) \
    )
    ;return (aiChance >= aiMin && aiChance <= aiMax)
endfunction

float function Max(float a, float b) global
    if (a > b)
        return a
    else
        return b
    endif
endFunction

;/
    Caps the value of a variable

    @aiValue: the value to cap
    @aiCapTo: the value it should be capped to
    @abCondition: what must be met to have it capped

    returns @aiCapTo if @aiValue met the condition
    returns @aiValue if it did not meet the condition
/;
; int function CapValueIf(int aiValue, int aiCapTo, bool abCondition) global
;     if(abCondition)
;         aiValue = aiCapTo
;     endif
;     return aiValue
; endfunction
int function CapValueIf(int aiValue, int aiCapTo, bool abCondition) global
    return int_if(abCondition, aiCapTo, aiValue)
endfunction

int function int_cap(int aiValue, int aiCapTo) global
    return int_if(aiValue > aiCapTo, aiCapTo, aiValue)
endfunction

;/
	Ternary operator-like functions
	objective: float x = condition ? afTrue : afFalse
    usage: float x = float_if(condition, afTrue, afFalse)
    example: float x = float_if(y == 2, 4, 8)

/;
float function float_if(bool condition, float afTrue, float afFalse = 0.0) global
	if(condition)
		return afTrue
	endif
	return afFalse
endfunction

int function int_if(bool condition, int aiTrue, int aiFalse = 0) global
	if(condition)
		return aiTrue
	endif
	return aiFalse
endfunction

bool function bool_if(bool condition, bool abTrue, bool abFalse = false) global
	if(condition)
		return abTrue
	endif
	return abFalse
endfunction

string function string_if(bool condition, string asTrue, string asFalse = "") global
	if(condition)
		return asTrue
	endif
	return asFalse
endfunction

Form function form_if(bool condition, Form akTrue, Form akFalse = none) global
    if(condition)
        return akTrue
    else
        return akFalse
    endif
endfunction


string function __internal_GetMapElement( \
    int map, \
    string paramKey, \
    string includeStringFilter = "", \
    string excludeStringFilter = "", \
    int includeIntegerFilter = -1, \
    int excludeIntegerFilter = -1, \
    Form includeFormFilter = none, \
    Form excludeFormFilter = none, \
    int indentLevel = 1 \
) global

    int mapLength = JMap.count(map)

    if (mapLength == 0)
        return ""
    endif

    bool paramValueBool = JMap.getInt(map, paramKey) as bool
    int paramValueInt = JMap.getInt(map, paramKey)
    float paramValueFlt = JMap.getFlt(map, paramKey)
    string paramValueStr = JMap.getStr(map, paramKey)
    int paramValueObj = JMap.getObj(map, paramKey)
    Form paramValueForm = JMap.getForm(map, paramKey)

    bool isBoolValue = paramValueBool == false || paramValueBool == true
    bool isIntValue = paramValueInt != 0
    bool isFloatValue = paramValueFlt != 0
    bool isStringValue = paramValueStr != ""
    bool isFormValue = paramValueForm != none
    bool isObjValue = paramValueObj != 0

    if (isStringValue)
        string paramValue = paramValueStr
        return paramKey + ": " + paramValue

    elseif (isIntValue)
        int paramValue = paramValueInt
        return paramKey + ": " + paramValue

    elseif (isFloatValue)
        float paramValue = paramValueFlt
        return paramKey + ": " + paramValue

    elseif (isObjValue)
        int paramValue = paramValueObj
        string objListFunction = GetContainerList( \
            paramValue, \
            includeStringFilter = includeStringFilter, \
            excludeStringFilter = excludeStringFilter, \
            includeIntegerFilter = includeIntegerFilter, \
            excludeIntegerFilter = excludeIntegerFilter, \
            includeFormFilter = includeFormFilter, \
            excludeFormFilter = excludeFormFilter, \
            indentLevel = indentLevel + 1 \
        )
        return paramKey + ": " + objListFunction

    elseif (isFormValue)
        Form paramValue = paramValueForm
        return paramKey + ": " + paramValue

    elseif (isBoolValue)
        bool paramValue = paramValueBool
        return paramKey + ": " + paramValue
    endif

    return ""
endFunction

string function __internal_GetIntegerMapElement( \
    int map, \
    int paramKey, \
    string includeStringFilter = "", \
    string excludeStringFilter = "", \
    int includeIntegerFilter = -1, \
    int excludeIntegerFilter = -1, \
    Form includeFormFilter = none, \
    Form excludeFormFilter = none, \
    int indentLevel = 1 \
) global

    int mapLength = JIntMap.count(map)

    if (mapLength == 0)
        return ""
    endif

    bool paramValueBool = JIntMap.getInt(map, paramKey) as bool
    int paramValueInt = JIntMap.getInt(map, paramKey)
    float paramValueFlt = JIntMap.getFlt(map, paramKey)
    string paramValueStr = JIntMap.getStr(map, paramKey)
    int paramValueObj = JIntMap.getObj(map, paramKey)
    Form paramValueForm = JIntMap.getForm(map, paramKey)

    bool isBoolValue = paramValueBool == false || paramValueBool == true
    bool isIntValue = paramValueInt != 0
    bool isFloatValue = paramValueFlt != 0
    bool isStringValue = paramValueStr != ""
    bool isObjValue = paramValueObj != 0
    bool isFormValue = paramValueForm != none

    if (isStringValue)
        string paramValue = paramValueStr
        return paramKey + ": " + paramValue

    elseif (isIntValue)
        int paramValue = paramValueInt
        return paramKey + ": " + paramValue

    elseif (isFloatValue)
        float paramValue = paramValueFlt
        return paramKey + ": " + paramValue

    elseif (isObjValue)
        int paramValue = paramValueObj
        string objListFunction = GetContainerList( \
            paramValue, \
            includeStringFilter = includeStringFilter, \
            excludeStringFilter = excludeStringFilter, \
            includeIntegerFilter = includeIntegerFilter, \
            excludeIntegerFilter = excludeIntegerFilter, \
            includeFormFilter = includeFormFilter, \
            excludeFormFilter = excludeFormFilter, \
            indentLevel = indentLevel + 1 \
        )
        return paramKey + ": " + objListFunction

    elseif (isFormValue)
        Form paramValue = paramValueForm
        return paramKey + ": " + paramValue

    elseif (isBoolValue)
        bool paramValue = paramValueBool
        return paramKey + ": " + paramValue
    endif

    return ""
endFunction

string function __internal_GetFormMapElement( \
    int map, \
    Form paramKey, \
    string includeStringFilter = "", \
    string excludeStringFilter = "", \
    int includeIntegerFilter = -1, \
    int excludeIntegerFilter = -1, \
    Form includeFormFilter = none, \
    Form excludeFormFilter = none, \
    int indentLevel = 1 \
) global

    int mapLength = JFormMap.count(map)

    if (mapLength == 0)
        return ""
    endif

    bool paramValueBool = JFormMap.getInt(map, paramKey) as bool
    int paramValueInt = JFormMap.getInt(map, paramKey)
    float paramValueFlt = JFormMap.getFlt(map, paramKey)
    string paramValueStr = JFormMap.getStr(map, paramKey)
    int paramValueObj = JFormMap.getObj(map, paramKey)
    Form paramValueForm = JFormMap.getForm(map, paramKey)

    bool isBoolValue = paramValueBool == false || paramValueBool == true
    bool isIntValue = paramValueInt != 0
    bool isFloatValue = paramValueFlt != 0
    bool isStringValue = paramValueStr != ""
    bool isObjValue = paramValueObj != 0
    bool isFormValue = paramValueForm != none

    if (isStringValue)
        string paramValue = paramValueStr
        return paramKey + ": " + paramValue

    elseif (isIntValue)
        int paramValue = paramValueInt
        return paramKey + ": " + paramValue

    elseif (isFloatValue)
        float paramValue = paramValueFlt
        return paramKey + ": " + paramValue

    elseif (isObjValue)
        int paramValue = paramValueObj
        string objListFunction = GetContainerList( \
            paramValue, \
            includeStringFilter = includeStringFilter, \
            excludeStringFilter = excludeStringFilter, \
            includeIntegerFilter = includeIntegerFilter, \
            excludeIntegerFilter = excludeIntegerFilter, \
            includeFormFilter = includeFormFilter, \
            excludeFormFilter = excludeFormFilter, \
            indentLevel = indentLevel + 1 \
        )
        return paramKey + ": " + objListFunction

    elseif (isFormValue)
        Form paramValue = paramValueForm
        return paramKey + ": " + paramValue

    elseif (isBoolValue)
        bool paramValue = paramValueBool
        return paramKey + ": " + paramValue
    endif

    return ""
endFunction

string function __internal_GetArrayElement( \
    int array, \
    int index, \
    string includeStringFilter = "", \
    string excludeStringFilter = "", \
    int includeIntegerFilter = -1, \
    int excludeIntegerFilter = -1, \
    Form includeFormFilter = none, \
    Form excludeFormFilter = none, \
    int indentLevel = 1 \
) global

    int arrayLength = JArray.count(array)

    if (arrayLength == 0)
        return ""
    endif

    bool paramValueBool = JArray.getInt(array, index) as bool
    int paramValueInt = JArray.getInt(array, index)
    float paramValueFlt = JArray.getFlt(array, index)
    string paramValueStr = JArray.getStr(array, index)
    int paramValueObj = JArray.getObj(array, index)
    Form paramValueForm = JArray.getForm(array, index)

    bool isBoolValue = paramValueBool == false || paramValueBool == true
    bool isIntValue = paramValueInt != 0
    bool isFloatValue = paramValueFlt != 0
    bool isStringValue = paramValueStr != ""
    bool isObjValue = paramValueObj != 0
    bool isFormValue = paramValueForm != none

    if (isStringValue)
        string paramValue = paramValueStr
        return index + ": " + paramValue

    elseif (isIntValue)
        int paramValue = paramValueInt
        return index + ": " + paramValue

    elseif (isFloatValue)
        float paramValue = paramValueFlt
        return index + ": " + paramValue

    elseif (isObjValue)
        int paramValue = paramValueObj
        string objListFunction = GetContainerList( \
            paramValue, \
            includeStringFilter = includeStringFilter, \
            excludeStringFilter = excludeStringFilter, \
            includeIntegerFilter = includeIntegerFilter, \
            excludeIntegerFilter = excludeIntegerFilter, \
            includeFormFilter = includeFormFilter, \
            excludeFormFilter = excludeFormFilter, \
            indentLevel = indentLevel + 1 \
        )
        return index + ": " + objListFunction

    elseif (isFormValue)
        Form paramValue = paramValueForm
        return index + ": " + paramValue

    elseif (isBoolValue)
        bool paramValue = paramValueBool
        return index + ": " + paramValue
    endif

    return ""
endFunction

string function __internal_GetIndentLevel(int indentLevel) global
    string output
    if (indentLevel > 1)
        int currentIndentLevel = 0
        while (currentIndentLevel != indentLevel)
            output += "    "
            currentIndentLevel += 1
        endWhile
    endif

    return output
endFunction

string function GetContainerList( \
    int _container, \
    string includeStringFilter = "", \
    string excludeStringFilter = "", \
    int includeIntegerFilter = -1, \
    int excludeIntegerFilter = -1, \
    Form includeFormFilter = none, \
    Form excludeFormFilter = none, \
    int indentLevel = 1 \
) global

    string paramOutput

    int containerLength = JValue.count(_container)
    bool isArray = JValue.isArray(_container)

    if (containerLength == 0)
        return string_if (!isArray, "{}", "[]")
    endif

    int i = 0
    while (i < containerLength)
        ; Add indentation before getting the element
        paramOutput += __internal_GetIndentLevel(indentLevel)
        string elementSpacing = "\n" + string_if(i != containerLength - 1, "\t")
        
        if (JValue.isMap(_container))
            string paramKey = JMap.getNthKey(_container, i)
            bool hasIncludeFilter = includeStringFilter != "" && StringUtil.Find(paramKey, includeStringFilter) != -1
            bool hasExcludeFilter = excludeStringFilter != "" && StringUtil.Find(paramKey, excludeStringFilter) != -1

            if (hasIncludeFilter || includeStringFilter == "")
                paramOutput += __internal_GetMapElement( \
                    _container, \
                    paramKey, \
                    includeStringFilter = includeStringFilter, \
                    excludeStringFilter = excludeStringFilter, \
                    includeIntegerFilter = includeIntegerFilter, \
                    excludeIntegerFilter = excludeIntegerFilter, \
                    includeFormFilter = includeFormFilter, \
                    excludeFormFilter = excludeFormFilter, \
                    indentLevel = indentLevel + 1 \
                ) + elementSpacing
            endif

        elseif (JValue.isIntegerMap(_container))
            int paramKey = JIntMap.getNthKey(_container, i)
            bool hasIncludeFilter = includeIntegerFilter != -1 && paramKey == includeIntegerFilter
            bool hasExcludeFilter = excludeIntegerFilter != -1 && paramKey == excludeIntegerFilter

            if ((hasIncludeFilter && !hasExcludeFilter) || (!hasIncludeFilter && !hasExcludeFilter))
                paramOutput += __internal_GetIntegerMapElement( \
                    _container, \
                    paramKey, \
                    includeStringFilter = includeStringFilter, \
                    excludeStringFilter = excludeStringFilter, \
                    includeIntegerFilter = includeIntegerFilter, \
                    excludeIntegerFilter = excludeIntegerFilter, \
                    includeFormFilter = includeFormFilter, \
                    excludeFormFilter = excludeFormFilter, \
                    indentLevel = indentLevel + 1 \
                ) + elementSpacing
            endif

        elseif (JValue.isFormMap(_container))
            Form paramKey = JFormMap.getNthKey(_container, i)
            bool hasIncludeFilter = includeFormFilter != none && paramKey == includeFormFilter
            bool hasExcludeFilter = excludeFormFilter != none && paramKey == excludeFormFilter

            if ((hasIncludeFilter && !hasExcludeFilter) || (!hasIncludeFilter && !hasExcludeFilter))
                paramOutput += __internal_GetFormMapElement( \
                    _container, \
                    paramKey, \
                    includeStringFilter = includeStringFilter, \
                    excludeStringFilter = excludeStringFilter, \
                    includeIntegerFilter = includeIntegerFilter, \
                    excludeIntegerFilter = excludeIntegerFilter, \
                    includeFormFilter = includeFormFilter, \
                    excludeFormFilter = excludeFormFilter, \
                    indentLevel = indentLevel + 1 \
                ) + elementSpacing
            endif

        elseif (isArray)
            int index = i
            paramOutput += __internal_GetArrayElement( \
                _container, \
                index, \
                includeStringFilter = includeStringFilter, \
                excludeStringFilter = excludeStringFilter, \
                includeIntegerFilter = includeIntegerFilter, \
                excludeIntegerFilter = excludeIntegerFilter, \
                includeFormFilter = includeFormFilter, \
                excludeFormFilter = excludeFormFilter, \
                indentLevel = indentLevel + 1 \
            ) + elementSpacing
        endif

        i += 1
    endWhile

    if (paramOutput == "")
        return string_if (!isArray, "{}", "[]")
    endif

    ; Add indentation after getting the element
    paramOutput += __internal_GetIndentLevel(indentLevel)

    ; EndBenchmark(start, "GetContainerList [Length: "+ containerLength +", indentLevel: "+ indentLevel +"]")
    return string_if (!isArray, "{\n\t" + paramOutput + "}", "[\n\t" + paramOutput + "]")
endFunction

float function ToPercent(float percentToConvertToDecimal) global
    return percentToConvertToDecimal / 100
endFunction

; Converts the passed in percent number to its equivalent decimal percentage to do calculations.
; e.g: 5 becomes 0.05
float function Percent(float percentToConvertToDecimal) global
    if (percentToConvertToDecimal <= 0)
        return 0.0
    endif
    
    return percentToConvertToDecimal / 100
endFunction

;/
    Item Functions
/;

function RemoveKeysFromActor(Actor akActor, ObjectReference akContainer = none) global

endFunction

function RemoveWeaponsFromActor(Actor akActor, ObjectReference akContainer = none) global

endFunction

function WearItem(Actor akActor, Form akItem, int count = 1, bool forced = false, bool silent = true) global
    akActor.AddItem(akItem, aiCount = count, abSilent = silent)
    akActor.EquipItemEx(akItem, equipSlot = 0, preventUnequip = forced, equipSound = false)
endfunction

function UnwearItem(Actor akActor, Form akItem, int count = 1, bool forced = false, bool silent = true) global
    akActor.UnequipItemEx(akItem, equipSlot = 0, preventEquip = forced)
    akActor.RemoveItem(akItem, aiCount = count, abSilent = silent)
endfunction

function WearItemIf(Actor akActor, Form akItem, bool condition, int count = 1, bool forced = false, bool silent = true) global
    if(condition)
        WearItem(akActor, akItem, count, forced, silent)
    endif
endfunction

function UnwearItemIf(Actor akActor, Form akItem, bool condition, int count = 1, bool forced = false, bool silent = true) global
    if(condition)
        UnwearItem(akActor, akItem, count, forced, silent)
    endif
endfunction

bool function ActorHasClothing(Actor akActor) global
    ;/
        TODO: Possibly check for more slotMasks, but for now Body should be fine.
    /;
    return akActor.GetWornForm(GetSlotMask("Body")) != none
endFunction

int function GetSlotMask(string bodyPart) global
    int kSlotMask30 = 0x00000001 ; HEAD
    int kSlotMask31 = 0x00000002 ; Hair
    int kSlotMask32 = 0x00000004 ; BODY
    int kSlotMask33 = 0x00000008 ; Hands
    int kSlotMask34 = 0x00000010 ; Forearms
    int kSlotMask35 = 0x00000020 ; Amulet
    int kSlotMask36 = 0x00000040 ; Ring
    int kSlotMask37 = 0x00000080 ; Feet
    int kSlotMask38 = 0x00000100 ; Calves
    int kSlotMask39 = 0x00000200 ; SHIELD
    int kSlotMask40 = 0x00000400 ; TAIL
    int kSlotMask41 = 0x00000800 ; LongHair
    int kSlotMask42 = 0x00001000 ; Circlet
    int kSlotMask43 = 0x00002000 ; Ears

    if (bodyPart == "Head")
        return kSlotMask30
    elseif (bodyPart == "Hair")
        return kSlotMask31
    elseif (bodyPart == "Body")
        return kSlotMask32
    elseif (bodyPart == "Hands")
        return kSlotMask33
    elseif (bodyPart == "Forearms")
        return kSlotMask34
    elseif (bodyPart == "Amulet")
        return kSlotMask35
    elseif (bodyPart == "Ring")
        return kSlotMask36
    elseif (bodyPart == "Feet")
        return kSlotMask37
    elseif (bodyPart == "Calves")
        return kSlotMask38
    elseif (bodyPart == "Shield")
        return kSlotMask39
    elseif (bodyPart == "Tail")
        return kSlotMask40
    elseif (bodyPart == "LongHair")
        return kSlotMask41
    elseif (bodyPart == "Circlet")
        return kSlotMask42
    elseif (bodyPart == "Ears")
        return kSlotMask43
    endif

endFunction

int function GetSlotMaskValue(int slotMask) global
    ; int slotMaskMap = JIntMap.object()

    int currentSlotMask = 30
    int slotMaskValue = 0x00000001
    while (currentSlotMask <= 61)
        ; JIntMap.setInt(slotMaskMap, currentSlotMask, slotMaskValue)
        if (slotMask == currentSlotMask)
            return slotMaskValue
            ; return JIntMap.getInt(slotMaskMap, slotMask)
        endif
        currentSlotMask += 1
        slotMaskValue *= 2 ; Get next slot mask by doubling the value
    endWhile

    return -1
endFunction

float function UnitsToCentimeters(int unit)
    return unit * 1.428
endFunction

;/
    Temporary function
    Gets the Base Jail Door ID for the specified hold

    SDoorJail01 - 5E91D (Solitude) [Haafingar]
    WRJailDoor01 - A7613 (Whiterun) [Whiterun]
    ImpJailDoor01 - 40BB2 (Windhelm, Riften) [Eastmarch, The Rift]
    FarmhouseJailDoor01 - EC563 (Falkreath, Morthal, Dawnstar) [Falkreath, Hjaalmarch, The Pale]
/;
int function GetJailBaseDoorID(string hold) global
    if (hold == "Haafingar")
        return 0x5E91D

    elseif (hold == "Whiterun")
        return 0xA7613

    elseif (hold == "Windhelm" || hold == "The Rift")
        return 0x40BB2

    elseif (hold == "Falkreath" || hold == "Hjaalmarch" || hold == "The Pale")
        return 0xEC563
    endif
endFunction

ObjectReference function GetNearestJailDoorOfType(int jailBaseDoorId, ObjectReference centerRef, float radius) global
    int i = 10

    Form doorRef = Game.GetFormEx(jailBaseDoorId)
    ObjectReference _cellDoor = Game.FindClosestReferenceOfTypeFromRef(doorRef, centerRef, radius)
    return _cellDoor

    ; while (i > 0)
    ;     ObjectReference _cellDoor = Game.FindClosestReferenceOfTypeFromRef(doorRef.GetBaseObject(), centerRef, radius)
    ;     if (_cellDoor)
    ;         return _cellDoor
    ;     endif

    ;     if (radius < 8000)
    ;         radius *= 2
    ;     endif
    ;     i -= 1
    ; endWhile

    return none
endFunction

ObjectReference function GetRandomJailDoorOfType(int jailBaseDoorId, ObjectReference centerRef, float radius) global
    Form doorRef = Game.GetFormEx(jailBaseDoorId)
    ObjectReference _cellDoor = Game.FindRandomReferenceOfTypeFromRef(doorRef, centerRef, radius)
    return _cellDoor
endFunction

function OpenMultipleDoorsOfType(int jailBaseDoorId, ObjectReference scanFromWhere, float radius) global
    int i = 10

    Form doorRef = Game.GetFormEx(jailBaseDoorId)

    while (i > 0)
        ObjectReference _cellDoor = Game.FindRandomReferenceOfTypeFromRef(doorRef, scanFromWhere, radius)
        bool isOpen = _cellDoor.GetOpenState() == 1 || _cellDoor.GetOpenState() == 2
        if (isOpen)
            OpenMultipleDoorsOfType(jailBaseDoorId, scanFromWhere, radius)
        endif

        if (_cellDoor)
            _cellDoor.SetOpen(true)
        endif

        if (radius < 8000)
            radius *= 2
        endif
        i -= 1
    endWhile
endFunction

Actor function GetNearestActor(ObjectReference centerRef, float radius) global
    int i = 10

    while (i > 0)
        Actor _actor = Game.FindRandomActorFromRef(centerRef, radius)
        if (_actor)
            return _actor
        endif

        if (radius < 8000)
            radius *= 2
        endif
        i -= 1
    endWhile

    return none
endFunction

bool function IsActorNearReference(Actor akActor, ObjectReference akReference, float radius = 80.0) global
    ObjectReference referenceToFind = Game.FindClosestReferenceOfTypeFromRef(akReference.GetBaseObject(), akActor, radius)
    if (referenceToFind)
        return true
    endif

    return false
endFunction

function ClearBounty(Faction akFaction, bool nonViolent = true, bool violent = true) global
    if (nonViolent)
        akFaction.SetCrimeGold(0)
    endif

    if (violent)
        akFaction.SetCrimeGoldViolent(0)
    endif
endFunction

float function StartBenchmark(bool condition = true) global
    if (condition)
        float startTime = Utility.GetCurrentRealTime()
        return startTime
    endif
endFunction

float function EndBenchmark(float startTime, string _message = "", bool condition = true) global
    if (condition)
        float endTime = Utility.GetCurrentRealTime()
        float elapsedTime = endTime - startTime
        debug.trace("[Realistic Prison and Bounty] DEBUG: " + _message + " execution took: " + ((elapsedTime * 1000)) + " ms")
        ; local_log(none, string_if(_message != "", _message + " ", "") + "execution took " + ((elapsedTime * 1000)) + " ms", LOG_DEBUG(), hideCall = true)
        return elapsedTime
    endif
endFunction