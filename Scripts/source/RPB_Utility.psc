scriptname RPB_Utility hidden

import Math
import RPB_Memory

string function ModName() global
    return "Realistic Prison and Bounty"
endFunction

string function PluginName() global
    return "RealisticPrisonAndBounty.esp"
endFunction

Form function GetFormFromMod(int formId) global
    return Game.GetFormFromFile(formId, PluginName())
endFunction

; ==========================================================
;                           Globals
; ==========================================================

GlobalVariable function RPB_ArrestGlobal(string asGlobal) global
    if (asGlobal == "Surrender")
        return GetFormFromMod(0x26A2D) as GlobalVariable

    elseif (asGlobal == "No Dialogue")
        return GetFormFromMod(0x26A2E) as GlobalVariable
    endif

    return none
endFunction

; ==========================================================
;                       Form References
; ==========================================================

Quest function GetCellPackageGroup(string questPackageID) global
    ; return GetFormFromMod(0x1F8CC) as Quest
    string packageID = "RPB_" + questPackageID

    int packages = FastMap("<string>")
    FastMap_SetForm(packages, "RPB_CellPackages_02",        GetFormFromMod(0x21916))
    FastMap_SetForm(packages, "RPB_CellPackages_M_01",      GetFormFromMod(0x27A60))
    FastMap_SetForm(packages, "RPB_CellPackages_L_01",      GetFormFromMod(0x27A61))
    FastMap_SetForm(packages, "RPB_CellPackages_XL_01",     GetFormFromMod(0x27A62))
    FastMap_SetForm(packages, "RPB_CellPackages_XXL_01",    GetFormFromMod(0x27A63))

    if (!FastMap_HasKey(packages, packageID))
        ; Error, package quest does not exist
        return none
    endif

    return FastMap_GetForm(packages, packageID) as Quest
endFunction

RPB_PackageGroup function GetCellPackageGroupEx(string questPackageID) global
    ; return GetFormFromMod(0x1F8CC) as Quest
    string packageID = "RPB_" + questPackageID

    int packages = FastMap("<string>")
    FastMap_SetForm(packages, "RPB_CellPackages_02",        GetFormFromMod(0x21916))
    FastMap_SetForm(packages, "RPB_CellPackages_M_01",      GetFormFromMod(0x27A60))
    FastMap_SetForm(packages, "RPB_CellPackages_L_01",      GetFormFromMod(0x27A61))
    FastMap_SetForm(packages, "RPB_CellPackages_XL_01",     GetFormFromMod(0x27A62))
    FastMap_SetForm(packages, "RPB_CellPackages_XXL_01",    GetFormFromMod(0x27A63))

    if (!FastMap_HasKey(packages, packageID))
        ; Error, package quest does not exist
        return none
    endif

    return FastMap_GetForm(packages, packageID) as RPB_PackageGroup
endFunction

; Quest function GetCellPackageGroup() global
;     ; return GetFormFromMod(0x1F8CC) as Quest
;     return GetFormFromMod(0x21916) as Quest
; endFunction

Message function ServeTimeMessage() global
    return GetFormFromMod(0x1EE08) as Message
endFunction

Spell function RPB_ArresteeSpell() global
    return GetFormFromMod(0x187B3) as Spell
endFunction

Spell function RPB_PrisonerSpell() global
    return GetFormFromMod(0x197D7) as Spell
endFunction

Spell function RPB_CaptorSpell() global
    return GetFormFromMod(0x2293E) as Spell
endFunction

Idle function BoundHandsBehindBack() global
    return Game.GetFormEx(0xB600A) as Idle
endFunction

Armor function RPB_PrisonerHandCuffs() global
    return GetFormFromMod(0x23969) as Armor
endFunction

Outfit function RPB_GetOutfit(string asOutfit) global
    if (asOutfit == "Naked")
        return GetFormFromMod(0x259D4) as Outfit

    elseif (asOutfit == "Default")
        return GetFormFromMod(0x259D5) as Outfit

    elseif (asOutfit == "Default 2")
        return GetFormFromMod(0x259D6) as Outfit

    elseif (asOutfit == "Default no Shoes")
        return GetFormFromMod(0x259D7) as Outfit

    elseif (asOutfit == "Default 2 no Shoes")
        return GetFormFromMod(0x259D8) as Outfit
    endif
endFunction

; ==========================================================
;                        Log Functions
; ==========================================================


bool function IsTracingEnabled() global
    return IsDebuggingEnabled() && RPB_StorageVars.GetBool("TRACE", "Log", true)
endFunction

bool function IsDebuggingEnabled() global
    return RPB_StorageVars.GetBool("DEBUG", "Log", true)
endFunction

bool function IsLoggingEnabled() global
    return RPB_StorageVars.GetBool("LOG", "Log", true)
endFunction

function EnableDebugging() global
    RPB_StorageVars.SetBool("DEBUG", true, "Log")
endFunction

function DisableDebugging() global
    RPB_StorageVars.SetBool("DEBUG", false, "Log")
endFunction

function EnableLogging() global
    RPB_StorageVars.SetBool("LOG", true, "Log")
endFunction

function DisableLogging() global
    RPB_StorageVars.SetBool("LOG", false, "Log")
endFunction

function SetLoggingEnabled(string asLogType, bool abEnabled) global
    RPB_StorageVars.SetBool(asLogType, abEnabled, "Log")
endFunction

function base_log(string asLogType = "DEBUG", string asLogInfo, string asCaller = "", string asCallerArgs = "") global
    if (asCaller)
        debug.trace("["+ ModName() +"] " + asLogType + " " + asCaller + "("+ asCallerArgs +")" + " -> " + asLogInfo)
    else
        debug.trace("["+ ModName() +"] " + asLogType + " " + asLogInfo)
    endif
endFunction

function Trace(string asCaller, string asLogInfo, bool abCondition = true) global
    if (!abCondition || !IsTracingEnabled())
        return
    endif

    base_log("TRACE:", asLogInfo, asCaller)
endFunction

function Debug(string asCaller, string asLogInfo, bool abCondition = true) global
    if (!abCondition || !IsDebuggingEnabled())
        return
    endif

    base_log("DEBUG:", asLogInfo, asCaller)
endFunction

function NotImplemented(string asCaller, bool abCondition = true) global
    if (!abCondition || !IsDebuggingEnabled())
        return
    endif

    base_log("IMPLEMENT:", asCaller + " has not been implemented!", asCaller)
endFunction

function FunctionNotImplemented(string asCaller, bool abCondition = true) global
    if (!abCondition || !IsDebuggingEnabled())
        return
    endif

    base_log("IMPLEMENT:", "Function " + asCaller + "() has not been implemented!", asCaller)
endFunction

function EventNotImplemented(string asCaller, bool abCondition = true) global
    if (!abCondition || !IsDebuggingEnabled())
        return
    endif

    base_log("IMPLEMENT:", "Event " + asCaller + "() has not been implemented!", asCaller)
endFunction

function DebugInfo(string asCaller, string asLogInfo, bool abCondition = true) global
    if (!abCondition || !IsDebuggingEnabled())
        return
    endif

    base_log("INFO:", asLogInfo, asCaller)
endFunction

function DebugWarn(string asCaller, string asLogInfo, bool abCondition = true) global
    if (!abCondition || !IsDebuggingEnabled())
        return
    endif

    base_log("WARN:", asLogInfo, asCaller)
endFunction

function DebugError(string asCaller, string asLogInfo, bool abCondition = true) global
    if (!abCondition || !IsDebuggingEnabled())
        return
    endif

    base_log("ERROR:", asLogInfo, asCaller)
endFunction

function DebugWithArgs(string asCaller, string asArgs, string asLogInfo, bool abCondition = true) global
    if (!abCondition || !IsDebuggingEnabled())
        return
    endif

    base_log("DEBUG:", asLogInfo, asCaller, asArgs)
endFunction

function DebugParams(string params, string paramNames = "", string caller = "", bool condition = true) global
    string[] splitParams    = StringUtil.Split(params, ",")
    string[] splitNames     = StringUtil.Split(paramNames, ", ")

    string msg = "[\n"
    int i = 0
    while (i < splitParams.Length)
        string paramName = string_if (splitNames[i], splitNames[i], i)
        msg += "\t" + paramName + ": " + splitParams[i]

        if (i < splitParams.Length - 1)
            msg += "\n"
        endif

        i += 1
    endWhile
    msg += "\n]"

    Debug(caller, msg, condition)
endFunction

function LogNoType(string asLogInfo, string asCaller = "", bool abCondition = true) global
    if (!abCondition || !IsLoggingEnabled())
        return
    endif

    debug.trace("["+ ModName() +"] " + asLogInfo)
endFunction

function Info(string asLogInfo, bool abCondition = true) global
    if (!abCondition || IsDebuggingEnabled() || !IsLoggingEnabled())
        return
    endif

    base_log("INFO:", asLogInfo)
endFunction

function Warn(string asLogInfo, bool abCondition = true) global
    if (!abCondition || IsDebuggingEnabled() || !IsLoggingEnabled())
        return
    endif

    base_log("WARN:", asLogInfo)
endFunction

function Error(string asLogInfo, bool abCondition = true) global
    if (!abCondition || IsDebuggingEnabled() || !IsLoggingEnabled())
        return
    endif

    base_log("ERROR:", asLogInfo)
endFunction

function Fatal(string asLogInfo, bool abCondition = true) global
    if (!abCondition || IsDebuggingEnabled() || !IsLoggingEnabled())
        return
    endif

    base_log("FATAL:", asLogInfo)
endFunction

function LogProperty(string prop, string asLogInfo, bool condition = true) global
    if (!condition || IsDebuggingEnabled() || !IsLoggingEnabled())
        return
    endif
    
    base_log("PROPERTY:", asLogInfo)
endFunction

function ErrorProperty(string asProperty, string asLogInfo, bool condition = true) global
    if (!condition || IsDebuggingEnabled() || !IsLoggingEnabled())
        return
    endif

    base_log("ERROR (PROPERTY):", asLogInfo)
endFunction

; ==========================================================
;                       Math Functions
; ==========================================================

float function Max(float a, float b) global
    if (a > b)
        return a
    else
        return b
    endif
endFunction

float function Min(float a, float b) global
    if (a < b)
        return a
    else
        return b
    endif
endFunction

int function Round(float value) global
    float fractionalPart = value - math.floor(value)

    if (fractionalPart >= 0.5)
        return math.ceiling(value)
    else
        return math.floor(value)
    endif
endFunction


; Converts the passed in percent number to its equivalent decimal percentage to do calculations.
; e.g: 5 becomes 0.05
float function GetPercentAsDecimal(float percentToConvert) global
    if (percentToConvert <= 0)
        return 0.0
    endif
    
    return percentToConvert / 100
endFunction

