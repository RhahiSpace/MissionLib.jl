function preload(sp)
    delay(sp.ts, 0.1)
    delay(sp.ts, 1)
    delay(sp.ts, 0.1, "Preload 1")
    delay(sp.ts, 1, "Preload 2")
end

function register_parts(sp::Spacecraft)
    parts = SCH.Parts(sp.ves)
    core = SCH.WithTag(parts, "core")[1] |> CommandModule.ProbeCore
    e1 = SCH.WithTag(parts, "e1")[1] |> Engine.RealEngine
    e2 = SCH.WithTag(parts, "e2")[1] |> Engine.RealEngine
    chute = SCH.WithTag(parts, "chute")[1] |> Parachute.RealChute
    dec1 = SCH.WithTag(parts, "dec")[1] |> Decoupler.RegularDecoupler
    dec2 = SCH.WithTag(parts, "dec")[2] |> Decoupler.RegularDecoupler
    return (core, e1, e2, chute, dec1, dec2)
end

function setup(sp::Spacecraft, con::SubControl)
    put!(con.throttle, 1)
    preload(sp)
    ctrl = SCH.Control(sp.ves)
    if SCH.Throttle(ctrl) ≉ 1
        @error "Throttle check failed"
        error("Throttle check failed")
    end
    return register_parts(sp)
end

function setup_logger(sp::Spacecraft)
    @assert pwd() |> dirname |> basename == "Karman3"
    logger = KerbalRemoteLogger(;
        port=50003,
        timestring=timestring(sp),
        console_loglevel=Base.LogLevel(-1000),
        console_exclude_group=(:ProgressLogging,:time,),
        disk_directory="./run/log",
        data_directory="./run/data",
        data_groups=(:atmospheric,),
    )
    Base.global_logger(logger)
end
