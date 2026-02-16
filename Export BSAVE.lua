-- structure cribbed from https://github.com/boombuler/aseprite-gbexport/blob/master/GameboyExport.lua
local sprite = app.activeSprite

if sprite == nil then
    app.alert("No active sprite")
    return
end

if sprite.colorMode ~= ColorMode.INDEXED then
    app.alert("Sprite must have indexed color")
    return
end

local dlg = Dialog()
dlg:file{ id="exportFile",
          label="File",
          title="BSAVE Export",
          open=false,
          save=true,
          filetypes={"bin" }}

dlg:check{ id="pixelDoubled",
           label="Double pixels horizontally",
           text="",
           selected=false }
          
dlg:button{ id="ok", text="OK" }
dlg:button{ id="cancel", text="Cancel" }
dlg:show()

local data = dlg.data

if not data.pixelDoubled and (sprite.width & 1) == 1 then
    app.alert("Warning: sprite width is an odd value")
end

if data.ok then
    local f = io.open(data.exportFile, "wb")
    io.output(f)

    local frame = app.activeFrame
    if frame == nil then frame = 1 end
    
    local img = Image(sprite.spec)
    img:drawSprite(sprite, frame)
    
    local bytes = {}
    table.insert(bytes, 0xFD) -- magic byte
    table.insert(bytes, 0x9999 & 0xFF) -- segment, always 0x9999
    table.insert(bytes, 0x9999 >> 8)
    table.insert(bytes, 0) -- offset, always 0
    table.insert(bytes, 0)
    
    local width = sprite.width
    if data.pixelDoubled then
        width = width * 2
    end
    
    local length = width * sprite.height + 4 -- 4 for PUT header width/height
    table.insert(bytes, length & 0xFF) -- length in bytes
    table.insert(bytes, length >> 8)
    
    local bitWidth = width * 8
    table.insert(bytes, bitWidth & 0xFF) -- width in bits
    table.insert(bytes, bitWidth >> 8)
    table.insert(bytes, sprite.height & 0xFF) -- height in bits
    table.insert(bytes, sprite.height >> 8)

    if data.pixelDoubled then
        for y = 0, sprite.height - 1 do
            for x = 0, sprite.width - 1 do
                local pixel = img:getPixel(x, y)
                table.insert(bytes, pixel & 0xFF)
                table.insert(bytes, pixel & 0xFF)
            end
        end
    else
        for y = 0, sprite.height - 1 do
            for x = 0, sprite.width - 1 do
                local pixel = img:getPixel(x, y)
                table.insert(bytes, pixel & 0xFF)
            end
        end
    end

    io.write(string.char(table.unpack(bytes)))
    io.close(f)
end