scriptname RPB_Recovery hidden

;/
@functions:
    string function ResetActor(Actor akActor) global
    string function CancelArrest(Actor akActor, string asReason, bool abReturnBelongings = true) global
/;

;/
    Frees @akActor from everything this mod may have left on them, however they got stuck: a prisoner is released where
    they stand (belongings back from the prison's container, outfit, cell package, hostility restore, and whatever is left
    of their arrest), an arrestee's arrest is reverted, a guard loses its Captor and package lock, any Scene still
    playing with them in it ends, and their AI is back on. Every step only acts on what it finds, so it's safe on any mix
    of leftovers and on an actor with nothing left at all.

    This is the manual way out for real gameplay (MCM Check Arrestee / Check Prisoner) and testing (F4), and what the
    tests' teardown uses so a deleted test actor never leaves items in a shared prison container.

    Returns what was done, for a message or a log line ("" when there was nothing to do).
/;
string function ResetActor(Actor akActor) global
    if (!akActor)
        return ""
    endif

    RPB_Arrest arrest = RPB_API.GetArrest()
    RPB_PrisonManager prisonManager = RPB_API.GetPrisonManager()
    RPB_SceneManager sceneManager = RPB_API.GetSceneManager()
    string done = ""

    ; Not in prison yet: cancelled, not released (a release outside prison counted all game time as time jailed)
    RPB_Prison pendingPrison = prisonManager.FindPrisonByPrisoner(akActor)
    if (pendingPrison)
        RPB_Prisoner pendingPrisoner = pendingPrison.Prisoners.AtKey(akActor)
        if (pendingPrisoner && !pendingPrisoner.IsImprisoned)
            done += RPB_Recovery.CancelArrest(akActor, "the actor is being reset")
        endif
    endif

    RPB_Recovery.__Step(akActor, "ResetActor: pending arrest cancel done")
    ; A Scene still playing with them in it would keep driving them (and its guard) after everything below
    if (sceneManager.EndSceneWithActor(akActor, "the actor is being reset"))
        done += "Scene ended; "
    endif

    RPB_Recovery.__Step(akActor, "ResetActor: Scenes done")
    ; Prisoner: released in place, the same release as the prison's own minus the move (this also clears a leftover arrest)
    RPB_Prison prison = prisonManager.FindPrisonByPrisoner(akActor)
    RPB_Prisoner prisonerRef = none
    if (prison)
        prisonerRef = prison.Prisoners.AtKey(akActor)
    endif