; ==========================================================
;                 Ternary-Operator Functions
; ==========================================================

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

ActiveMagicEffect function ame_if (bool condition, ActiveMagicEffect apTrue, ActiveMagicEffect apFalse) global
    if (condition)
        return apTrue
    else
        return apFalse
    endif
endFunction

; ==========================================================
;                      String Functions
; ==========================================================

string function GetFormattedAsParams(string values, string keys = "", string keyPrefixes = "", string keySuffixes = "", string valuePrefixes = "", string valueSuffixes = "") global
    string[] splitValues        = StringUtil.Split(values, ",")
    string[] splitKeys          = StringUtil.Split(keys, ", ")
    string[] splitKeyPrefixes   = StringUtil.Split(keyPrefixes, ", ")
    string[] splitKeySuffixes   = StringUtil.Split(keySuffixes, ", ")
    string[] splitValuePrefixes = StringUtil.Split(valuePrefixes, ", ")
    string[] splitValueSuffixes = StringUtil.Split(valueSuffixes, ", ")

    string msg = "[\n"
    int i = 0
    while (i < splitValues.Length)
        string paramName = string_if (splitKeys[i], splitKeys[i], i)
        string keyPrefix = ""
        string keySuffix = ""
        string valuePrefix = ""
        string valueSuffix = ""

        if (splitKeyPrefixes != none)
            keyPrefix = splitKeyPrefixes[i]
        endif

        if (splitValuePrefixes != none)
            valuePrefix = splitValuePrefixes[i]
        endif

        if (splitKeySuffixes != none)
            keySuffix = splitKeySuffixes[i]
        endif

        if (splitValueSuffixes != none)
            valueSuffix = splitValueSuffixes[i]
        endif

        msg += "\t" + keyPrefix + paramName + keySuffix + ": " + valuePrefix + splitValues[i] + valueSuffix

        if (i < splitValues.Length - 1)
            msg += "\n"
        endif

        i += 1
    endWhile
    msg += "\n]"

    return msg
endFunction

bool function String_StartsWith(string str, string needle) global
    if (StringUtil.GetLength(str) < StringUtil.GetLength(needle))
        return false
    endif

    string substring = StringUtil.Substring(str, 0, StringUtil.GetLength(needle))
    return substring == needle
endFunction

string function String_Implode(string[] akStrArray, string asDelimiter = ",") global
    string result = ""

    int i = 0
    while (i < akStrArray.Length)
        result += akStrArray[i]

        if (i < (akStrArray.Length - 1))
            result += asDelimiter
        endif

        i += 1
    endWhile

    return result
endFunction

string[] function String_Explode(string asStr, string asDelimiter = ",") global
    return StringUtil.Split(asStr, asDelimiter)
endFunction

string function ReplaceString(string str, string toFind, string replacement) global
    int len = StringUtil.GetLength(str)
    string result = ""

    int i = 0
    while (i < len)
        int index = StringUtil.Find(str, toFind, i)
        if (index != -1)
            result += StringUtil.Substring(str, i, index - i)
            result += replacement

            i = index + StringUtil.GetLength(toFind)
        else
            result += StringUtil.Substring(str, i, len - i)
            return result
        endif
    endWhile

    return result
endFunction

; string function ReplaceChar(string str, string toFind, string replacement) global
;     int len = StringUtil.GetLength(str)
;     string result = ""
;     DebugWithArgs("Data::ReplaceChar", "toFind Length: " + StringUtil.GetLength(toFind) + ", replacement Length: " + StringUtil.GetLength(replacement), "")
;     int i = 0
;     while (i < len)
;         string currentChar = StringUtil.GetNthChar(str, i)
;         DebugWithArgs("", "Data::ReplaceChar", "Index: " + i + ", Current Char: " + currentChar + ", ToFind: " + toFind)

;         if (currentChar == toFind)
;             result += replacement
;             DebugWithArgs("Data::ReplaceChar", "str: " + str + ", toFind: " + toFind + ", replacement: " + replacement, "Found "+ currentChar +", appending " + replacement)
;         else
;             result += currentChar
;         endif
;         i += 1
;     endWhile
;     DebugWithArgs("Data::ReplaceChar", "str: " + str + ", toFind: " + toFind + ", replacement: " + replacement, "Returning " + result)

;     return result
; endFunction

string[] function StringArray_Merge(string[] asArrayOne, string[] asArrayTwo) global
    int newStringArray = JArray.object()
    int arrayOneObj = JArray.objectWithStrings(asArrayOne)
    int arrayTwoObj = JArray.objectWithStrings(asArrayTwo)

    JArray.addFromArray(newStringArray, arrayOneObj)
    JArray.addFromArray(newStringArray, arrayTwoObj)

    return JArray.asStringArray(newStringArray)
endFunction

string function Replace(string asTemplate, string[] akPlaceholders, string[] akReplacements) global
    int numberOfPlaceholders = akPlaceholders.Length
    int numberOfReplacements = akReplacements.Length

    if (numberOfPlaceholders != numberOfReplacements)
        return "Error: Number of placeholders does not match the number of replacements!"
    endif

    int startIndex = StringUtil.Find(asTemplate, "{", 0)
    int templateLength = StringUtil.GetLength(asTemplate)

    string result = ""

    int placeholderStartIndex = 0
    int placeholderEndIndex = 0

    bool outerBreak = false
    while (placeholderStartIndex < templateLength && !outerBreak)
        placeholderStartIndex = StringUtil.Find(asTemplate, "{", startIndex)
        if (placeholderStartIndex == -1)
            ; If no more placeholders found, append the remaining part of the template
            result += StringUtil.Substring(asTemplate, startIndex, templateLength - startIndex)
            ; Trace("Utility::Replace", "["+ placeholderStartIndex +"]: " + result)
            outerBreak = true
        else
            ; Append the part of the template before the placeholder
            if (startIndex > 0)
                result += StringUtil.Substring(asTemplate, startIndex, placeholderStartIndex - startIndex)
            endif
            ; result += StringUtil.Substring(asTemplate, startIndex, placeholderStartIndex - startIndex)
            ; Trace("Utility::Replace", "["+ placeholderStartIndex +"]: " + result)

            ; Find the end of the placeholder
            placeholderEndIndex = StringUtil.Find(asTemplate, "}", placeholderStartIndex)
            if (placeholderEndIndex == -1)
                return "Error: Unclosed placeholder."
            endif

            ; Get the placeholder name
            string placeholder = StringUtil.Substring(asTemplate, placeholderStartIndex + 1, placeholderEndIndex - placeholderStartIndex - 1)

            ; Find the index of the placeholder in the array
            int replacementIndex = -1
            int n = 0
            bool innerBreak = false
            while (n < numberOfPlaceholders && !innerBreak)
                if (placeholder == akPlaceholders[n])
                    replacementIndex = n
                    innerBreak = true
                endif
                n += 1
            endWhile

            ; If replacement found, append it; otherwise, append the original placeholder
            if (replacementIndex != -1)
                result += akReplacements[replacementIndex]
            else
                result += "{" + placeholder + "}"
            endif

            ; Move the start index to the character after the end of the placeholder
            startIndex = placeholderEndIndex + 1
        endif
    endWhile

    return result
endFunction

; ==========================================================
;                      Bitwise Functions
; ==========================================================

string function OR(int[] elements) global
    string orBitwiseExpr = ""

    int i = 0
    while (i < elements.Length)
        orBitwiseExpr += elements[i]
        if (i < (elements.Length - 1))
            orBitwiseExpr +=  " | "
        endif
        i += 1
    endWhile

    return orBitwiseExpr
endFunction

string function XOR(int[] elements) global
    string xorBitwiseExpr = ""

    int i = 0
    while (i < elements.Length)
        xorBitwiseExpr += elements[i]
        if (i < (elements.Length - 1))
            xorBitwiseExpr +=  " ^ "
        endif
        i += 1
    endWhile

    return xorBitwiseExpr
endFunction

string function AND(int[] elements) global
    string andBitwiseExpr = ""

    int i = 0
    while (i < elements.Length)
        andBitwiseExpr += elements[i]
        if (i < (elements.Length - 1))
            andBitwiseExpr +=  " & "
        endif
        i += 1
    endWhile

    return andBitwiseExpr
endFunction

; Temporary
int function BitwiseExpr(string bitfield) global
    ; Debug("BitwiseExpr", "["+i+"] " + "Bitfield: " + bitfield)

    int result = 0
    string currentOperator = ""
    string[] tokens = StringUtil.Split(bitfield, " ")

    ; Iterate over tokens to process the bitwise expression
    int i = 0
    while (i < tokens.length)
        string token = tokens[i]

        if (token == "|")
            currentOperator = "OR"
        elseif (token == "&")
            currentOperator = "AND"
        elseif (token == "<<")
            currentOperator = "LSHIFT"
        elseif (token == ">>")
            currentOperator = "RSHIFT"
        else
            bool isHexadecimal  = String_StartsWith(token, "0x")
            bool isBinary       = !isHexadecimal && String_StartsWith(token, "0b")
            bool isDecimal      = !isHexadecimal && !isBinary

            int currentValue = 0

            if (isHexadecimal)
                currentValue = HexStringToInt(token)
 
            elseif (isBinary)
                currentValue = BinStringToInt(token)

            elseif (isDecimal)
                currentValue = token as int
            endif

            ; Debug("BitwiseExpr", "["+i+"] " + currentValue)

            ; Apply the current operator
            if (currentOperator == "")
                result = currentValue
            elseif (currentOperator == "OR")
                result = Math.LogicalOr(result, currentValue)
            elseif (currentOperator == "AND")
                result = Math.LogicalAnd(result, currentValue)
            elseif (currentOperator == "LSHIFT")
                result = Math.LeftShift(result, currentValue)
            elseif (currentOperator == "RSHIFT")
                result = Math.RightShift(result, currentValue)
            endif

            ; Reset current operator after use
            currentOperator = ""
        endif

        i += 1
    endWhile

    return result
endFunction

; ==========================================================
;                        AI Functions
; ==========================================================

function RetainAI(bool condition = true) global
    if (condition)
        Game.SetPlayerAIDriven(true)
        Game.DisablePlayerControls( \
            abMovement = true, \
            abFighting = true, \
            abCamSwitch = false, \
            abLooking = false, \
            abSneaking = true, \
            abMenu = true, \
            abActivate = true, \
            abJournalTabs = false, \
            aiDisablePOVType = 0 \
        )
    endif
endFunction

function ReleaseAI(bool condition = true) global
    if (condition)
        Game.SetPlayerAIDriven(false)
        Game.EnablePlayerControls()
    endif
endFunction

function SetGameStat(string asStatName, int aiValue) global
    int statValue = Game.QueryStat(asStatName)
    Game.IncrementStat(asStatName, (-statValue) + aiValue)
endFunction

