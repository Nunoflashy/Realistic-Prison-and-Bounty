Scriptname RealisticPrisonAndBounty_Util hidden

;/ 
    Logger
/;

string function ModName() global
    return "Realistic Prison and Bounty"
endFunction

int function LOG_NOTYPE() global
    return -1
endFunction

int function LOG_TRACE() global
    return 0
endFunction

int function LOG_DEBUG() global
    return 1
endFunction

int function LOG_INFO() global
    return 2
endFunction

int function LOG_WARN() global
    return 3
endFunction

int function LOG_ERROR() global
    return 4
endFunction

int function LOG_FATAL() global
    return 4
endFunction

bool function LOG_CALL_HIDDEN() global
    return true
endFunction

string function __getLogLevel(int _level) global
    return \ 
        string_if(_level == LOG_NOTYPE(), "", \
        string_if(_level == LOG_TRACE(), "trace:", \
        string_if(_level == LOG_DEBUG(), "debug:", \
        string_if(_level == LOG_INFO(), "info:", \
        string_if(_level == LOG_WARN(), "warn:", \
        string_if(_level == LOG_ERROR(), "error:", \
        string_if(_level == LOG_FATAL(), "fatal:")))))))
endFunction


function local_log(string caller, string logInfo, int logLevel = 0, bool hideCall = false) global
    string _scriptName = ModName()
    string logLvl  = __getLogLevel(logLevel)

    bool noCall = caller == "" || hideCall
    debug.trace( \
        string_if(noCall, "[" + _scriptName + "] " +  logLvl + " " + logInfo, \
        "[" + _scriptName + "] " +  logLvl + " " + caller + "() -> " + logInfo) \
    )
endFunction
; //////////////////////////

function local_log_if(string caller, string logInfo, bool condition, int logLevel = 0, bool hideCall = false) global
    if(condition)
        local_log(caller, logInfo, logLevel, hideCall)
    endif
endfunction

function Log(Form script, string caller, string logInfo, int logLevel = 0, bool hideCall = false) global
    string logLvl  = __getLogLevel(logLevel)

    if(caller == "" || hideCall)
        ; We didn't pass any function name nor a state scope, let the log be anonymous
        debug.trace("[" + ModName() + "] " +  logLvl + " " + logInfo)
    else
        caller += "()" ; Append to caller name

        if(script.GetState() != "")
            ; We are currently in a state, let the caller know
            string scopedState = script.GetState() + "::" + caller

            ; Since the caller was appended to the scoped state, the caller becomes part of the state
            caller = scopedState
        endif
        debug.trace("[" + ModName() + "] " +  logLvl + " " + caller + " -> " + logInfo)
    endif

    ; With caller from a state:     [ModName] INFO: State::OnUpdateGameTime() -> Message
    ; With caller from empty state: [ModName] INFO: OnUpdateGameTime() -> Message
    ; Without caller:               [ModName] INFO: Message
endFunction
; //////////////////////////

function Trace(Form script, string caller, string logInfo, bool condition = true, bool hideCall = false) global
    LogIf(script, caller, logInfo, condition, LOG_TRACE(), hideCall)
    ; Log(script, caller, logInfo, LOG_TRACE(), hideCall)
endfunction

function Debug(Form script, string caller, string logInfo, bool condition = true, bool hideCall = false) global
    LogIf(script, caller, logInfo, condition, LOG_DEBUG(), hideCall)
    ; Log(script, caller, logInfo, LOG_DEBUG(), hideCall)
endfunction

function Info(Form script, string caller, string logInfo, bool condition = true, bool hideCall = false) global
    LogIf(script, caller, logInfo, condition, LOG_INFO(), hideCall)
    ; Log(script, caller, logInfo, LOG_INFO(), hideCall)
endfunction

function Warn(Form script, string caller, string logInfo, bool condition = true, bool hideCall = false) global
    LogIf(script, caller, logInfo, condition, LOG_WARN(), hideCall)
    ; Log(script, caller, logInfo, LOG_WARN(), hideCall)
