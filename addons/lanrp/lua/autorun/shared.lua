local base_folder = "autorun/"

-- Загружаем ТОЛЬКО свои папки lanrp.
-- Путь "LUA" в GMod общий для всех аддонов, поэтому раньше file.Find("autorun/*")
-- подхватывал чужие файлы (autorun/client/*, autorun/server/*, sh_*.lua из economy,
-- realism gun sway, squad, ragdoll death и т.д.). Движок и так загружает их сам,
-- в итоге они выполнялись дважды, а economy/sv_init.lua - ещё и до economic.lua
-- (ошибка "table index is nil", B_DOWN ещё не определён).
local OwnFolders = {
    "player/",
    "systems/",
    "voice/",
}

local function LoadModuleFolder(modulenm)
    local full_folder = base_folder .. modulenm

    local files, folders = file.Find(full_folder .. "*", "LUA")
    for _, ifolder in ipairs(folders) do
        LoadModuleFolder(modulenm .. ifolder .. "/")
    end

    for _, CL in ipairs(file.Find(full_folder .. "cl_*.lua", "LUA")) do
        if SERVER then AddCSLuaFile(full_folder .. CL) end
        if CLIENT then include(full_folder .. CL) end
    end

    for _, SH in ipairs(file.Find(full_folder .. "sh_*.lua", "LUA")) do
        if SERVER then AddCSLuaFile(full_folder .. SH) end
        include(full_folder .. SH)
    end

    if SERVER then
        for _, SV in ipairs(file.Find(full_folder .. "sv_*.lua", "LUA")) do
            include(full_folder .. SV)
        end
    end
end

for _, folder in ipairs(OwnFolders) do
    LoadModuleFolder(folder)
end