if (prisonerRef)
        prison.ReleaseInPlace(prisonerRef)
    done += "released from " + prison.Name + "; "
    elseif (akActor.HasSpell(RPB_Utility.RPB_PrisonerSpell()))
        akActor.RemoveSpell(RPB_Utility.RPB_PrisonerSpell())
        done += "stray Prisoner effect removed; "
    endif

    RPB_Recovery.__Step(akActor, "ResetActor: prisoner done")
    ; Arrestee: whatever the release didn't already clear. Its Captor goes first, if it's still escorting them.
    RPB_Arrestee arresteeRef = arrest.Arrestees.AtKey(akActor)
    if (arresteeRef)
        RPB_Captor captorRef = arresteeRef.Captor
        if (captorRef && captorRef.Arrestee == akActor)
            Actor guard = captorRef.GetActor()
            captorRef.Destroy()
            RPB_Recovery.__FreeGuard(guard, sceneManager)
            done += "their guard was freed; "
        endif

        arresteeRef.RevertArrest()
        done += "arrest reverted; "
    elseif (akActor.HasSpell(RPB_Utility.RPB_ArresteeSpell()))
        akActor.RemoveSpell(RPB_Utility.RPB_ArresteeSpell())
        done += "stray Arrestee effect removed; "
    endif

    RPB_Recovery.__Step(akActor, "ResetActor: arrestee done")
    ; A guard: its own Captor and a package lock left on it
    RPB_Captor ownCaptor = arrest.GetCaptor(akActor)
    if (ownCaptor)
        ownCaptor.Destroy()
        done += "Captor removed; "
    elseif (akActor.HasSpell(RPB_Utility.RPB_CaptorSpell()))
        akActor.RemoveSpell(RPB_Utility.RPB_CaptorSpell())
        done += "stray Captor effect removed; "
    endif
    if (RPB_Recovery.__FreeGuard(akActor, sceneManager))
        done += "package lock removed; "
    endif

    RPB_Recovery.__Step(akActor, "ResetActor: captor done")
    ; A pending arrest holds its arrestee with SetRestrained and SetDontMove (the revert above lifts them, this covers an
    ; arrest state that was already gone)
    akActor.SetRestrained(false)
    akActor.SetDontMove(false)
    sceneManager.UnsetPendingHoldOnActor(akActor) ; the pending hold's package alias, if one is recorded
    RPB_Recovery.__Step(akActor, "ResetActor: holds done")
    if (akActor == Game.GetPlayer())
        int calmed = RPB_Utility.CalmGuardsAgainstPlayer()
        if (calmed > 0)
            done += calmed + " guard(s) calmed; "
        endif
        ; A Reset always hands control back: a player left locked by an arrest (AI-driven, movement and menus off)
        ; with no arrest state left got "nothing to reset" and stayed stuck
        RPB_Utility.ReleaseAI(true)
    endif
    if (RPB_Utility.RemoveCuffs(akActor) > 0)
        done += "cuffs removed; "
    endif
    ; A pose left over from an arrest Scene (a looping idle), even when there was no arrest state left to reset
    Debug.SendAnimationEvent(akActor, "IdleForceDefaultState")
    akActor.EnableAI(true)
    akActor.EvaluatePackage()

    RPB_Utility.Debug("Recovery::ResetActor", akActor + ": " + RPB_Utility.string_if(done == "", "nothing to reset", done))
    return done
endFunction