endfunction

function Error(Form script, string caller, string logInfo, bool condition = true, bool hideCall = false) global
    LogIf(script, caller, logInfo, condition, LOG_ERROR(), hideCall)
    ; Log(script, caller, logInfo, LOG_ERROR(), hideCall)
endfunction

function Fatal(Form script, string caller, string logInfo, bool condition = true, bool hideCall = false) global
    LogIf(script, caller, logInfo, condition, LOG_FATAL(), hideCall)
    ; Log(script, caller, logInfo, LOG_FATAL(), hideCall)
endfunction

function LogIf(Form script, string caller, string logInfo, bool condition, int logLevel = 0, bool hideCall = false) global
    if(condition)
        Log(script, caller, logInfo, logLevel, hideCall)
    endif
endfunction

function WarnIf(Form script, string caller, string logInfo, bool condition, bool hideCall = false) global
    LogIf(script, caller, logInfo, condition, LOG_WARN(), hideCall)
endfunction

function ErrorIf(Form script, string caller, string logInfo, bool condition, bool hideCall = false) global
    LogIf(script, caller, logInfo, condition, LOG_ERROR(), hideCall)
endfunction

function LogProperty(Form script, string prop, string logInfo, int logLevel = 0) global
    string logLvl  = __getLogLevel(logLevel)

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
; //////////////////////////

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

function LogParams(Form script, string caller, string logInfo, string args, int logLevel = 0, bool hideCall = false) global
    string logLvl  = __getLogLevel(logLevel)

    if(caller == "" || hideCall)
        ; We didn't pass any function name nor a state scope, let the log be anonymous
        debug.trace("[" + ModName() + "] " +  logLvl + " " + logInfo)
    else
        caller += "(" + args + ")" ; Append to caller name

        if(script.GetState() != "")
            ; We are currently in a state, let the caller know
            string scopedState = script.GetState() + "::" + caller

            ; Since the caller was appended to the scoped state, the caller becomes part of the state
            caller = scopedState
        endif
        debug.trace("[" + ModName() + "] " +  logLvl + " " + caller + " -> " + logInfo)
    endif

    ; With caller from a state:     [ModName] INFO: State::OnUpdateGameTime() -> Message
    ; With caller from empty state: [ModName] INFO: OnUpdateGameTime() -> Message
    ; Without caller:               [ModName] INFO: Message
endFunction
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

ObjectReference function objectreference_if(bool condition, ObjectReference akTrue, ObjectReference akFalse = none) global
    if(condition)
        return akTrue
    else
        return akFalse
    endif
endfunction

Actor function actor_if(bool condition, Actor akTrue, Actor akFalse = none) global
    if(condition)
        return akTrue
    else
        return akFalse
    endif
endfunction

Faction function faction_if(bool condition, Faction akTrue, Faction akFalse = none, bool hasElseClause = false) global
    ; Implicit assignment if we pass a value to akFalse, or explicit if we set hasElseClause to true
    hasElseClause = bool_if(hasElseClause || !is_null(akFalse), true)
    local_log_if("faction_if", "no else clause specified, function may return none!", !hasElseClause, 1)

    if(condition)
        return akTrue
    elseif(!condition && hasElseClause)
        return akFalse
    endif

    return none
endfunction


bool function is_null(Form akForm) global
    return akForm == none || akForm == None
endfunction

;/
    Function that takes two functions as parameter,
    calls @ifCall if condition is met, otherwise call @elseCall
    objective:
        let x = () => {
            // Do things if condition is met
        }

        let y = () => {
            // Do things if condition is not met
        }

    usage: call_if(true, x, y)
        Calls x if condition is met, otherwise calls y

    returns true if the function was called
    returns false if the function was not called
/;
bool function call_if(bool condition, string _if, string _else = "")
    string functionToCall = ""
    bool calledSuccessfully = false
    if(condition)
        functionToCall = _if
        calledSuccessfully = true
    else
        functionToCall = _else
        calledSuccessfully = false
    endif

    LogIf(none, "call_if", "Could not call function none!", functionToCall == "", 2)

    GotoState(functionToCall)
    return calledSuccessfully
