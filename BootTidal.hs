:set -XOverloadedStrings
:set prompt ""

import Sound.Tidal.Context

import System.IO (hSetEncoding, stdout, utf8)

hSetEncoding stdout utf8

:{
linlin slo shi dlo dhi value =
    let norm = (value - slo) / shi
    in dlo + norm * (dhi - dlo)
:}

:{
let renoise = Target {
        oName="renoise",
        oAddress="127.0.0.1",
        oPort=8000,
        oLatency=0.2,
        oSchedule=Live,
        oWindow=Nothing
        }
    formats = [
        -- send note_on event
        OSC "/renoise/trigger/note_on" $ ArgList [
            ("instrument", Just $ VI (-1)),
            ("track", Just $ VI (-1)),
            ("note", Nothing),
            ("velocity", Just $ VI 127)
            ],

        -- send note_off event (not very useful if you ask me)
        OSC "/renoise/trigger/note_off" $ ArgList [
            ("sound", Just $ VI (-1)),
            ("track", Just $ VI (-1)),
            ("noteOff", Nothing)
            ],

        -- instrument macro controls
        OSC "/renoise/song/instrument/{instrument}/macro1" $ ArgList [("m1", Nothing)],
        OSC "/renoise/song/instrument/{instrument}/macro2" $ ArgList [("m2", Nothing)],
        OSC "/renoise/song/instrument/{instrument}/macro3" $ ArgList [("m3", Nothing)],
        OSC "/renoise/song/instrument/{instrument}/macro4" $ ArgList [("m4", Nothing)],
        OSC "/renoise/song/instrument/{instrument}/macro5" $ ArgList [("m5", Nothing)],
        OSC "/renoise/song/instrument/{instrument}/macro6" $ ArgList [("m6", Nothing)],
        OSC "/renoise/song/instrument/{instrument}/macro7" $ ArgList [("m7", Nothing)],
        OSC "/renoise/song/instrument/{instrument}/macro8" $ ArgList [("m8", Nothing)],

        -- set device parameters (effects)
        OSC "/renoise/song/track/{track}/device/{device}/set_parameter_by_name" $ ArgList [
            ("param", Nothing),
            ("value", Nothing)
            ]
        ]
    -- use t1 .. t8 to select the track
    track = pI "track"
    -- sound to select an instrument
    sound = pI "instrument"
    s = sound
    -- triggers note_on event
    note = pI "note"
    n = note
    -- triggers note_off event
    noteOff = pI "noteOff"
    -- gain controls velocity, remapping from [0 1] to [0 127]
    gain = pF "velocity" . linlin 0 1 0 127
    -- instument macros
    m1 = pF "m1"
    m2 = pF "m2"
    m3 = pF "m3"
    m4 = pF "m4"
    m5 = pF "m5"
    m6 = pF "m6"
    m7 = pF "m7"
    m8 = pF "m8"
    -- device params
    device = pI "device"
    dev = device
    param = pS "param"
    par = param
    value = pF "value"
    val = value
    -- redefining octave. use it with operator |+ instead of #
    octave = \p -> note (p |* 12)
    oscmap = [(renoise, formats)]
:}

tidal <- startStream defaultConfig oscmap

:{
let only = (hush >>)
    p = streamReplace tidal
    hush = streamHush tidal
    panic = do hush
               once $ sound "superpanic"
    list = streamList tidal
    mute = streamMute tidal
    unmute = streamUnmute tidal
    unmuteAll = streamUnmuteAll tidal
    solo = streamSolo tidal
    unsolo = streamUnsolo tidal
    once = streamOnce tidal
    first = streamFirst tidal
    asap = once
    nudgeAll = streamNudgeAll tidal
    all = streamAll tidal
    resetCycles = streamResetCycles tidal
    setcps = asap . cps
    xfade i = transition tidal True (Sound.Tidal.Transition.xfadeIn 4) i
    xfadeIn i t = transition tidal True (Sound.Tidal.Transition.xfadeIn t) i
    histpan i t = transition tidal True (Sound.Tidal.Transition.histpan t) i
    wait i t = transition tidal True (Sound.Tidal.Transition.wait t) i
    waitT i f t = transition tidal True (Sound.Tidal.Transition.waitT f t) i
    jump i = transition tidal True (Sound.Tidal.Transition.jump) i
    jumpIn i t = transition tidal True (Sound.Tidal.Transition.jumpIn t) i
    jumpIn' i t = transition tidal True (Sound.Tidal.Transition.jumpIn' t) i
    jumpMod i t = transition tidal True (Sound.Tidal.Transition.jumpMod t) i
    mortal i lifespan release = transition tidal True (Sound.Tidal.Transition.mortal lifespan release) i
    interpolate i = transition tidal True (Sound.Tidal.Transition.interpolate) i
    interpolateIn i t = transition tidal True (Sound.Tidal.Transition.interpolateIn t) i
    clutch i = transition tidal True (Sound.Tidal.Transition.clutch) i
    clutchIn i t = transition tidal True (Sound.Tidal.Transition.clutchIn t) i
    anticipate i = transition tidal True (Sound.Tidal.Transition.anticipate) i
    anticipateIn i t = transition tidal True (Sound.Tidal.Transition.anticipateIn t) i
    forId i t = transition tidal False (Sound.Tidal.Transition.mortalOverlay t) i
    t1 = p 1 . (|< track 1)
    t2 = p 2 . (|< track 2)
    t3 = p 3 . (|< track 3)
    t4 = p 4 . (|< track 4)
    t5 = p 5 . (|< track 5)
    t6 = p 6 . (|< track 6)
    t7 = p 7 . (|< track 7)
    t8 = p 8 . (|< track 8)
:}

:{
let setI = streamSetI tidal
    setF = streamSetF tidal
    setS = streamSetS tidal
    setR = streamSetR tidal
    setB = streamSetB tidal
:}

:set prompt "tidal> "
:set prompt-cont ""
