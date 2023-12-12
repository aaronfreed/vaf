# vasara
update of Hopper, Ares Ex Machina, treellama, and Irons’ texturing utility for Marathon Aleph One
----------------------------------------------------------------
**Vasara 2.0b1**
by **Hopper**, **Ares Ex Machina**, **Aaron Freed**, **CryoS**, and **Solra Bizna**
from work by **Jon Irons** and **Gregory Smith**

----------------------------------------------------------------
WIP notes by Aaron (see below for original readme):

- I’m in the middle of redoing the grid interface *again*. I started out just wanting to add a “centred” option (useful if you drew an entire map off-grid, but have a bunch of rectangles whose points align to a *different* grid – this applies to a disturbingly large number of levels in *Where Monsters Are in Dreams* – or else you recentered a map in Forge and it didn’t recenter it to the grid), but I’m now planning to have a “negative alignment” option that will align walls to the bottom and/or right (it’ll probably treat floors and ceilings normally).
- “Centred” mostly works, but it doesn’t yet centre sides vertically, because that’s horrendously complicated to implement.
- I’m also planning to add separate “x” and “y” snap options, since there are numerous cases where mapmakers might want to align one but not the other, or might want to use one snap vertically and another horizontally
- I’ve fixed the Lua error spam for lights > 55, but haven’t figured out how to get them to preview correctly. You can currently select lights 0-97 in the main palette, and even if you have both “apply light” and “apply texture” selected with lights > 97, it won’t spam errors. I may figure out a way to reduce the size of each light if there are more than 98 so that more will fit in the selector (but really, what are you doing with that many lights? I’ve only ever made a map with that many lights to test Vasara)
- You can now select “apply texture mode” separately from “apply texture” - if you have it selected by itself, it’ll apply different transfer modes to existing textures without adjusting their textures. By contrast, if you have “apply texture” selected but not “apply texture mode”, it’ll preserve existing transfer modes while changing the textures. The wild card is landscapes, which often override existing transfer modes. None of this is reflected sensibly in the main interface yet
- I don’t know what sort of preview to do for the 2x or 4x transfer modes
- This will flat-out break if you aren’t using at least Aleph One 1.7, and I don’t care
- “Realign when retexturing” is a forthcoming option that will preserve the old behavior of Vasara of realigning textures to (0,0) when you change a texture. I currently have it disabled, since it’s possible to realign textures to (0,0) manually with it disabled, while it’s *not* possible to preserve existing texture alignment with it *enabled*, but sometimes having it enabled is useful behavior
- The border for the selected texture on the texture palette broke and I haven’t figured out why. this has been the most annoying thing to debug
- I think I understand the math needed to fix alignment of transparent textures on the reverse side; I just haven’t figured out how to get Vasara to do it correctly
- Vasara’s code is very, very dense and very, very sparsely documented, so this has been a slow project and will probably continue to be slow, but I hope to get it finished soon™
- Most of the updates are mine; a few are CryoS or Solra’s work

----------------------------------------------------------------

------------
Vasara 1.0.3
------------
by Hopper and Ares Ex Machina
from work by Irons and Smith

----------------------------------------------------------------
**DESCRIPTION:**

Vasara is a Lua script and dedicated HUD for use in texturing Aleph One maps. The HUD lists the keyboard shortcts for easy reference, and features a GUI-style interface for choosing textures and options.

To get the most out of Vasara, be sure to turn on "**Use Mouse**" and "**Overlay Map**" in your preferences.

----------------------------------------------------------------
**INSTALLATION:**