; ==========================================================
;                      External Functions
; ==========================================================

bool function IsActorArrested(Actor akActor) global
    return RPB_StorageVars.GetBoolOnForm("Arrested", akActor, "Arrest")
endFunction

bool function IsActorImprisoned(Actor akActor) global
    return RPB_StorageVars.GetBoolOnForm("Imprisoned", akActor, "Jail")
endFunction

bool function IsPlayerArrested() global
    return RPB_StorageVars.GetBoolOnForm("Arrested", Game.GetForm(0x14))
endFunction

bool function IsPlayerImprisoned() global
    return RPB_StorageVars.GetBoolOnForm("Imprisoned", Game.GetForm(0x14))
endFunction

;/
    Retrieves the Hold's Crime Faction through its name

    string  @asHold: The hold's crime faction.

    returns (Faction): The Hold's Crime Faction.
/;
Faction function GetCrimeFactionByHold(string asHold) global
    int holdObject = RPB_Data.GetRootObject(asHold)
    return RPB_Data.Hold_GetCrimeFaction(holdObject)
endFunction

bool function WasPlayerLastJailedInHold(Faction akCrimeFaction) global
    return RPB_StorageVars.HasVarOnForm("Last Jailed - Prison", akCrimeFaction, "PrisonLastJailed")
endFunction

int function GetPlayerPrisonLastJailedTime(string asTimeType, Faction akCrimeFaction) global
    if (asTimeType != "Day" && asTimeType != "Month" && asTimeType != "Year" && asTimeType != "Hour" && asTimeType != "Minute")
        return -1
    endif

    return RPB_StorageVars.GetIntOnForm("Last Jailed - " + asTimeType, akCrimeFaction, "PrisonLastJailed")
endFunction

int function GetPlayerPrisonLastReleasedTime(string asTimeType, Faction akCrimeFaction) global
    if (asTimeType != "Day" && asTimeType != "Month" && asTimeType != "Year" && asTimeType != "Hour" && asTimeType != "Minute")
        return -1
    endif

    return RPB_StorageVars.GetIntOnForm("Last Released - " + asTimeType, akCrimeFaction, "PrisonLastReleased")
endFunction

int function GetPlayerPrisonLastEscapedTime(string asTimeType, Faction akCrimeFaction) global
    if (asTimeType != "Day" && asTimeType != "Month" && asTimeType != "Year" && asTimeType != "Hour" && asTimeType != "Minute")
        return -1
    endif

    return RPB_StorageVars.GetIntOnForm("Last Escaped - " + asTimeType, akCrimeFaction, "PrisonLastEscaped")
endFunction

; ==========================================================
;                       Actor Functions
; ==========================================================

function UnequipHandsForActor(Actor akActor) global
    UnequipWeaponForActor(akActor, false)
    UnequipWeaponForActor(akActor, false)
    UnequipWeaponForActor(akActor, true)
    UnequipSpellForActor(akActor)
    UnequipShieldForActor(akActor)
endFunction

function UnequipWeaponForActor(Actor akActor, bool abLeftHand = false, bool abPreventEquip = false, bool abSilentUnequip = true) global
    Weapon kWeapon = akActor.GetEquippedWeapon(abLeftHand)
    if (kWeapon != None)
        akActor.UnequipItem(kWeapon, abPreventEquip, abSilentUnequip)
    endif
endFunction

function UnequipShieldForActor(Actor akActor, bool abPreventEquip = false, bool abSilentUnequip = true) global
    Armor kShield = akActor.GetEquippedShield()
    if (kShield != None)
        akActor.UnequipItem(kShield, abPreventEquip, abSilentUnequip)
    endif
endFunction

function UnequipSpellForActor(Actor akActor) global
    int leftHand  = 0
    int rightHand = 1

    Spell kSpell = akActor.GetEquippedSpell(leftHand)
    if (kSpell != None)
        akActor.UnequipSpell(kSpell, leftHand)
    endif

    kSpell = akActor.GetEquippedSpell(rightHand)
    if (kSpell != None)
        akActor.UnequipSpell(kSpell, rightHand)
    endif
endFunction

function UnequipShoutForActor(Actor akActor) global
    Shout kShout = akActor.GetEquippedShout()
    if (kShout != None)
        akActor.UnequipShout(kShout)
    endif
endFunction

bool function ActorHasClothing(Actor akActor) global
    ;/
        TODO: Possibly check for more slotMasks, but for now Body should be fine.
    /;
    return akActor.GetWornForm(GetSlotMask("Body")) != none
endFunction

bool function IsActorMale(Actor akActor) global
    return akActor.GetActorBase().GetSex() == 0
endFunction

bool function IsActorFemale(Actor akActor) global
    return akActor.GetActorBase().GetSex() == 1
endFunction

; ==========================================================
;                   Prison/Arrest Functions
; ==========================================================

;/
    Awaits a reference of RPB_Actor for the specified Actor.
    If the Actor is not of the Entity type yet, they will be made into one and bound to it. 

    Actor           @akEntity: The actor to retrieve the Prisoner reference from.
    RPB_ActorList   @apEntityList: The entity list to get the reference from.
    RPB_Entity      @apEntity: The entity to bind this Actor to.
    int?            @aiMaxTries: How many attempts retrieving the reference, in case it fails initially.
    float?          @afInitialTimeBetweenTries: The delay on each try
    float?          @afMaxTimeBetweenTries: The max delay on each try that is possible (Exponential Backoff).

    returns (RPB_Actor): The RPB_Actor reference for this Actor.
/;
RPB_Actor function AwaitEntityReference(\
    Actor akEntity, \
    RPB_ActorList apEntityList, \
    RPB_Entity apEntity = none, \
    int aiMaxTries = 50, \
    float afInitialTimeBetweenTries = 0.1, \
    float afMaxTimeBetweenTries = 3.0 \
) global
    if (apEntityList as RPB_PrisonerList)
        EnsurePrisonerSpellAndBinding(akEntity, apEntity as RPB_Prison)
        ; Debug("Utility::AwaitEntityReference", "("+ akEntity +") apEntityList: " + apEntityList)
        ; Debug("Utility::AwaitEntityReference", "(RPB_PrisonerList) ("+ akEntity +") apEntityList Keys: " + apEntityList.GetKeys())

    elseif (apEntityList as RPB_ArresteeList)
        EnsureArresteeSpellAndBinding(akEntity, apEntity as RPB_Hold)
        ; Debug("Utility::AwaitEntityReference", "(RPB_ArresteeList) ("+ akEntity +") apEntityList Keys: " + apEntityList.GetKeys())

     elseif (apEntityList as RPB_CaptorList)
         EnsureCaptorSpellAndBinding(akEntity)
    endif

    ; Shared logic for awaiting reference
    RPB_Actor entityRef = apEntityList.AtKeyEx(akEntity) as RPB_Actor
    int tries = 0
    float delay = afInitialTimeBetweenTries

    ; Safeguard
    while (!entityRef && tries < aiMaxTries)
        entityRef = apEntityList.AtKeyEx(akEntity) as RPB_Actor
        Utility.Wait(delay)
        ; Debug("Utility::AwaitEntityReference", "("+ tries +") ("+ akEntity +") entityRef: " + entityRef)
        tries += 1
        delay *= 1.5
        if (delay > afMaxTimeBetweenTries)
            delay = afMaxTimeBetweenTries
        endif
    endWhile

    if (!entityRef)
        DebugError("Utility::AwaitEntityReference ["+ apEntityList.ListIdentifier() +"]", "The Actor " + akEntity + " is not in the provided list or there was a state mismatch!")
        Error(akEntity.GetBaseObject().GetName() + " is not in the provided list or there was a state mismatch!")
        return none
    endif
    ; Debug("Utility::AwaitEntityReference", "("+ akEntity +") Returned: " + entityRef)

    return entityRef
endFunction

;/
    Awaits a reference of RPB_Actor for the specified Actor.

    Actor           @akEntity: The actor to retrieve the Prisoner reference from.
    RPB_ActorList   @apEntityList: The entity list to get the reference from.
    RPB_Entity      @apEntity: The entity to bind this Actor to.
    int?            @aiMaxTries: How many attempts retrieving the reference, in case it fails initially.
    float?          @afInitialTimeBetweenTries: The delay on each try
    float?          @afMaxTimeBetweenTries: The max delay on each try that is possible (Exponential Backoff).

    returns (RPB_Actor): The RPB_Actor reference for this Actor.
/;
RPB_Actor function AwaitExistingEntityReference(\
    Actor akEntity, \
    RPB_ActorList apEntityList, \
    RPB_Entity apEntity = none, \
    int aiMaxTries = 50, \
    float afInitialTimeBetweenTries = 0.1, \
    float afMaxTimeBetweenTries = 3.0 \
) global
    ; Shared logic for awaiting reference
    RPB_Actor entityRef = apEntityList.AtKeyEx(akEntity) as RPB_Actor
    int tries = 0
    float delay = afInitialTimeBetweenTries

    ; Safeguard
    while (!entityRef && tries < aiMaxTries)
        entityRef = apEntityList.AtKeyEx(akEntity) as RPB_Actor
        Utility.Wait(delay)
        tries += 1
        delay *= 1.5
        if (delay > afMaxTimeBetweenTries)
            delay = afMaxTimeBetweenTries
        endif
    endWhile

    if (!entityRef)
        DebugError("Utility::AwaitExistingEntityReference ["+ apEntityList.ListIdentifier() +"]", "The Actor " + akEntity + " is not in the provided list or there was a state mismatch!")
        Error(akEntity.GetBaseObject().GetName() + " is not in the provided list or there was a state mismatch!")
        return none
    endif

    return entityRef
endFunction

;/
    Ensures the Actor @akArrestee is an Arrestee, and binds it to @apHold.

    Actor       @akArrestee: The Actor to be ensured as an Arrestee.
    RPB_Hold    @apHold: The Prison to which the Actor should be bound as an Arrestee.
/;
function EnsureArresteeSpellAndBinding(Actor akArrestee, RPB_Hold apHold) global
    if (!akArrestee.HasSpell(RPB_ArresteeSpell()))
        ; Cast the Arrestee spell (to bind the RPB_Arrestee instance script)
        akArrestee.AddSpell(RPB_ArresteeSpell(), false)

        if (apHold)
            ; Bind this Hold to the Arrestee (to retrieve it from RPB_Arrestee)
            RPB_StorageVars.SetStringOnForm("Hold UUID", akArrestee, apHold.UUID, "Arrest")
        endif
    endif
endFunction

;/
    Ensures the Actor @akPrisoner is a Prisoner, and binds it to @apPrison.

    Actor       @akPrisoner: The Actor to be ensured as a Prisoner.
    RPB_Prison  @apPrison: The Prison to which the Actor should be bound as a Prisoner.
