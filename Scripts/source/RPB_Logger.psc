scriptname RPB_Logger extends ReferenceAlias

import RPB_Utility

; ==========================================================
;                      Script References
; ==========================================================

; ==========================================================
;                        Properties
; ==========================================================

bool property Logging
    bool function get()
        return RPB_StorageVars.GetBool("LOG", "Log", true)
    endFunction

    function set(bool value)
        RPB_StorageVars.SetBool("LOG", value, "Log")
    endFunction
endProperty

bool property Tracing
    bool function get()
        return RPB_StorageVars.GetBool("TRACE", "Log", true)
    endFunction

    function set(bool value)
        RPB_StorageVars.SetBool("TRACE", value, "Log")
    endFunction
endProperty

bool property Debugging
    bool function get()
        return RPB_StorageVars.GetBool("DEBUG", "Log", true)
    endFunction

    function set(bool value)
        RPB_StorageVars.SetBool("DEBUG", value, "Log")
    endFunction
endProperty

; ==========================================================
;                        Event Handlers
; ==========================================================

event OnTrace(string msg, string caller)
    Trace(caller, msg)
endEvent

event OnInfo(string msg, string caller, bool condition)
    DebugInfo(caller, msg, condition)
    Info(msg, condition)
endEvent

event OnWarn(string msg, string caller, bool condition)
    DebugWarn(caller, msg, condition)
    Warn(msg, condition)
endEvent

event OnError(string msg, string caller, bool condition)
    DebugError(caller, msg, condition)
    Error(msg, condition)
endEvent

; ==========================================================
;                      Event Dispatchers
; ==========================================================

function SendError(string msg, string caller = "", bool condition = true)
    self.OnError(msg, caller, condition)
endFunction

function SendWarning(string msg, string caller = "", bool condition = true)
    self.OnWarn(msg, caller, condition)
endFunction

function SendInfo(string msg, string caller = "", bool condition = true)
    self.OnInfo(msg, caller, condition)
endFunction

function TraceParams(string params, string paramNames = "", string caller = "")
    string[] splitParams    = StringUtil.Split(params, ",")
    string[] splitNames     = StringUtil.Split(paramNames, ", ")

    string traceMsg = "[\n"
    int i = 0
    while (i < splitParams.Length)
        string paramName = string_if (splitNames[i], splitNames[i], i)
        traceMsg = "\t" + paramName + ": " + splitParams[i] + "\n"
        ; if (i < splitParams.Length - 1)
        ;     traceMsg += "\n"
        ; endif
        i += 1
    endWhile
    traceMsg += "\n]"
    
    self.OnTrace(traceMsg, caller)
endFunction

; ==========================================================
;                     Log Functions Base
; ==========================================================

function base_log(string asLogType = "DEBUG", string asLogInfo, string asCaller = "", string asCallerArgs = "") global
    if (asCaller)
        debug.trace("["+ ModName() +"] " + asLogType + " " + asCaller + "("+ asCallerArgs +")" + " -> " + asLogInfo)
    else
        debug.trace("["+ ModName() +"] " + asLogType + " " + asLogInfo)
    endif
endFunction

function Trace(string asCaller, string asLogInfo, bool abCondition = true)
    if (!abCondition || !Tracing)
        return
    endif

    base_log("TRACE:", asLogInfo, asCaller)
endFunction

function Debug(string asCaller, string asLogInfo, bool abCondition = true)
    if (!abCondition || !Debugging)
        return
    endif

    base_log("DEBUG:", asLogInfo, asCaller)
endFunction

function DebugInfo(string asCaller, string asLogInfo, bool abCondition = true)
    if (!abCondition || !Debugging)
        return
    endif

    base_log("INFO:", asLogInfo, asCaller)
endFunction

function DebugWarn(string asCaller, string asLogInfo, bool abCondition = true)
    if (!abCondition || !Debugging)
        return
    endif

    base_log("WARN:", asLogInfo, asCaller)
endFunction

function DebugError(string asCaller, string asLogInfo, bool abCondition = true)
    if (!abCondition || !Debugging)
        return
    endif

    base_log("ERROR:", asLogInfo, asCaller)
endFunction

function DebugWithArgs(string asCaller, string asArgs, string asLogInfo, bool abCondition = true)
    if (!abCondition || !Debugging)
        return
    endif

    base_log("DEBUG:", asLogInfo, asCaller, asArgs)
endFunction

function DebugParams(string params, string paramNames = "", string caller = "", bool abCondition = true)
    if (!abCondition || !Debugging)
        return
    endif

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

    Debug(caller, msg, abCondition)
endFunction


function LogNoType(string asLogInfo, string asCaller = "", bool abCondition = true)
    if (!abCondition || !Logging)
        return
    endif

    debug.trace("["+ ModName() +"] " + asLogInfo)
endFunction

function Info(string asLogInfo, bool abCondition = true)
    if (!abCondition || Debugging || !Logging)
        return
    endif

    base_log("INFO:", asLogInfo)
endFunction

function Warn(string asLogInfo, bool abCondition = true)
    if (!abCondition || Debugging || !Logging)
        return
    endif

    base_log("WARN:", asLogInfo)
endFunction

function Error(string asLogInfo, bool abCondition = true)
    if (!abCondition || Debugging || !Logging)
        return
    endif

    base_log("ERROR:", asLogInfo)
endFunction

function Fatal(string asLogInfo, bool abCondition = true)
    if (!abCondition || Debugging || !Logging)
        return
    endif

    base_log("FATAL:", asLogInfo)
endFunction

function LogProperty(string prop, string asLogInfo, bool condition = true)
    if (!condition || Debugging || !Logging)
        return
    endif
    
    base_log("PROPERTY:", asLogInfo)
endFunction

function ErrorProperty(string asProperty, string asLogInfo, bool condition = true)
    if (!condition || Debugging || !Logging)
        return
    endif

    base_log("ERROR (PROPERTY):", asLogInfo)
endFunction

function NotImplemented(string asCaller, bool abCondition = true)
    if (!abCondition || !Debugging)
        return
    endif

    base_log("IMPLEMENT:", asCaller + " has not been implemented!", asCaller)
endFunction

function FunctionNotImplemented(string asCaller, bool abCondition = true)
    if (!abCondition || !Debugging)
        return
    endif

    base_log("IMPLEMENT:", "Function " + asCaller + "() has not been implemented!", asCaller)
endFunction

function EventNotImplemented(string asCaller, bool abCondition = true)
    if (!abCondition || !Debugging)
        return
    endif

    base_log("IMPLEMENT:", "Event " + asCaller + "() has not been implemented!", asCaller)
endFunction
