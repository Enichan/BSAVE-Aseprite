# BSAVE For Aseprite
This is a script for Aseprite to save sprites to QBasic's BSAVE format, assuming 8 bits per pixel.

# Installation
Download `Export BSAVE.lua` and place it in `%APPDATA%\Aseprite\scripts` and restart Aseprite if it was already running.

# Using
Use `File > Scripts > Export BSAVE` and select a file then press OK.

# FAQ

**Why do I get a warning that the sprite width is an odd value?**
The closest match for an 8-bit data type in QBasic is 16-bit integers. If the width of a sprite is odd it won't fit exactly in an array of 16-bit integers.

If you hate this warning, you can comment out the following lines:

```lua
if not data.pixelDoubled and (sprite.width & 1) == 1 then
    app.alert("Warning: sprite width is an odd value")
end
```

**What does the "double pixels horizontally" option do?**
Each pixel is duplicated across 2 bytes (or one 16-bit integer) which isn't that helpful to most people but I use it for my 160x100 display mode. That mode is MODE 13 but with a tweak to the VGA registers that draws each logical scanline twice on screen, resulting in 320x100, then I double each pixel to effectively get 160x100. If you're not doing that, you'll want to leave this one off probably.