/;
function EnsurePrisonerSpellAndBinding(Actor akPrisoner, RPB_Prison apPrison) global
    if (!akPrisoner.HasSpell(RPB_PrisonerSpell()))
        ; Cast the Prisoner spell (to bind the RPB_Prisoner instance script)
        akPrisoner.AddSpell(RPB_PrisonerSpell(), false)

        if (apPrison)
            ; Bind this Prison to the Prisoner (to retrieve it from RPB_Prisoner)
            RPB_StorageVars.SetStringOnForm("Prison UUID", akPrisoner, apPrison.UUID, "Jail")        
        endif
    endif
endFunction

function EnsureCaptorSpellAndBinding(Actor akCaptor) global
    if (!akCaptor.HasSpell(RPB_CaptorSpell()))
        akCaptor.AddSpell(RPB_CaptorSpell(), false)
    endif
endFunction

; ==========================================================
;                     Type Cast Functions
; ==========================================================

Form[] function ActorToFormArray(Actor[] akActors) global
    int arr = JArray.object()

    int i = 0
    while (i < akActors.Length)
        JArray.addForm(arr, akActors[i])
        i += 1
    endWhile

    return JArray.asFormArray(arr)
endFunction

; ==========================================================
;                       Param Functions
; ==========================================================

function AddIntIfNotNone(int aiElement, int arr) global
    if (aiElement)
        JArray.addInt(arr, aiElement)
    endif
endFunction

function AddFormIfNotNone(Form akForm, int arr) global
    if (akForm)
        JArray.addForm(arr, akForm)
    endif
endFunction

int[] function IntList( \
int aiElement1, \
int aiElement2 = 0, \
int aiElement3 = 0, \
int aiElement4 = 0, \
int aiElement5 = 0, \
int aiElement6 = 0, \
int aiElement7 = 0, \
int aiElement8 = 0, \
int aiElement9 = 0, \
int aiElement10 = 0, \
int aiElement11 = 0, \
int aiElement12 = 0, \
int aiElement13 = 0, \
int aiElement14 = 0, \
int aiElement15 = 0, \
int aiElement16 = 0, \
int aiElement17 = 0, \
int aiElement18 = 0, \
int aiElement19 = 0, \
int aiElement20 = 0 \
) global

    int arr = JArray.object()

    AddIntIfNotNone(aiElement1, arr)
    AddIntIfNotNone(aiElement2, arr)
    AddIntIfNotNone(aiElement3, arr)
    AddIntIfNotNone(aiElement4, arr)
    AddIntIfNotNone(aiElement5, arr)
    AddIntIfNotNone(aiElement6, arr)
    AddIntIfNotNone(aiElement7, arr)
    AddIntIfNotNone(aiElement8, arr)
    AddIntIfNotNone(aiElement9, arr)
    AddIntIfNotNone(aiElement10, arr)
    AddIntIfNotNone(aiElement11, arr)
    AddIntIfNotNone(aiElement12, arr)
    AddIntIfNotNone(aiElement13, arr)
    AddIntIfNotNone(aiElement14, arr)
    AddIntIfNotNone(aiElement15, arr)
    AddIntIfNotNone(aiElement16, arr)
    AddIntIfNotNone(aiElement17, arr)
    AddIntIfNotNone(aiElement18, arr)
    AddIntIfNotNone(aiElement19, arr)
    AddIntIfNotNone(aiElement20, arr)

    return JArray.asIntArray(arr)
endFunction

Form[] function BuildParamsObjectReference(\
    ObjectReference akRef1, \
    ObjectReference akRef2 = none, \
    ObjectReference akRef3 = none, \
    ObjectReference akRef4 = none, \
    ObjectReference akRef5 = none, \
    ObjectReference akRef6 = none, \
    ObjectReference akRef7 = none, \
    ObjectReference akRef8 = none, \
    ObjectReference akRef9 = none, \
    ObjectReference akRef10 = none, \
    ObjectReference akRef11 = none, \
    ObjectReference akRef12 = none, \
    ObjectReference akRef13 = none, \
    ObjectReference akRef14 = none, \
    ObjectReference akRef15 = none, \
    ObjectReference akRef16 = none, \
    ObjectReference akRef17 = none, \
    ObjectReference akRef18 = none, \
    ObjectReference akRef19 = none, \
    ObjectReference akRef20 = none \
) global

    int arr = JArray.object()

    AddFormIfNotNone(akRef1, arr)
    AddFormIfNotNone(akRef2, arr)
    AddFormIfNotNone(akRef3, arr)
    AddFormIfNotNone(akRef4, arr)
    AddFormIfNotNone(akRef5, arr)
    AddFormIfNotNone(akRef6, arr)
    AddFormIfNotNone(akRef7, arr)
    AddFormIfNotNone(akRef8, arr)
    AddFormIfNotNone(akRef9, arr)
    AddFormIfNotNone(akRef10, arr)
    AddFormIfNotNone(akRef11, arr)
    AddFormIfNotNone(akRef12, arr)
    AddFormIfNotNone(akRef13, arr)
    AddFormIfNotNone(akRef14, arr)
    AddFormIfNotNone(akRef15, arr)
    AddFormIfNotNone(akRef16, arr)
    AddFormIfNotNone(akRef17, arr)
    AddFormIfNotNone(akRef18, arr)
    AddFormIfNotNone(akRef19, arr)
    AddFormIfNotNone(akRef20, arr)

    return JArray.asFormArray(arr)
endFunction

Form[] function BuildParamsActor(\
    Actor akRef1, \
    Actor akRef2 = none, \
    Actor akRef3 = none, \
    Actor akRef4 = none, \
    Actor akRef5 = none, \
    Actor akRef6 = none, \
    Actor akRef7 = none, \
    Actor akRef8 = none, \
    Actor akRef9 = none, \
    Actor akRef10 = none, \
    Actor akRef11 = none, \
    Actor akRef12 = none, \
    Actor akRef13 = none, \
    Actor akRef14 = none, \
    Actor akRef15 = none, \
    Actor akRef16 = none, \
    Actor akRef17 = none, \
    Actor akRef18 = none, \
    Actor akRef19 = none, \
    Actor akRef20 = none \
) global

    int arr = JArray.object()

    AddFormIfNotNone(akRef1, arr)
    AddFormIfNotNone(akRef2, arr)
    AddFormIfNotNone(akRef3, arr)
    AddFormIfNotNone(akRef4, arr)
    AddFormIfNotNone(akRef5, arr)
    AddFormIfNotNone(akRef6, arr)
    AddFormIfNotNone(akRef7, arr)
    AddFormIfNotNone(akRef8, arr)
    AddFormIfNotNone(akRef9, arr)
    AddFormIfNotNone(akRef10, arr)
    AddFormIfNotNone(akRef11, arr)
    AddFormIfNotNone(akRef12, arr)
    AddFormIfNotNone(akRef13, arr)
    AddFormIfNotNone(akRef14, arr)
    AddFormIfNotNone(akRef15, arr)
    AddFormIfNotNone(akRef16, arr)
    AddFormIfNotNone(akRef17, arr)
    AddFormIfNotNone(akRef18, arr)
    AddFormIfNotNone(akRef19, arr)
    AddFormIfNotNone(akRef20, arr)

    return JArray.asFormArray(arr)

endFunction

; ==========================================================
;                       Alias Functions
; ==========================================================

function BindAliasTo(ReferenceAlias akAlias, ObjectReference akObjectReference) global
    if (akObjectReference != None)
        ; DebugWithArgs("Utility::BindAliasTo", "akAlias: " + akAlias + ", akObjectReference: " + akObjectReference, "Bound Alias to "+ akObjectReference)
        akAlias.ForceRefTo(akObjectReference)
    else
        akAlias.Clear()
    endif
endFunction

function UnbindAlias(ReferenceAlias akAlias) global
    akAlias.Clear()
endFunction

; ==========================================================
;           Distance/Position/Translation Functions
; ==========================================================

float function GetInfinityDistance() global
    return 340282346638528859811
endFunction

float function UnitsToCM(int unit)
    return unit * 1.428
endFunction

float function UnitsToM(int unit)
    return (unit * 1.428) / 100
endFunction

; Faces akObjA relative to akObjB
; 
; Examples:
; OrientRelative(objA, objB) 					; Sets A to face directly away from B
; OrientRelative(objA, objB, afRotZ = 180.0) 	; Sets A to face toward B
; 
function OrientRelative(ObjectReference akObjA, ObjectReference akObjB, Float afRotX = 0.0, Float afRotY = 0.0, Float afRotZ = 0.0) Global
	Float rotX = akObjB.GetAngleX()
	Float rotY = akObjB.GetAngleY()
	Float rotZ = akObjB.GetAngleZ()

	akObjA.SetAngle(rotX, rotY, rotZ)
endFunction

bool function IsFarAwayFromObject(ObjectReference akObjectOne, ObjectReference akObjectTwo) global
    float infinityDistance = 340282346638528859811 ; Obtained from GetDistance in another cell different from @akObjectOne
    return akObjectOne.GetDistance(akObjectTwo) >= infinityDistance
endFunction

bool function IsActorFarAwayFromPlayer(Actor akActor) global
    if (!akActor)
        DebugError("Utility::IsActorFarAwayFromPlayer", "Actor is null, cannot measure the distance!")
        Error("Actor is null, cannot measure the distance!")
        return false
    endif
    
    return IsFarAwayFromObject(akActor, Game.GetPlayer())
endFunction

; ==========================================================
;                       UUID Functions
; ==========================================================

string function GenerateUUIDSection(int aiLength) global
    string result = ""
    while (aiLength > 0)
        result += GetRandomHex()
        aiLength -= 1
    endWhile

    return result
endFunction

string function GenerateUUID() global
    string section1 = GenerateUUIDSection(8)
    string section2 = GenerateUUIDSection(4)
    string section3 = "4" + GenerateUUIDSection(3) ; Force UUIDv4
    string section4 = IntToHex(Utility.RandomInt(8, 11)) + GenerateUUIDSection(3) ; Set 'N' to be 8, 9, A or B
    string section5 = GenerateUUIDSection(12)

    string uuid = section1 + "-" + section2 + "-" + section3 + "-" + section4 + "-" + section5
    return uuid
endFunction

; ==========================================================
;                       Misc Functions
; ==========================================================

int[] function Pair(int n1, int n2) global
    int[] pair = new int[2]
    pair[0] = n1
    pair[1] = n2

    return pair
endFunction

;/
    INFO: Slow function, execution takes ~25ms, avoid when looping

    Retrieves a Form from a string identifier (the string obtained when implicitly casting a Form to a string),
    which means a Form can be passed here.

    string  @asFormIdentifier: The Form's identifier when implicitly cast as a string, expressed like this: [Form < (00036897)>]
    Actor, ObjectReference, or any other Form type will work.

    returns (Form): The Form that matches its identifier.