- Drag the downloaded .zip file, or the unzipped "Vasara" folder, into the "**Plugins**" folder inside your *Marathon Infinity* or custom scenario folder. (Create a "**Plugins**" folder if you don't already have one.)
- Launch **Aleph One**, and go to "**Preferences**", then "**Environment**", then **"Plugins**" to enable or disable Vasara.

***(EDITORIAL NOTE:** If you’re using **Aleph One** 1.7 or later - and you should be - then **Plugins** isn’t found under **Environment** but is instead its own button. But then, you can also just launch **Vasara** from within **Weland,** and you should. See Weland’s readme for basic instructions or https://aaronfreed.github.io/mapmaking.html#welandsetup for a more detailed setup guide. **-Aaron)***

**IMPORTANT:** other plugins can interfere with Vasara. You should be all right as long as anything listed after Vasara in your plugins list is turned off. If you have problems, try turning off all plugins except Vasara.

----------------------------------------------------------------
**GETTING STARTED:**

Vasara has four modes. The tabs at the top left of the screen show which mode you're in, and the area to the right shows what your keys do. For some commands, you need to hold the **Microphone** key down and then press the other key shown.

***(EDITORIAL NOTE:** The Microphone key is now referred to as the **Aux Trigger** key. **-Aaron)***

Vasara will feel most natural if you have "**Use Mouse**" turned on, and have the primary trigger mapped to your left mouse button. That way, the most common actions can be done by pointing and clicking.

1. You start in **Visual Mode**, where you apply lights and textures to your level. Click to "paint", and hold the trigger down to drag textures into position.

2. Press the **Microphone** key to switch to **Choose Textures mode**. Click a texture to select it for use in **Visual Mode**. Click on the buttons at the bottom to switch to a different collection. Or, use the key shortcuts to switch textures and collections.

3. Press the **Action** key to switch to **Options** mode. You can toggle lesser-used settings here, like **snap-to-grid** or **transfer modes**.

4. Press the **Map** key to switch to Teleport mode. Point at a polygon and click to teleport there. With the key shortcuts, you can cycle through polygons to reach faraway areas. The currently selected polygon is highlighted in first-person view and on the overhead map.

You can get back to **Visual Mode** from any other mode by hitting the secondary trigger (the "grenade" button). Always check the top of the screen to see what your options are.

To save your work, press the "Chat/Console" key (default is backslash: \ ) and then type:

  .save level my-fabulous-level.sceA

The period at the start is important! You can replace "my-fabulous-level.sceA" with whatever filename you like. Your level will be saved in Aleph One's standard location for your platform; see:

  https://github.com/Aleph-One-Marathon/alephone/wiki/File-Locations

----------------------------------------------------------------
**TIPS AND TRICKS:**

Vasara's functionality is based on Visual Mode.lua, which in turn is based on Forge's Visual Mode. If you're confused about what something in Vasara does, check the Forge manual or existing discussions about VML.

Having trouble navigating menu screens with the mouse? Try the keyboard. Your key bindings for turning and looking up/down will move the cursor. Moving or sidestepping will snap the cursor to the closest item in the pressed direction.

When selecting lights, the clickable area is larger than you might think. You can click on either the number or the square.

For VML veterans, the key combo Mic+Action acts as an Undo/Redo toggle just like in Visual Mode.lua.

Once you're done texturing, you can take screenshots of your level in Vasara. Use teleport, jump and freeze to find a nice vantage point, then press F2 to hide the GUI. Press F9 to take a screenshot and F1 to bring the GUI back.

The two Lua scripts have various preferences at the top. You can change the mouse cursor sensitivity, the color scheme, the collection names, and more. Poke around there if you're interested.

----------------------------------------------------------------
**SCENARIO COMPATIBILITY:**

Out of the box, Vasara only works with scenarios that use the same 5 texture sets and same 4 landscapes as *Marathon Infinity*, since the plugin needs to know the proper shapes collections to use. It mostly works with *Marathon 2* (which is missing the Jjaro set), but there are glitches with the fourth "landscape" since M2 uses that collection for something else.

To use Vasara with additional or moved collections (or to limit M2 to the 3 working landscapes), edit the "walls" and "landscapes" settings at the top of Vasara_Script.lua.

----------------------------------------------------------------
CHANGELOG:

v1.0.3:
* Improved compatibility with Marathon 2

v1.0.2:
* Fix problem where "Revert Changes" did nothing
* Fix problem where control panel settings were reverted
* Fix problem where chip insertion slots were marked as destroyable
* Require Aleph One 1.2, which fixes a bug involving Lua and wires
* Ships as one plugin instead of two

v1.0.1:
* Fix crash when frames are missing for wall texture bitmaps
* Fix crash when a level has no platforms

v1.0:
* First release

----------------------------------------------------------------
SPECIAL THANKS:

TychoVII, Kurinn - For pushing the boundaries of the Lua HUD
Bitstream, Tavmjong Bah - For fonts used in the HUD
dustu - For beta testing
Treellama, Irons - For Visual Mode.lua

----------------------------------------------------------------
CONTACT:

If you have any questions, comments, or bugs to report, you can email Hopper:
- hopper@whpress.com