;/
    Cancels @akActor's arrest: they're free, as if it never happened. For an arrest that can't go on and has nobody to
    take it over - its guard died, or a fight broke out before the cuffs went on. Their Scenes end without their end
    events, the arrest is reverted (hold lifted, uncuffed, bounty back), a prisoner not yet in prison is cancelled without
    a release (Prison.CancelImprisonment), their guard is freed, and their hostility comes back at once, so guards react to
    them again instead of ignoring them. An actor already imprisoned is left alone (that's a release, not a cancel).
    @abReturnBelongings false: a stripped prisoner's things stay in the belongings chest (nobody left to hand them over).

    Returns what was done ("" when there was nothing to do).
/;
string function CancelArrest(Actor akActor, string asReason, bool abReturnBelongings = true) global
    if (!akActor)
        return ""
    endif

    RPB_Arrest arrest = RPB_API.GetArrest()
    RPB_PrisonManager prisonManager = RPB_API.GetPrisonManager()
    RPB_SceneManager sceneManager = RPB_API.GetSceneManager()

    RPB_Prison prison = prisonManager.FindPrisonByPrisoner(akActor)
    RPB_Prisoner prisonerRef = none
    if (prison)
        prisonerRef = prison.Prisoners.AtKey(akActor)
    endif
    if (prisonerRef && prisonerRef.IsImprisoned)
        RPB_Utility.Info("Not cancelling the arrest of " + akActor + " (" + asReason + "): already imprisoned")
        return ""
    endif

    string done = ""
    ; First: the snapshot lives in the actor's "Jail" storage, which cancelling the prisoner below wipes (a freed bandit
    ; stayed neutral, and guards ignored it)
    if (RPB_Utility.RestoreNeutralizedHostility(akActor) > 0)
        done += "hostility restored; "
    endif

    bool sceneStopped = sceneManager.EndSceneWithActor(akActor, asReason)
    if (sceneStopped)
        done += "Scene ended; "
    endif
    RPB_Recovery.__Step(akActor, "CancelArrest: hostility and Scenes done")
    ; Freeze experiment E: the kept guard's probe series starts right at the Scene stop (before experiment C's wait, if on)
    bool probeSeriesSent = false
    if (sceneStopped && RPB_Utility.IsCaptorKeptForTest())
        RPB_Arrestee keptArrestee = arrest.Arrestees.AtKey(akActor)
        Actor keptGuard = none
        if (keptArrestee)
            keptGuard = keptArrestee.GetCaptorActor()
        endif
        if (keptGuard)
            int series = ModEvent.Create("RPB_TestProbeSeries")
            if (series)
                ModEvent.PushForm(series, keptGuard)
                ModEvent.PushFloat(series, Utility.GetCurrentRealTime())
                ModEvent.Send(series)
                probeSeriesSent = true
            endif
        endif
    endif
    bool imprisonmentCancelled = false
    if (prisonerRef && RPB_Utility.IsImprisonmentCancelFirstForTest())
        ; Freeze experiment G3: the imprisonment cancelled now, before the gap below (the block after skips it then)
        prison.CancelImprisonment(prisonerRef, asReason, abReturnBelongings)
        imprisonmentCancelled = true
        done += "imprisonment cancelled (experiment G3); "
        RPB_Recovery.__Step(akActor, "CancelArrest: the imprisonment cancelled right after the Scene stop (experiment G3)")
    endif
    if (RPB_Utility.IsRevertFirstForTest())
        ; Freeze experiment G2: the arrest reverted now (the uncuff, the Arrestee effect), before the gap below. The probe
        ; series above already has the guard; with the arrestee gone the block below skips his release (E keeps him)
        RPB_Arrestee earlyArrestee = arrest.Arrestees.AtKey(akActor)
        if (earlyArrestee)
            earlyArrestee.RevertArrest()
            done += "arrest reverted (experiment G2); "
        endif
        RPB_Recovery.__Step(akActor, "CancelArrest: the arrest reverted right after the Scene stop (experiment G2)")
    endif
    if (RPB_Utility.IsAIFlipFirstForTest())
        ; Freeze experiment G1: the player's AI side of the revert now, before the gap below (the rest after it)
        if (prisonerRef)
            prisonerRef.StopEscortAssist()
        endif
        if (akActor == Game.GetPlayer())
            RPB_Utility.ReleaseAI(true)
        endif
        RPB_Recovery.__Step(akActor, "CancelArrest: the escort assist stopped and the AI released right after the Scene stop (experiment G1)")
    endif
    if (RPB_Utility.IsSceneEndSpacedForTest())
        ; Freeze experiment C: the Scene's end settles on the guard before the rest. With E too (experiment F), 10s: the
        ; Scene stop alone, the player's arrest not reverted yet and the Captor on, under the 0.5s probes
        float spacing = 3.0
        if (RPB_Utility.IsCaptorKeptForTest())
            spacing = 10.0
        endif
        Utility.Wait(spacing)
        RPB_Recovery.__Step(akActor, "CancelArrest: " + (spacing as int) + "s after the Scene end (experiment C/F)")
    endif

    RPB_Arrestee arresteeRef = arrest.Arrestees.AtKey(akActor)
    RPB_Recovery.__Step(akActor, "CancelArrest: arrestee looked up (" + arresteeRef + ")")
    if (arresteeRef)
        ; The guard's side (his Captor, his package lock) on its own stack (Arrest.ReleaseCaptorOf): looking the Captor up
        ; calls into him, and a frozen guard held this cancel there (148's teardown: the player left cuffed). The guard is
        ; read from my storage, which doesn't call him.
        Actor guard = arresteeRef.GetCaptorActor()
        ; A guard froze with his Captor still on, right after his Scene was stopped here (round 102): probes from now,
        ; so a freeze in that window is reported and marked (the teardown then leaves him alone instead of hanging on him)
        if (guard && sceneStopped)
            RPB_Utility.ProbeGuardAfterBurst(guard, "his Scene stopped")
        endif
        if (guard && RPB_Utility.IsCaptorKeptForTest())
            ; Freeze experiment E: his Captor stays on (the test's teardown takes it off later), probed every 0.5s (the
            ; series sent at the Scene stop above; here only if there was no Scene to stop)
            if (!probeSeriesSent)
                int lateSeries = ModEvent.Create("RPB_TestProbeSeries")
                if (lateSeries)
                    ModEvent.PushForm(lateSeries, guard)
                    ModEvent.PushFloat(lateSeries, Utility.GetCurrentRealTime())
                    ModEvent.Send(lateSeries)
                endif
            endif
            done += "guard kept (experiment E); "
            RPB_Recovery.__Step(akActor, "CancelArrest: the Captor of " + guard + " kept on, probed every 0.5s (experiment E)")
        elseif (guard && RPB_Utility.IsReleaseOnPackageChangeForTest())
            ; Freeze experiment D: his Captor releases him on his package change (RPB_Captor.OnPackageChange), a one-shot
            ; backstop if none comes
            RPB_StorageVars.SetFormOnReference("Release Pending", guard, akActor, "Captor")
            int backstop = ModEvent.Create("RPB_ReleaseCaptorBackstop")
            if (backstop)
                ModEvent.PushForm(backstop, guard)
                ModEvent.PushForm(backstop, akActor)
                ModEvent.PushFloat(backstop, 5.0)
                ModEvent.Send(backstop)
            endif
            done += "guard release pending; "
            RPB_Recovery.__Step(akActor, "CancelArrest: release of " + guard + " pending on his package change (experiment D)")
        elseif (guard)
            int handle = ModEvent.Create("RPB_ReleaseCaptor")
            if (handle)
                ModEvent.PushForm(handle, guard)
                ModEvent.PushForm(handle, akActor)
                ModEvent.PushBool(handle, true)
                ModEvent.Send(handle)
                done += "guard release sent; "
            endif
        endif
        RPB_Recovery.__Step(akActor, "CancelArrest: reverting the arrest")
        arresteeRef.RevertArrest()
        done += "arrest reverted; "
    endif

    RPB_Recovery.__Step(akActor, "CancelArrest: captor and arrest done")

    if (prisonerRef && !imprisonmentCancelled)
        prison.CancelImprisonment(prisonerRef, asReason, abReturnBelongings)
        done += "imprisonment cancelled; "
    endif
    RPB_Recovery.__Step(akActor, "CancelArrest: imprisonment done")

    akActor.SetRestrained(false)
    akActor.SetDontMove(false)
    sceneManager.UnsetPendingHoldOnActor(akActor)
    if (RPB_Utility.RemoveCuffs(akActor) > 0)
        done += "cuffs removed; "
    endif
    ; The confrontation's pose ("Hands Behind Back" is a looping idle) outlives the Scene ended above: a fight before the
    ; cuffs left the player holding it, free to go but stuck in the pose
    Debug.SendAnimationEvent(akActor, "IdleForceDefaultState")
    RPB_Recovery.__Step(akActor, "CancelArrest: holds and cuffs done")
    if (akActor == Game.GetPlayer())
        RPB_Utility.ReleaseAI(true)
        ; A surrender keeps the forced arrest dialogue off until BeginArrest's end: an arrest cancelled before that would
        ; leave it off for good
        RPB_Arrest.EnableForcedArrestDialogue()
    else
        akActor.EnableAI(true)
    endif
    akActor.EvaluatePackage()
    RPB_Recovery.__Step(akActor, "CancelArrest: AI and controls released")

    RPB_Utility.Info("Arrest of " + akActor.GetDisplayName() + " " + akActor + " cancelled (" + asReason + "): " + RPB_Utility.string_if(done == "", "nothing left to undo", done))
    return done
endFunction

; A step mark (DEBUG only, built only then): a reset that never finished (126's teardown) left no trace of where it stopped
function __Step(Actor akActor, string asStep) global
    if (RPB_Utility.IsDebuggingEnabled())
        RPB_Utility.Debug("Recovery", akActor + ": " + asStep)
    endif
endFunction

; Removes a package lock left on @akGuard. Only when one is recorded: UnsetPackageLockOnActor() on an actor without one
; resolves alias id 0, which is one of the Scene aliases, and would unbind it.
bool function __FreeGuard(Actor akGuard, RPB_SceneManager apSceneManager) global
    if (!akGuard || !RPB_StorageVars.GetIntOnReference("Package Lock", akGuard))
        return false
    endif

    apSceneManager.UnsetPackageLockOnActor(akGuard)
    if (!akGuard.IsDead()) ; nothing to evaluate on a corpse (the handover of a dead guard hung around here once)
        akGuard.EvaluatePackage()
    endif
    return true
endFunction