/;
Form function GetFormFromString(string asFormIdentifier) global
    int formIdLength    = 8 ; FormID always has 8 digits
    int endOffset       = 3 ; )>]
    int len             = StringUtil.GetLength(asFormIdentifier)
    string hexFormID    = StringUtil.Substring(asFormIdentifier, len - endOffset - formIdLength, formIdLength)
    int formID          = HexStringToInt(hexFormID)

    return Game.GetFormEx(formID)
endFunction

;/
    Parses the given number string as an integer in various formats.

    For Decimal numbers, @asNumber should simply be passed the number.
    For Hexadecimal numbers, prefix the number with '0x'.
    For Binary numbers, prefix the number with '0b'.

    returns (int): The given number as an integer in decimal format.
/;
int function ParseInt(string asNumber) global
    bool isHexadecimal  = String_StartsWith(asNumber, "0x")
    bool isBinary       = !isHexadecimal && String_StartsWith(asNumber, "0b")
    bool isDecimal      = !isHexadecimal && !isBinary

    if (isHexadecimal)
        return HexStringToInt(asNumber)

    elseif (isBinary)
        return BinStringToInt(asNumber)

    elseif (isDecimal)
        return asNumber as int
    endif

    return -1
endFunction

int function ParseBinary(string asBin) global
    int BIT_OFF = 0
    int BIT_ON  = 1
    int PREFIX_LEN = 2
    int result = 0
    int len = StringUtil.GetLength(asBin)

    bool hasBinPrefix = String_StartsWith(asBin, "0b")
    int i = int_if (hasBinPrefix, PREFIX_LEN, 0)
    
    while (i < len)
        string currentBit = StringUtil.GetNthChar(asBin, i)
        if (currentBit < BIT_OFF || currentBit > BIT_ON)
            return -1
        endif

        result += Math.Pow(2, (len - 1 - i)) as int
        i += 1
    endWhile

    return result
endFunction

int function HexStringToInt(string asHexString) global
    int result = 0
    int len = StringUtil.GetLength(asHexString)

    bool hasHexPrefix = \ 
        StringUtil.GetNthChar(asHexString, 0) == "0" && \
        StringUtil.GetNthChar(asHexString, 1) == "x"

    int i = int_if (hasHexPrefix, 2, 0)
    while (i < len)
        string currentChar = StringUtil.GetNthChar(asHexString, i)
        int value

        if (StringUtil.IsDigit(currentChar))
            value = (currentChar as int)
        elseif (currentChar == "A")
                value = 10
            elseif (currentChar == "B")
                value = 11
            elseif (currentChar == "C")
                value = 12
            elseif (currentChar == "D")
                value = 13
            elseif (currentChar == "E")
                value = 14
            elseif (currentChar == "F")
                value = 15
        else
            DebugError("Utility::HexStringToInt", "Invalid HEX character: " + currentChar)
            return -1
        endif

        result = result * 16 + value
        ; Debug("Utility::HexStringToInt", "["+ currentChar +"] result: " + result + " (value: "+ value +")")
        i += 1
    endWhile

    return result
endFunction

int function BinStringToInt(string asBinString) global
    int BIT_OFF = 0
    int BIT_ON  = 1
    int PREFIX_LEN = 2
    int result = 0
    int len = StringUtil.GetLength(asBinString)

    bool hasBinPrefix = String_StartsWith(asBinString, "0b")

    int i = int_if (hasBinPrefix, PREFIX_LEN, 0)
    while (i < len)
        string currentChar = StringUtil.GetNthChar(asBinString, i)
        result += Math.Pow(2, (len - 1 - i)) as int
        i += 1
    endWhile

    return result
endFunction

string function IntToHex(int i) global
    if (i >= 0 && i <= 9)
        return i as string

    elseif (i == 10)
        return "A"
    elseif (i == 11)
        return "B"
    elseif (i == 12)
        return "C"
    elseif (i == 13)
        return "D"
    elseif (i == 14)
        return "E"
    elseif (i == 15)
        return "F"
    endif

    return ""
endFunction

string function GetRandomHex() global
    int random = Utility.RandomInt(0, 15)
    return IntToHex(random)
endFunction


Form function GetFormOfType(string asFormType) global
    if (asFormType == "Gold")
        return Game.GetFormEx(0xF)

    elseif (asFormType == "Lockpick")
        return Game.GetFormEx(0xA)
    endif
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
    int currentSlotMask = 30
    int slotMaskValue = 0x00000001
    while (currentSlotMask <= 61)
        if (slotMask == currentSlotMask)
            return slotMaskValue
        endif
        currentSlotMask += 1
        slotMaskValue *= 2 ; Get next slot mask by doubling the value
    endWhile

    return -1
endFunction

string function YesNo(bool abValue) global
    if (abValue)
        return "Yes"
    else
        return "No"
    endif
endFunction

int function EnsureTrue(bool condition, string messageWhenFalse, int failedConditionList = 0) global
    if (!condition && failedConditionList)
        RPB_Memory.FastArray_AddString(failedConditionList, messageWhenFalse)

    elseif (!condition)
        failedConditionList = RPB_Memory.FastArray("<string>")
        RPB_Memory.FastArray_AddString(failedConditionList, messageWhenFalse)
        DebugWarn("Utility::EnsureTrue", messageWhenFalse)
    endif

    return failedConditionList
endFunction

int function EnsureFalse(bool condition, string messageWhenTrue, int failedConditionList = 0) global
    if (condition && failedConditionList)
        RPB_Memory.FastArray_AddString(failedConditionList, messageWhenTrue)

    elseif (condition)
        failedConditionList = RPB_Memory.FastArray("<string>")
        RPB_Memory.FastArray_AddString(failedConditionList, messageWhenTrue)
        DebugWarn("Utility::EnsureFalse", messageWhenTrue)
    endif

    return failedConditionList
endFunction

; ==========================================================
;                 Skill Stats/Perks Functions
; ==========================================================

string[] function GetAllSkillNames(bool abIncludeStatSkills = true, bool abIncludePerkSkills = true) global
    if (!abIncludeStatSkills && !abIncludePerkSkills)
        return none
    endif

    string skillList = ""

    if (abIncludeStatSkills)
        skillList += "Health,Stamina,Magicka,"
    endif

    if (abIncludePerkSkills)
        skillList += "Heavy Armor,Light Armor,Sneak,One-Handed,Two-Handed,Archery,Block," + \
                     "Smithing,Speechcraft,Pickpocketing,Lockpicking,Alteration,Conjuration," + \
                     "Destruction,Illusion,Restoration,Enchanting,Alchemy,"
    endif

    if (skillList != "")
        ; Remove trailing comma
        skillList = StringUtil.Substring(skillList, 0, StringUtil.GetLength(skillList) - 1)
    endif

    return StringUtil.Split(skillList, delim = ",")
endFunction

string function GetSkillName(string asSkillInternalReference) global
    string[] skillNames = GetAllSkillNames()
    string[] skillInternalReferences = GetAllSkills()

    int i = 0
    while (i < skillNames.Length)
        if (asSkillInternalReference == skillInternalReferences[i])
            return skillNames[i]
        endif
        i += 1
    endWhile
endFunction

string[] function GetAllSkills(bool abIncludeStatSkills = true, bool abIncludePerkSkills = true) global
    if (!abIncludeStatSkills && !abIncludePerkSkills)
        return none
    endif

    string skillList = ""

    if (abIncludeStatSkills)
        skillList += "Health,Stamina,Magicka,"
    endif

    if (abIncludePerkSkills)
        skillList += "HeavyArmor,LightArmor,Sneak,OneHanded,TwoHanded,Marksman,Block," + \
                     "Smithing,Speechcraft,Pickpocket,Lockpicking,Alteration,Conjuration," + \
                     "Destruction,Illusion,Restoration,Enchanting,Alchemy,"
    endif

    if (skillList != "")
        ; Remove trailing comma
        skillList = StringUtil.Substring(skillList, 0, StringUtil.GetLength(skillList) - 1)
    endif

    return StringUtil.Split(skillList, delim = ",")
endFunction

string[] function GetStatSkills() global
    return GetAllSkills(true, false)
endFunction

string[] function GetPerkSkills() global
    return GetAllSkills(false, true)
endFunction

bool function IsStatSkill(string asSkillName) global
    string[] statSkills = GetStatSkills()
    
    int i = 0
    while (i < statSkills.Length)
        if (asSkillName == statSkills[i])
            return true
        endif
        i += 1
    endWhile

    return false
endFunction

bool function IsPerkSkill(string asSkillName) global
    return !IsStatSkill(asSkillName)
endFunction

string function GetRandomSkill(string asSkillType = "Stat") global
    if (asSkillType != "Stat" && asSkillType != "Perk")
        return none
    endif

    string[] skills = GetAllSkills(abIncludeStatSkills = asSkillType == "Stat", abIncludePerkSkills = asSkillType == "Perk")
    return skills[Utility.RandomInt(0, skills.Length - 1)]
endFunction

; ==========================================================
;                       Lock Functions
; ==========================================================

string[] function GetLockLevels() global
    return StringUtil.Split("Novice,Apprentice,Adept,Expert,Master,Requires Key", delim = ",")
endFunction

; ==========================================================
;                System Time Related Functions
; ==========================================================

; Retrieves the system time in the format Y-m-d H:i:s
string function GetDateTimeNow() global
    int[] systemTime = PO3_SKSEFunctions.GetSystemTime()
    int year    = systemTime[0]
    int month   = systemTime[1]
    int day     = systemTime[3]
    int hour    = systemTime[4]
    int minute  = systemTime[5]
    int second  = systemTime[6]

    return year + "-" + month + "-" + day + " " + hour + ":" + minute + ":" + second
endFunction


; ==========================================================
;                 Game-Time Related Functions
; ==========================================================

float function now() global
    return Utility.GetCurrentGameTime()
endFunction

float function GetCurrentTime() global
    return Utility.GetCurrentGameTime()
endFunction

int function GetDaysOfMonth(int aiMonth) global
    if (aiMonth == 2) ; Sun's Dawn
        return 28
    elseif (aiMonth == 1 || aiMonth == 3 || aiMonth == 5 || aiMonth == 7 || aiMonth == 8 || aiMonth == 10 || aiMonth == 12)
        return 31
    elseif (aiMonth == 4 || aiMonth == 6 || aiMonth == 9 || aiMonth == 11)
        return 30
    else
        return -1
    endif
endFunction

int function GetCurrentMinute() global
    float hourWithMinutes = GetCurrentHourFloat()
    return GetMinutesFromHour(hourWithMinutes)
endFunction

int function GetCurrentHour() global
    GlobalVariable GameHour = Game.GetFormEx(0x38) as GlobalVariable
    return GameHour.GetValueInt()
endFunction

