-- Function to find a track by name
function findTrackByName(name)
    local trackCount = reaper.CountTracks(0)
    for i = 0, trackCount - 1 do
        local track = reaper.GetTrack(0, i)
        if track then
            local _, trackName = reaper.GetTrackName(track, "")
            if string.find(trackName:lower(), name:lower(), 1, true) then
                return track
            end
        end
    end
    return nil
end

-- Function to reroute track outputs and disable master send
function rerouteOutputs()
    local stemTracks = {
        "GTR_STEM",
        "BASS_STEM",
        "DRUMS_STEM",
        "PERCS_STEM",
        "KEYS_STEM",
        "SYNTH_STEM",
        "STRINGS_STEM",
        "BRASS_STEM",
        "WW_STEM",
        "VOICE_STEM",
        "SFX_STEM"
    }

    for _, stemName in ipairs(stemTracks) do
        local pattern = stemName:lower():gsub("_stem", "")
        for i = 0, reaper.CountTracks(0) - 1 do
            local track = reaper.GetTrack(0, i)
            if track then
                local _, name = reaper.GetTrackName(track, "")
                if string.find(name:lower(), pattern, 1, true) then
                    if string.find(name:lower(), "_stem", 1, true) then
                        -- If it's a *_STEM track, skip disabling master send
                        goto continue
                    else
                        -- Disable master send
                        reaper.SetMediaTrackInfo_Value(track, "B_MAINSEND", 0)
                    end
                    -- Check if there's already a send to the STEM track
                    local stemTrack = findTrackByName(stemName)
                    local sendExists = false
                    if stemTrack then
                        local sendCount = reaper.GetTrackNumSends(track, 0)
                        for j = 0, sendCount - 1 do
                            local destTrack = reaper.BR_GetMediaTrackSendInfo_Track(track, 0, j, 1)
                            if destTrack == stemTrack then
                                sendExists = true
                                break
                            end
                        end
                        if not sendExists then
                            -- Add send to STEM track
                            reaper.CreateTrackSend(track, stemTrack)
                        end
                    end
                end
            end
            ::continue::
        end
    end
end

-- Function to run on each loop iteration
function main()
    rerouteOutputs()
    reaper.defer(main)
end

-- Start the script
main()

