# BSAVE For Aseprite
This is a script for Aseprite to save sprites to QBasic's BSAVE format, assuming 8 bits per pixel.

# Installation
Download `Export BSAVE.lua` and place it in `%APPDATA%\Aseprite\scripts` and restart Aseprite if it was already running.

# Using
Use `File > Scripts > Export BSAVE` and select a file then press OK.

# FAQ

**Why do I get a warning that the sprite width is an odd value?** \
The closest match for an 8-bit data type in QBasic is 16-bit integers. If the width of a sprite is odd it won't fit exactly in an array of 16-bit integers.

If you hate this warning, you can comment out the following lines:

```lua
if not data.pixelDoubled and (sprite.width & 1) == 1 then
    app.alert("Warning: sprite width is an odd value")
end
```

**What does the "double pixels horizontally" option do?** \
Each pixel is duplicated across 2 bytes (or one 16-bit integer) which isn't that helpful to most people but I use it for my 160x100 display mode. That mode is MODE 13 but with a tweak to the VGA registers that draws each logical scanline twice on screen, resulting in 320x100, then I double each pixel to effectively get 160x100. If you're not doing that, you'll want to leave this one off probably.

A nice benefit of this mode is that it splits the 320x200 VGA memory into effectively two pages. And because QBasic still thinks the screen is 320x200 all the built-in drawing functions will still work (just add 100 to the Y coordinate for the 2nd page) and you can "page flip" by setting the VGA's start address:

```qbasic
SUB PageFlip (page%)
    page% = (page% + 1) AND 1
  
    ' note: address in 32-bit words
    pghi% = page% * &H1F
    pglo% = page% * &H40

    ' set VGA start address hi register
    OUT &H3D4, &HC
    OUT &H3D5, pghi%
    ' set VGA start address low register
    OUT &H3D4, &HD
    OUT &H3D5, pglo%
END SUB
```