float function GetCurrentHourFloat() global
    GlobalVariable GameHour = Game.GetFormEx(0x38) as GlobalVariable
    return GameHour.GetValue()
endFunction

int function GetCurrentDay() global
    GlobalVariable GameDay = Game.GetFormEx(0x37) as GlobalVariable
    return GameDay.GetValueInt()
endFunction

int function GetCurrentMonth() global
    GlobalVariable GameMonth = Game.GetFormEx(0x36) as GlobalVariable
    return GameMonth.GetValueInt() + 1  ; starts at 0, ends at 11, the Getters/Setters are 1-12
endFunction

int function GetCurrentYear() global
    GlobalVariable GameYear = Game.GetFormEx(0x35) as GlobalVariable
    return GameYear.GetValueInt()
endFunction

int function GetDaysPassed() global
    GlobalVariable GameYear = Game.GetFormEx(0x39) as GlobalVariable
    return GameYear.GetValueInt()
endFunction

int function GetLastDayOfMonth(int aiMonth) global
    return GetDaysOfMonth(aiMonth)
endFunction

bool function IsLastDayOfMonth() global
    return GetCurrentDay() == GetLastDayOfMonth(GetCurrentMonth())
endFunction

bool function IsLastDayOfYear() global
    return GetCurrentMonth() == 12 && IsLastDayOfMonth()
endFunction

bool function SetGameHour(int aiGameHour) global
    GlobalVariable GameHour = Game.GetFormEx(0x38) as GlobalVariable
    GameHour.SetValueInt(aiGameHour)
endFunction

bool function ModGameHour(float afIncrementByHours) global
    GlobalVariable GameHour = Game.GetFormEx(0x38) as GlobalVariable
    GameHour.Mod(afIncrementByHours)
endFunction

int function GetMinutesFromHour(float aiHour) global
    ; 13.50 = 1:30 PM
    ; Get the minutes from the hour
    float minutesOfHourAsDecimal = aiHour - math.floor(aiHour) ; 0.50 if x.50

    int resultAsMinutes = math.floor(60 * minutesOfHourAsDecimal) ; convert the decimal into minutes (0.5 becomes 30, half an hour)

    ; DebugWithArgs("Utility::GetMinutesFromHour", aiHour, "Getting minutes from hour " + aiHour + " = " + resultAsMinutes + " minutes" + " ("+ "minutesOfHourAsDecimal: " + minutesOfHourAsDecimal + ")")

    return resultAsMinutes
endFunction

string function GetClockFormat(int aiHour, int aiMinutes = 0, string format = "12 Hour") global
    bool isTwelveHourClock = (format == "12 Hour" || format == "12h")

    if (isTwelveHourClock)
        int hourConverted = 0
        if (aiHour >= 0 && aiHour < 12) ; AM
            if (aiHour == 0)
                hourConverted = 12 ; 12 AM
            else
                hourConverted = aiHour ; No need to convert, already in the form of 1-11 AM
            endif
    
            return hourConverted + string_if (aiMinutes > 0, ":" + string_if (aiMinutes < 10, "0" + aiMinutes, aiMinutes) + " AM", ":00 AM")
        elseif (aiHour >= 12 && aiHour < 24) ; PM
            if (aiHour == 12)
                hourConverted = 12 ; 12 PM
            else
                hourConverted = aiHour - 12
            endif
    
            return hourConverted + string_if (aiMinutes > 0, ":" + string_if (aiMinutes < 10, "0" + aiMinutes, aiMinutes) + " PM", ":00 PM")
        endif

    else ; 24h
        string shownHour    = string_if (aiHour < 10, "0" + aiHour, aiHour)
        string shownMinutes = string_if (aiMinutes < 10, "0" + aiMinutes, aiMinutes)

        return shownHour + ":" + shownMinutes
    endif

endFunction

string function GetTimeAs12Hour(int aiHour, int aiMinutes = 0) global
    int hourConverted = 0
    if (aiHour >= 0 && aiHour < 12) ; AM
        if (aiHour == 0)
            hourConverted = 12 ; 12 AM
        else
            hourConverted = aiHour ; No need to convert, already in the form of 1-11 AM
        endif

        return hourConverted + string_if (aiMinutes > 0, ":" + string_if (aiMinutes < 10, "0" + aiMinutes, aiMinutes) + " AM", ":00 AM")
    elseif (aiHour >= 12 && aiHour < 24) ; PM
        if (aiHour == 12)
            hourConverted = 12 ; 12 PM
        else
            hourConverted = aiHour - 12
        endif

        return hourConverted + string_if (aiMinutes > 0, ":" + string_if (aiMinutes < 10, "0" + aiMinutes, aiMinutes) + " PM", ":00 PM")
    endif
endFunction

bool function IsLeapYear(int aiYear) global
    return (aiYear % 4 == 0 && (aiYear % 100 != 0 || aiYear % 400 == 0))
endFunction

bool function IsWeekend(int aiDay, int aiMonth, int aiYear) global
    int dayOfWeek = CalculateDayOfWeek(aiDay, aiMonth, aiYear)
    return dayOfWeek == GetDayOfWeekByName("Loredas") || dayOfWeek == GetDayOfWeekByName("Sundas")
endFunction

bool function IsLoredas(int aiDay, int aiMonth, int aiYear) global
    int dayOfWeek = CalculateDayOfWeek(aiDay, aiMonth, aiYear)
    return dayOfWeek == GetDayOfWeekByName("Loredas")
endFunction

bool function IsSundas(int aiDay, int aiMonth, int aiYear) global
    int dayOfWeek = CalculateDayOfWeek(aiDay, aiMonth, aiYear)
    return dayOfWeek == GetDayOfWeekByName("Sundas")
endFunction

bool function IsWeekday(int aiDay, int aiMonth, int aiYear) global
    return !IsWeekend(aiDay, aiMonth, aiYear)
endFunction

int function CalculateDaysPassedFromDate(int aiDay, int aiMonth, int aiYear) global
    int daysInMonth = GetDaysOfMonth(aiMonth)

    if (daysInMonth == -1)
        return -1
    endif

    int totalDaysPassed = 0 ; All days of all months

    int month = 1
    while (month < aiMonth)
        totalDaysPassed += GetDaysOfMonth(month)
        month += 1
    endWhile

    ; DebugWithArgs("Utility::CalculateDaysPassedFromDate", aiDay + ", " + aiMonth + ", " + aiYear, "month: " + month + ", " + "totalDaysPassed: " + totalDaysPassed)

    ; Add days in the current month
    totalDaysPassed += aiDay

    ; Adjust for leap year if needed
    if (IsLeapYear(aiYear) && aiMonth > 2)
        totalDaysPassed += 1
    endif

    return totalDaysPassed
endFunction

int function GetDayOfWeekByName(string asDayOfWeekName) global
    if (asDayOfWeekName == "Sundas")
        return 1
    elseif (asDayOfWeekName == "Morndas")
        return 2
    elseif (asDayOfWeekName == "Tirdas")
        return 3
    elseif (asDayOfWeekName == "Middas")
        return 4
    elseif (asDayOfWeekName == "Turdas")
        return 5
    elseif (asDayOfWeekName == "Fredas")
        return 6
    elseif (asDayOfWeekName == "Loredas")
        return 7
    endif
endFunction

string function GetDayOfWeekName(int aiDayOfWeek) global
    if (aiDayOfWeek == 1)
        return "Sundas"
    elseif (aiDayOfWeek == 2)
        return "Morndas"
    elseif (aiDayOfWeek == 3)
        return "Tirdas"
    elseif (aiDayOfWeek == 4)
        return "Middas"
    elseif (aiDayOfWeek == 5)
        return "Turdas"
    elseif (aiDayOfWeek == 6)
        return "Fredas"
    elseif (aiDayOfWeek == 7)
        return "Loredas"
    endif
endFunction

string function GetDayOfWeekGregorianName(int aiDayOfWeek) global
    if (aiDayOfWeek == 1)
        return "Monday"
    elseif (aiDayOfWeek == 2)
        return "Tuesday"
    elseif (aiDayOfWeek == 3)
        return "Wednesday"
    elseif (aiDayOfWeek == 4)
        return "Thursday"
    elseif (aiDayOfWeek == 5)
        return "Friday"
    elseif (aiDayOfWeek == 6)
        return "Saturday"
    elseif (aiDayOfWeek == 7)
        return "Sunday"
    endif
endFunction

int function GetFirstDayOfWeek(int aiYear) global
    int daysOfWeek = 7 ; (Morndas, Tirdas, Middas, Turdas, Fredas, Loredas, Sundas)
    
    ; Assign the day of week for 4E 201
    int dayOfWeek4E201 = 3 ; Middas

    int dayOfWeek4EPassedYear = dayOfWeek4E201 ; Assume it's 4E 201 as default

    int startingYear = 201
    while (startingYear < aiYear)
        dayOfWeek4EPassedYear = (dayOfWeek4EPassedYear % daysOfWeek) + 1
        startingYear += 1
    endWhile

    return dayOfWeek4EPassedYear
endFunction

int function CalculateDayOfWeek(int aiDay, int aiMonth, int aiYear) global
    ; Constants
    int daysInWeek = 7

    ; Determine the starting day of the year
    int startingDay = GetFirstDayOfWeek(aiYear)

    ; Calculate total days passed from the beginning of the year
    int totalDaysPassed = CalculateDaysPassedFromDate(aiDay, aiMonth, aiYear)

    ; Determine the day of the week (1 for Morndas, 2 for Tirdas, ..., 7 for Sundas)
    int dayOfWeek = (((totalDaysPassed + startingDay - 1) % daysInWeek)) + 1

    ; DebugWithArgs("Utility::CalculateDayOfWeek", aiDay + ", " + aiMonth + ", " + aiYear, "startingDay: " + startingDay + ", totalDaysPassed: " + totalDaysPassed + ", dayOfWeek: " + dayOfWeek)

    return dayOfWeek
endFunction

int function GetDateFromDaysPassed(int aiDay, int aiMonth, int aiYear, int aiDaysPassed) global
    int currentDay = aiDay + aiDaysPassed
    int currentMonth = aiMonth
    int currentYear = aiYear

    while (currentDay > GetDaysOfMonth(currentMonth)) 
        currentDay -= GetDaysOfMonth(currentMonth)
        currentMonth += 1

        if (currentMonth > 12)
            currentYear += 1
            currentMonth = 1
        endif
    endWhile

    int struct = new_struct()
    SetStructMemberInt(struct, "day", currentDay)
    SetStructMemberInt(struct, "month", currentMonth)
    SetStructMemberInt(struct, "year", currentYear)

    return struct
endFunction

