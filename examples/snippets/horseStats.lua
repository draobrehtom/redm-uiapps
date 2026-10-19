-- Ref: https://github.com/Rexshack-RedM/rsg-horses/blob/e5b825606bda5b54b8f76e499b0f860e0b87f8b5/client/horseinfo.lua#L196

---Launches the horse details UI app if the entity is a horse
---@param iEntity integer ID of the horse entity
---@param hModel integer Model hash of the horse entity
local function ShowHorseDetailsOnCard(iEntity, hModel)
    local iInfoBox = DatabindingAddDataContainerFromPath('', 'InfoBox') -- Add the info box container
    m_InfoCardData.tDataBinding.iInfoBox = iInfoBox -- Save data for the info box container for future use. This data is deleted on cleanup.

    DatabindingAddDataString(iInfoBox, 'itemLabel', GetStringFromHashKey(GetDiscoverableNameHashAndTypeForEntity(iEntity))) -- Sets the title of the card.

    DatabindingAddDataBool(iInfoBox, 'showHorseStats', true) -- Shows horse stats.
    DatabindingAddDataBool(iInfoBox, 'isVisible', true) -- Makes info box visible.

    DatabindingAddDataString(iInfoBox, 'HorseCoat', GetHorseCoatFromModel(hModel)) -- Sets the horse coat text.

    -- Set the horse speed value
    DatabindingAddDataInt(iInfoBox, 'HorseSpeedValue', GetAttributeBaseRank(iEntity, 5) + 1)
    DatabindingAddDataInt(iInfoBox, 'HorseSpeedMinValue', 0)
    DatabindingAddDataInt(iInfoBox, 'HorseSpeedMaxValue', 10)

    local iBaseRank = GetAttributeBaseRank(iEntity, 5) + 1
    local iBonusRank = GetAttributeBonusRank(iEntity, 5)
    local iStatValue = ClampValue( iBaseRank + iBonusRank, 0, 10)

    DatabindingAddDataInt(iInfoBox, 'HorseSpeedEquipmentValue', iStatValue)
    DatabindingAddDataInt(iInfoBox, 'HorseSpeedEquipmentMinValue', 0)
    DatabindingAddDataInt(iInfoBox, 'HorseSpeedEquipmentMaxValue', 10)

    DatabindingAddDataInt(iInfoBox, 'HorseSpeedCapacityValue', ClampValue(iBaseRank + 3, 0, 10))
    DatabindingAddDataInt(iInfoBox, 'HorseSpeedCapacityMinValue', 0)
    DatabindingAddDataInt(iInfoBox, 'HorseSpeedCapacityMaxValue', 10)

    -- Set the horse acceleration value
    iBaseRank = GetAttributeBaseRank(iEntity, 6) + 1

    DatabindingAddDataInt(iInfoBox, 'HorseAccValue', iBaseRank)
    DatabindingAddDataInt(iInfoBox, 'HorseAccMinValue', 0)
    DatabindingAddDataInt(iInfoBox, 'HorseAccMaxValue', 10)

    iBonusRank = GetAttributeBonusRank(iEntity, 6)
    iStatValue = ClampValue(iBaseRank + iBonusRank, 0, 10)

    DatabindingAddDataInt(iInfoBox, 'HorseAccEquipmentValue', iStatValue)
    DatabindingAddDataInt(iInfoBox, 'HorseAccEquipmentMinValue', 0)
    DatabindingAddDataInt(iInfoBox, 'HorseAccEquipmentMaxValue', 10)

    DatabindingAddDataInt(iInfoBox, 'HorseAccCapacityValue', ClampValue(iBaseRank+2, 0, 10))
    DatabindingAddDataInt(iInfoBox, 'HorseAccCapacityMinValue', 0)
    DatabindingAddDataInt(iInfoBox, 'HorseAccCapacityMaxValue', 10)

    -- Set the horse handling value
    local iHandling = GetAttributeRank(iEntity, 4)

    if iHandling == 0 or iHandling == 1 then
        iHandling = 0
    elseif iHandling == 2 or iHandling == 3 then
        iHandling = 1
    elseif iHandling == 4 or iHandling == 5 then
        iHandling = 2
    elseif iHandling == 6 or iHandling == 7 or iHandling == 8 or iHandling == 9 then
        iHandling = 3
    end

    local sHandlingTextLabel = 'HORSE_HANDLING_HEAVY'

    if iHandling == 1 then
        sHandlingTextLabel = 'HORSE_HANDLING_STANDARD'
    elseif iHandling == 2 then
        sHandlingTextLabel = 'HORSE_HANDLING_RACE'
    elseif iHandling == 3 then
        sHandlingTextLabel = 'HORSE_HANDLING_ELITE'
    end

    DatabindingAddDataString(iInfoBox, 'HorseHandling', sHandlingTextLabel)
end
