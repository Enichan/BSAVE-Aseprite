# BSAVE For Aseprite
This is a script for Aseprite to save sprites to the QBasic BSAVE format, assuming 8 bits per pixel.

# Installation
Download `Export BSAVE.lua` and place it in `%APPDATA%\Aseprite\scripts` and restart Aseprite if it was already running.

# Using
Use `File > Scripts > Export BSAVE` and select a file then press OK.

# FAQ

**Why do I get a warning that the sprite length is an odd value?** \
The closest match for an 8-bit data type in QBasic is 16-bit integers. If the width and height of a sprite are both odd it won't fit exactly in an array of 16-bit integers.

If you hate this warning, you can comment out the following lines:

```lua
if not data.pixelDoubled and (sprite.width & 1) == 1 and (sprite.height & 1) == 1 then
    app.alert("Warning: sprite length is an odd value")
end
```

**What does the "Include image header" option do?** \
Short answer: if this option is on you can use the data after BLOAD with the PUT graphics command to write it to the screen. If in doubt leave this on.

Longer answer: BSAVE's format is for any binary data. The PUT graphics command expects your array to start with 4 bytes, 2 describing the image's width and 2 describing the image's height. When saving an image to the BSAVE format this is usually going to be what you want. However, there may be a reason that you just want the raw binary values that describe the image's pixels without this header so that you can BLOAD them anywhere in memory you want. If you're after such nefarious purposes, unchecking this option will let you do exactly that.

Interesting factoid: because GET and PUT work with different graphics modes the image header actually stores the width of the image in bits, not bytes. Although this export script only supports 8 bits per pixel chunky VGA.

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

If you're interested in this 320x100 video mode, you can set it up like this:

```qbasic
SCREEN 13

' turn off CRTC write protect
OUT &H3D4, &H11
OUT &H3D5, INP(&H3D5) AND &H7F

' enable line doubling
OUT &H3D4, &H9
OUT &H3D5, &H81

' turn on CRTC write protect
OUT &H3D4, &H11
OUT &H3D5, INP(&H3D5) OR &H80
```