endfunction

;/
    Item Functions
/;

function WearItem(Actor akActor, Form akItem, int count = 1, bool forced = false, bool silent = true) global
    bool invalidParams = is_null(akActor) || is_null(akItem)

    if(invalidParams)
        local_log("WearItem", "The parameters are invalid!" + "(" + akActor + "," + akItem + ")")
        return
    endif

    akActor.AddItem(akItem, aiCount = count, abSilent = silent)
    akActor.EquipItemEx(akItem, equipSlot = 0, preventUnequip = forced, equipSound = false)
endfunction

function UnwearItem(Actor akActor, Form akItem, int count = 1, bool forced = false, bool silent = true) global
    bool invalidParams = is_null(akActor) || is_null(akItem)

    if(invalidParams)
        local_log("WearItem", "The parameters are invalid!" + "(" + akActor + "," + akItem + ")")
        return
    endif

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

string function TrimString(string source) global
    string[] split = PapyrusUtil.StringSplit(source, " ")
    string joined = PapyrusUtil.StringJoin(split, "")
    return joined
endFunction

string function StoragePrefix() global
    return ".__" + ModName() + "__."
endFunction

function __setOptionEnabled(string _key) global
    JDB.solveIntSetter(StoragePrefix() + "OPTION_ID.ENABLED." + _key, true as int)
endFunction

bool function IsOptionSet(string _key) global
    return JDB.solveInt(StoragePrefix() + "OPTION_ID.ENABLED." + _key)
endFunction

int function GetOptionIntValue(int oid, int default = -1) global
    int NOT_DEFINED = -1
    return JDB.solveInt(StoragePrefix() + "OPTION_ID." + oid, default)
endFunction

bool function GetOptionBoolValue(int oid, bool default = false) global
    return GetOptionIntValue(oid, default as int)
endFunction

float function GetOptionIntValueFloat(int oid) global
    return JDB.solveFlt(StoragePrefix() + "OPTION_ID." + oid)
endFunction

bool function SetOptionValueBoolByKey(string _key, bool value) global
    return JDB.solveIntSetter(StoragePrefix() + "OPTION_ID." + _key, value as int, true)
endFunction

bool function SetOptionValueIntByKey(string _key, int value) global
    return JDB.solveIntSetter(StoragePrefix() + "OPTION_ID." + _key, value, true)
endFunction

int function GetOptionIntValueByKey(string _key) global
    return JDB.solveInt(StoragePrefix() + "OPTION_ID." + _key)
endFunction

bool function SetOptionValueBool(int optionId, bool value) global
    return JDB.solveIntSetter(StoragePrefix() + "OPTION_ID." + optionId, value as int, true)
endFunction

bool function SetOptionValueInt(int optionId, int value) global
    return JDB.solveIntSetter(StoragePrefix() + "OPTION_ID." + optionId, value, true)
endFunction

bool function SetOptionValueFloat(int optionId, float value) global
    return JDB.solveFltSetter(StoragePrefix() + "OPTION_ID." + optionId, value, true)
endFunction

bool function SetOptionValueString(int optionId, string value) global
    return JDB.solveStrSetter(StoragePrefix() + "OPTION_ID." + optionId, value, true)
endFunction

bool function SetOptionValueForm(int optionId, Form value) global
    return JDB.solveFormSetter(StoragePrefix() + "OPTION_ID." + optionId, value, true)
endFunction

float function StartBenchmark(bool condition = true) global
    if (condition)
        float startTime = Utility.GetCurrentRealTime()
        return startTime
    endif
endFunction

float function EndBenchmark(float startTime, bool condition = true) global
    if (condition)
        float endTime = Utility.GetCurrentRealTime()
        float elapsedTime = endTime - startTime
        local_log(none, "execution took " + ((elapsedTime * 1000)) + " ms", LOG_DEBUG(), hideCall = true)
        return elapsedTime
    endif
endFunction