string function GetDateFormat(int aiDay, int aiMonth, int aiYear, int aiHour = 0, int aiMinute = 0, string format = "d/m/Y") global
    string formattedDate = ""

    if (format == "d/m/Y")
        string day      = string_if(aiDay < 10, "0" + aiDay, aiDay)
        string month    = string_if (aiMonth < 10, "0" + aiMonth, aiMonth)
        string year     = "4E " + aiYear

        formattedDate = day + "/" + month + "/" + year

    elseif (format == "D M Y")
        string day      = RPB_Utility.ToOrdinalNthDay(aiDay)
        string month    = RPB_Utility.GetMonthName(aiMonth)
        string year     = "4E " + aiYear

        formattedDate = day + " of " + month + ", " + year
    endif

    return formattedDate
endFunction

int function GetPreviousDayOfWeekFromDate(int aiDay, int aiMonth, int aiYear, int aiDayOfWeek) global
    if (aiDayOfWeek < GetDayOfWeekByName("Sundas") || aiDayOfWeek > GetDayOfWeekByName("Loredas"))
        return -10
    endif

    int dayOfWeekForPassedDate      = CalculateDayOfWeek(aiDay, aiMonth, aiYear)
    int dayOfWeekDifference         = aiDayOfWeek - dayOfWeekForPassedDate
    bool dayOfWeekIsPreviousWeek    = dayOfWeekDifference >= 0
    int daysBackward                = int_if (dayOfWeekIsPreviousWeek, -7 + dayOfWeekDifference, dayOfWeekDifference)

    int newDateForDayOfWeek = GetDateFromDaysPassed(aiDay, aiMonth, aiYear, daysBackward)
    int day      = RPB_Utility.GetStructMemberInt(newDateForDayOfWeek, "day")
    int month    = RPB_Utility.GetStructMemberInt(newDateForDayOfWeek, "month")
    int year     = RPB_Utility.GetStructMemberInt(newDateForDayOfWeek, "year")

    int retval = new_struct()
    SetStructMemberInt(retval, "day", day)
    SetStructMemberInt(retval, "month", month)
    SetStructMemberInt(retval, "year", year)
    SetStructMemberInt(retval, "daysAgo", daysBackward)

    return retval
endFunction

int function GetNextDayOfWeekFromDate(int aiDay, int aiMonth, int aiYear, int aiDayOfWeek) global
    if (aiDayOfWeek < GetDayOfWeekByName("Sundas") || aiDayOfWeek > GetDayOfWeekByName("Loredas"))
        return -10
    endif

    int dayOfWeekForPassedDate = CalculateDayOfWeek(aiDay, aiMonth, aiYear)
    int dayOfWeekDifference     = aiDayOfWeek - dayOfWeekForPassedDate
    bool dayOfWeekIsNextWeek    = dayOfWeekDifference <= 0
    int daysForward             = int_if (dayOfWeekIsNextWeek, 7 + dayOfWeekDifference, dayOfWeekDifference)

    int newDateForDayOfWeek = GetDateFromDaysPassed(aiDay, aiMonth, aiYear, daysForward)
    int day      = RPB_Utility.GetStructMemberInt(newDateForDayOfWeek, "day")
    int month    = RPB_Utility.GetStructMemberInt(newDateForDayOfWeek, "month")
    int year     = RPB_Utility.GetStructMemberInt(newDateForDayOfWeek, "year")

    int retval = new_struct()
    SetStructMemberInt(retval, "day", day)
    SetStructMemberInt(retval, "month", month)
    SetStructMemberInt(retval, "year", year)
    SetStructMemberInt(retval, "daysFromNow", daysForward)

    return retval
endFunction


string function GetMonthName(int aiMonth) global
    if (aiMonth == 1)
        return "Morning Star"
    elseif (aiMonth == 2)
        return "Sun's Dawn"
    elseif (aiMonth == 3)
        return "First Seed"
    elseif (aiMonth == 4)
        return "Rain's Hand"
    elseif (aiMonth == 5)
        return "Second Seed"
    elseif (aiMonth == 6)
        return "Midyear"
    elseif (aiMonth == 7)
        return "Sun's Height"
    elseif (aiMonth == 8)
        return "Last Seed"
    elseif (aiMonth == 9)
        return "Heartfire"
    elseif (aiMonth == 10)
        return "Frostfall"
    elseif (aiMonth == 11)
        return "Sun's Dusk"
    elseif (aiMonth == 12)
        return "Evening Star"
    endif

    return none
endFunction

int function GetMonthByName(string asMonthName) global
    if (asMonthName == "Morning Star")
        return 1
    elseif (asMonthName == "Sun's Dawn")
        return 2
    elseif (asMonthName == "First Seed")
        return 3
    elseif (asMonthName == "Rain's Hand")
        return 4
    elseif (asMonthName == "Second Seed")
        return 5
    elseif (asMonthName == "Midyear")
        return 6
    elseif (asMonthName == "Sun's Height")
        return 7
    elseif (asMonthName == "Last Seed")
        return 8
    elseif (asMonthName == "Heartfire")
        return 9
    elseif (asMonthName == "Frostfall")
        return 10
    elseif (asMonthName == "Sun's Dusk")
        return 11
    elseif (asMonthName == "Evening Star")
        return 12
    endif

    return 0
endFunction

bool function Is28DayMonth(int aiMonth) global
    return GetDaysOfMonth(aiMonth) == 28
endFunction

bool function Is30DayMonth(int aiMonth) global
    return GetDaysOfMonth(aiMonth) == 30
endFunction

bool function Is31DayMonth(int aiMonth) global
    return GetDaysOfMonth(aiMonth) == 31
endFunction

string function ToOrdinalNthDay(int aiDay) global
    return aiDay + GetDayOrdinality(aiDay)
endFunction

string function GetDayOrdinality(int aiDay) global
    if (aiDay > 3 && aiDay < 21)
        return "th"
    endif

    int nthDayOrdinalValue = aiDay % 10

    if (nthDayOrdinalValue == 1)
        return "st"
    elseif (nthDayOrdinalValue == 2)
        return "nd"
    elseif (nthDayOrdinalValue == 3)
        return "rd"
    else
        return "th"
    endif
endFunction

; TODO: Fix weeks calculations
string function GetTimeFormatted(float afTime, bool abIncludeMinutes = false, bool abIncludeHours = true, bool abIncludeDays = true, bool abIncludeWeeks = true, bool abIncludeMonths = true, bool abIncludeYears = true, string asNullValue = "") global
    float timeGameTime  = afTime
    float timeHours     = ((timeGameTime - floor(timeGameTime)) / 0.0416)
    float timeMinutes   = (timeHours - floor(timeHours)) * 60
    float timeDays      = timeGameTime
    float timeMonths    = timeGameTime / 30
    float timeWeeks     = (timeGameTime / 7)
    float timeYears     = (timeDays / 365)

    string timeString = ""

    ; Only display Years, Months or Years
    if (abIncludeYears && floor(timeYears) >= 1)
        timeString = math.floor(timeYears) + " " + string_if (floor(timeYears) == 1, "Year", "Years")

        timeMonths = ((timeYears - floor(timeYears)) * 12)

        if (abIncludeMonths && floor(timeMonths) >= 1)
            timeString += string_if (timeString != "", ", " + floor(timeMonths) + " " + string_if (floor(timeMonths) == 1, "Month", "Months"))
        endif

        return timeString
    endif

    ; Only display Months or Months, Days
    if (abIncludeMonths && floor(timeMonths) >= 1)
        timeString = floor(timeMonths) + " " + string_if (floor(timeMonths) == 1, "Month", "Months")

        timeDays = ((timeMonths - floor(timeMonths)) * 30)
        timeWeeks = (floor(timeDays) % 30) / 7
  
        if (abIncludeWeeks && floor(timeWeeks) >= 1)
            timeString += string_if (timeString != "", ", " + floor(timeWeeks) + " " + string_if (floor(timeWeeks) == 1, "Week", "Weeks"))

        elseif (abIncludeDays && floor(timeDays) >= 1)
            timeString += string_if (timeString != "", ", " + floor(timeDays) + " " + string_if (floor(timeDays) == 1, "Day", "Days"))
        endif

        return timeString
    endif

    if (abIncludeWeeks && floor(timeWeeks) >= 1)
        timeString = floor(timeWeeks) + " " + string_if (floor(timeWeeks) == 1, "Week", "Weeks")

        timeDays = (timeWeeks - floor(timeWeeks)) * 7

        if (abIncludeDays && floor(timeDays) >= 1)
            timeString += string_if (timeString != "", ", " + floor(timeDays) + " " + string_if (floor(timeDays) == 1, "Day", "Days"))
        endif

        return timeString
    endif

    ; Only display Days or Days, Hours
    if (abIncludeDays && floor(timeDays) >= 1)
        timeHours = ((timeDays - floor(timeDays)) * 24)

        if (timeHours > 24)
            timeDays += 1
            timeHours -= 24
        endif

        timeString = floor(timeDays) + " " + string_if (floor(timeDays) == 1, "Day", "Days")

        if (abIncludeHours && floor(timeHours) >= 1)
            timeString += string_if (timeString != "", ", " + floor(timeHours) + " " + string_if (floor(timeHours) == 1, "Hour", "Hours"))
        endif

        return timeString
    endif

    ; Only display Hours or Hours, Minutes
    if (abIncludeHours && floor(timeHours) >= 1)
        timeString = floor(timeHours) + " " + string_if (floor(timeHours) == 1, "Hour", "Hours")

        timeMinutes = ((timeHours - floor(timeHours)) * 60)

        if (abIncludeMinutes && floor(timeMinutes) >= 1)
            timeString += string_if (timeString != "", ", " + floor(timeMinutes) + " " + string_if (floor(timeMinutes) == 1, "Minute", "Minutes"))
        endif

        return timeString
    endif

    ; Only display Minutes
    if (abIncludeMinutes && floor(timeMinutes) >= 1)
        timeString = floor(timeMinutes) + " " + string_if (floor(timeMinutes) == 1, "Minute", "Minutes")

        return timeString
    endif

    return asNullValue
endFunction

string function GetFormattedDate(int aiDay, int aiMonth, int aiYear, int aiHour = 0, int aiMinute = 0, bool abShowDayOfWeek = true, bool abShowDay = true, bool abShowTime = true, bool abShowYear = true) global
    string dayOfWeek    = GetDayOfWeekName(CalculateDayOfWeek(aiDay, aiMonth, aiYear))
    string hour         = GetClockFormat(aiHour, aiMinute)
    string dayOrdinal   = ToOrdinalNthDay(aiDay)
    string monthName    = GetMonthName(aiMonth)
    string yearString   = "4E " + aiYear

    string dateResult = ""

    if (abShowDayOfWeek)
        dateResult += dayOfWeek + ", "
    endif

    if (abShowTime)
        dateResult += hour + ", "
    endif

    if (abShowDay)
        dateResult += dayOrdinal + " of "
    endif

    dateResult += monthName + ", "

    if (abShowYear)
        dateResult += yearString
    endif

    return dateResult
    ; Fredas, 7:00 AM, 21st of Sun's Dusk, 4E 201
    ; return dayOfWeek + ", " + hour + ", " + dayOrdinal + " of " + monthName + ", " + yearString
