-- bridge.luau
-- Cek dulu, Arceus X gak punya Drawing kan?
if not Drawing then
    warn("[Bridge] Drawing gak ada, coba load library...")
    
    local ok, lib = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/Bubbajohn1/vamp.drawing/main/main.lua"))()
    end)
    
    if ok and lib then
        Drawing = lib
        print("[Bridge] Drawing berhasil di-inject!")
    else
        warn("[Bridge] Gagal load Drawing, ESP bakal skip.")
    end
else
    print("[Bridge] Drawing udah ada, gak perlu di-inject.")
end
