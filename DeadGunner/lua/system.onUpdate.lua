arkTime = system.getArkTime()

if bootTimer >= 2 then
    generateHTML()
end

inSZ = construct.isInPvPZone() == 0
SZD = construct.getDistanceToSafeZone()
bgColor = bottomHUDFillColorSZ 
fontColor = textColorSZ
lineColor = bottomHUDLineColorSZ
if not inSZ then 
    lineColor = bottomHUDLineColorPVP
    bgColor = bottomHUDFillColorPVP
    fontColor = textColorPVP
end

--if radarStart and radar_1 then
--    local _data = updateRadar(radarFilter)
--    system.updateData(radarDataID, _data)
--end

if radar_1 and cr == nil then
    cr = coroutine.create(updateRadar)
    --data = radar_1.getWidgetData()
elseif cr ~= nil then
    if coroutine.status(cr) ~= "dead" and coroutine.status(cr) == "suspended" then
        coroutine.resume(cr,radarFilter)
    elseif coroutine.status(cr) == "dead" then
        cr = nil
        system.updateData(radarDataID, radarWidgetData)
        if not cr_time then
            cr_time = system.getArkTime()
        else
            cr_delta = system.getArkTime() - cr_time
            cr_time = system.getArkTime()
            if (cr_delta > 1 and radarOverload) or showAlerts then
                warnings['radar_delta'] = 'svgCritical'
            else
                warnings['radar_delta'] = nil
            end
        end
    end
end

-- Shield Updates --
if shield_1 then
    local srp = shield_1.getResistancesPool()
    local csr = shield_1.getResistances()
    local rcd = shield_1.getResistancesCooldown()
    if shield_1.getStressRatioRaw()[1] == 0 and shield_1.getStressRatioRaw()[2] == 0 and shield_1.getStressRatioRaw()[3] == 0 and shield_1.getStressRatioRaw()[4] == 0 then
        dmgTick = 0
        srp = srp / 4
        if (csr[1] == srp and csr[2] == srp and csr[3] == srp and csr[4] == srp) or rcd ~= 0 then
            --No change
        else
            shield_1.setResistances(srp,srp,srp,srp)
        end
    elseif math.abs(arkTime - dmgTick) >= initialResistWait then
        local srr = shield_1.getStressRatioRaw()
        if (csr[1] == (srp*srr[1]) and csr[2] == (srp*srr[2]) and csr[3] == (srp*srr[3]) and csr[4] == (srp*srr[4])) or rcd ~= 0 then -- If ratio hasn't change, or timer is not up, don't waste the resistance change timer.
            --No change
        else
            shield_1.setResistances(srp*srr[1],srp*srr[2],srp*srr[3],srp*srr[4])
        end
    elseif dmgTick == 0 then
        dmgTick = arkTime
    end

    local hp = shield_1.getShieldHitpoints()
    if shield_1.isVenting() == 0 and hp == 0 and autoVent then
        shield_1.startVenting()
    elseif shield_1.isActive() == 0 and shield_1.isVenting() == 0 then 
        shield_1.activate()
    end

    local coreHP = 0
    if core_1 then coreHP = (core_1.getMaxCoreStress()-core_1.getCoreStress())/core_1.getMaxCoreStress() end
end
-- End Shield Updates --