endFunction

string function GetFormattedDate24Hours(int aiDay, int aiMonth, int aiYear, int aiHour = 0, int aiMinute = 0) global

endFunction

string function GetCurrentDateFormatted() global
    int currentDay      = GetCurrentDay()
    int currentMonth    = GetCurrentMonth()
    int currentYear     = GetCurrentYear()
    float currentHour   = GetCurrentHourFloat()
    int minutesFromHour = GetMinutesFromHour(currentHour)

    return GetFormattedDate(currentDay, currentMonth, currentYear, floor(currentHour), minutesFromHour)
endFunction

string function GetNextDayOfWeekDateFormatted(string asDayOfWeek, bool abShowTime = false) global
    int nextDayOfWeek       = GetNextDayOfWeekFromDate(GetCurrentDay(), GetCurrentMonth(), GetCurrentYear(), GetDayOfWeekByName(asDayOfWeek))
    int day                 = GetStructMemberInt(nextDayOfWeek, "day")
    int month               = GetStructMemberInt(nextDayOfWeek, "month")
    int year                = GetStructMemberInt(nextDayOfWeek, "year")
    int daysTillDayOfWeek   = GetStructMemberInt(nextDayOfWeek, "daysFromNow")

    return GetFormattedDate(day, month, year, GetCurrentHour(), GetCurrentMinute(), abShowTime = abShowTime)
endFunction

string function GetPreviousDayOfWeekDateFormatted(string asDayOfWeek, bool abShowTime = false) global
    int previousDayOfWeek   = GetPreviousDayOfWeekFromDate(GetCurrentDay(), GetCurrentMonth(), GetCurrentYear(), GetDayOfWeekByName(asDayOfWeek))
    int day                 = GetStructMemberInt(previousDayOfWeek, "day")
    int month               = GetStructMemberInt(previousDayOfWeek, "month")
    int year                = GetStructMemberInt(previousDayOfWeek, "year")
    int daysFromDayOfWeek   = GetStructMemberInt(previousDayOfWeek, "daysAgo")

    return GetFormattedDate(day, month, year, GetCurrentHour(), GetCurrentMinute(), abShowTime = abShowTime)
endFunction


bool function PassTimeInDays(int aiPassByDays) global
    GlobalVariable GameDaysPassed = Game.GetFormEx(0x39) as GlobalVariable
    GlobalVariable GameHour = Game.GetFormEx(0x38) as GlobalVariable

    int daysPassed = 0
    while (daysPassed < aiPassByDays)
        int currentDay      = GetCurrentDay()
        int currentMonth    = GetCurrentMonth()
        int daysInMonth     = GetDaysOfMonth(currentMonth)

        GameHour.Mod(24)
        Utility.Wait(0.01)
        string currentDate = GetCurrentDay() + "/" + GetCurrentMonth() + "/" + GetCurrentYear()
        DebugWithArgs("Utility::PassTimeInDays", aiPassByDays, "Date: " + currentDate +  " at " + GetTimeAs12Hour(GetCurrentHour()) + " ("+ GetTimeAs12Hour(GetCurrentHour()) +", "+  ToOrdinalNthDay(GetCurrentDay()) +" of " + GetMonthName(GetCurrentMonth()) +")" + ", " + "GameDaysPassed: " + GameDaysPassed.GetValue())
        daysPassed += 1
    endWhile
    ; GameHour.Mod(-1) ; Take off one hour, for some reason, after passing the days, the time is incremented by 1h
endFunction


string function FormatFloat(float number) global
    string numberAsString       = number as string
    int decimalPlacePosition    = StringUtil.Find(numberAsString, ".")

    if (decimalPlacePosition == -1) 
        return numberAsString
    endif

    string wholePart            = StringUtil.Substring(numberAsString, 0, decimalPlacePosition)
    string decimalPart          = StringUtil.Substring(numberAsString, decimalPlacePosition + 1)

    int decimalLength = StringUtil.GetLength(decimalPart)
    int decimalsToUse = Min(2, decimalLength) as int

    string formattedNumber = wholePart + "." + StringUtil.Substring(decimalPart, 0, decimalsToUse)

    ; DebugParams(number + "," + numberAsString + ",", "number, numberAsString")
    return formattedNumber
endFunction

; ==========================================================
;                           Struct
; ==========================================================
;/
    int myStruct = struct( \ 
        "bool: (isImprisoned = false, isInCell = false) |" + \ 
        "string: () |" + \ 
        "Form[]: (prisons) |" \ 
    )

    GetStructMemberBool(myStruct, "isInCell")
/;

; int function struct(string apStructMembers, bool abRetain = false) global
;     int structObj = JMap.object()

;     if (abRetain)
;         JValue.retain(structObj, "struct")
;     endif

;     return structObj
; endFunction

int function new_struct(bool abRetain = false, string asStructType = "") global
    int structObj = JMap.object()

    if (abRetain)
        JValue.retain(structObj, asStructType)
    endif

    return structObj
endFunction

bool function GetStructMemberBool(int apStructObject, string asMemberName) global
    return JMap.getInt(apStructObject, asMemberName) as bool
endFunction

int function GetStructMemberInt(int apStructObject, string asMemberName) global
    return JMap.getInt(apStructObject, asMemberName)
endFunction

float function GetStructMemberFloat(int apStructObject, string asMemberName) global
    return JMap.getFlt(apStructObject, asMemberName)
endFunction

string function GetStructMemberString(int apStructObject, string asMemberName) global
    return JMap.getStr(apStructObject, asMemberName)
endFunction

Form function GetStructMemberForm(int apStructObject, string asMemberName) global
    return JMap.getForm(apStructObject, asMemberName)
endFunction

function SetStructMemberBool(int apStructObject, string asMemberName, bool value) global
    JMap.setInt(apStructObject, asMemberName, value as int)
endFunction

function SetStructMemberInt(int apStructObject, string asMemberName, int value) global
    JMap.setInt(apStructObject, asMemberName, value)
endFunction

function SetStructMemberFloat(int apStructObject, string asMemberName, float value) global
    JMap.setFlt(apStructObject, asMemberName, value)
endFunction

function SetStructMemberString(int apStructObject, string asMemberName, string value) global
    JMap.setStr(apStructObject, asMemberName, value)
endFunction

function SetStructMemberForm(int apStructObject, string asMemberName, Form value) global
    JMap.setForm(apStructObject, asMemberName, value)
endFunction

function DestroyStruct(int apStructObject) global
    if (apStructObject)
        JValue.release(apStructObject)
    endif
endFunction

function DestroyStructsOfType(string asStructType) global
    JValue.releaseObjectsWithTag(asStructType)
endFunction


; ==========================================================
;                    Benchmark Functions
; ==========================================================

float function StartBenchmark(bool condition = true) global
    if (condition)
        float startTime = Utility.GetCurrentRealTime()
        return startTime
    endif
endFunction

int function EndBenchmark(float startTime, string _message = "", bool condition = true) global
    if (condition)
        float endTime = Utility.GetCurrentRealTime()
        int elapsedTime = ((endTime - startTime) * 1000) as int
        base_log("BENCHMARK:", string_if (_message != "", _message + " ") + "execution took " + elapsedTime + " ms")
        return elapsedTime
    endif
endFunction


; ==========================================================
;                           Temporary
; ==========================================================

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

ObjectReference function GetNearestJailDoorOfTypeEx(Form akJailBaseDoor, ObjectReference akCenterRef, float afRadius) global
    ObjectReference _cellDoor = Game.FindClosestReferenceOfTypeFromRef(akJailBaseDoor, akCenterRef, afRadius)
    return _cellDoor
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
        ; if (_actor && _actor.GetActorBase().GetSex() == 1 && _actor.GetFormID() != 0x14 && !_actor.IsChild())
        if (_actor && _actor.GetFormID() != 0x14 && !_actor.IsChild() && _actor.IsGuard())
            return _actor
        endif

        if (radius < 8000)
            radius *= 2
        endif
        i -= 1
    endWhile

    return none
endFunction

Actor function GetNearestActorFromList(Actor akRef, Form[] akRefs) global
    float nearestRefDistance = GetInfinityDistance()
    int nearestRefIndex = -1
    int i = 0
    while (i < akRefs.Length)
        if (akRefs[i] != none)
            Actor akRefFromList = akRefs[i] as Actor
            float distanceToRef = akRefFromList.GetDistance(akRef)
            if (distanceToRef < nearestRefDistance)
                nearestRefDistance = distanceToRef
                nearestRefindex = i
            endif
        endif
        i += 1
    endWhile

    if (nearestRefIndex != -1)
        return akRefs[nearestRefIndex] as Actor
    endif

    return none
endFunction

Actor function GetNearbyActorFromRefWithPrototype(ObjectReference akCenterRef, ActorBase akPrototype, float afMaxRadius = 1000.0) global
    int tries       = 0
    int maxTries    = 30
    float radius    = 50

    while (tries < maxTries)
        Actor scannedActor = Game.FindRandomActorFromRef(akCenterRef, radius)
        bool conditions = scannedActor.GetActorBase() == akPrototype

        if (conditions)
            return scannedActor
        endif

        if (radius < afMaxRadius)
            radius += 100
        endif

        tries += 1
    endWhile

    return none
endFunction

Actor function GetNearbyGuardForFactionFromRef( \
    ObjectReference akCenterRef, \ 
    Faction akCrimeFaction = none, \ 
    float afMinRadius = 50.0, \ 
    float afMaxRadius = 1000.0, \ 
    float afIncreaseRadiusBy = 100.0, \
    int aiMaxScans = 30 \ 
) global
    int scans    = 0
    float radius = afMinRadius

    while (scans < aiMaxScans)
        Actor scannedActor = Game.FindRandomActorFromRef(akCenterRef, radius)

        bool conditions = \ 
            scannedActor.GetFormID() != 0x14 && \
            !scannedActor.IsChild() && \
            scannedActor.IsGuard()

        if (conditions)
            return scannedActor
        endif

        if (radius < afMaxRadius)
            radius += afIncreaseRadiusBy
        endif

        scans += 1
    endWhile

    return none
endFunction

Actor function GetNearestGuard(ObjectReference centerRef, float radius, ObjectReference exclude) global
    int i = 30

    while (i > 0)
        Actor _actor = Game.FindRandomActorFromRef(centerRef, radius)
        bool notPlayer = _actor.GetFormID() != 0x14
        if (_actor && notPlayer && !_actor.IsChild() && _actor.IsGuard() && _actor != exclude)
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