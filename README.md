# Vasara
## a texturing utility for Marathon Aleph One

credits in chronological order:
- **[Visual Mode.lua](https://github.com/treellama/visualmode)** by **[@jonirons](https://github.com/jonirons)** and **[@treellama](https://github.com/treellama)**
- **[Vasara 1.0.3](https://simplici7y.com/items/vasara/)** by **[@Hopper262](https://github.com/Hopper262)** and **Ares Ex Machina**
- **Vasara 2.0b** by **[@aaronfreed](https://github.com/aaronfreed)**, **[@murbruksprodukt](https://github.com/murbruksprodukt)**, and **[@SolraBizna](https://github.com/SolraBizna)**

Hopper also has a **[GitHub repository for Vasara 1.0.2](https://github.com/Hopper262/Vasara)**, but it’s one version behind the Simplici7y release.

----------------------------------------------------------------
## WIP notes by Aaron (see below for original readme):
**Vasara** is a texturing utility for **[Marathon Aleph One](https://alephone.lhowon.org)** 1.7 or later, best used with **[Weland](https://github.com/treellama/weland/releases)** (see [my detailed setup guide](https://aaronfreed.github.io/mapmaking.html#welandsetup) if Weland’s readme proves confusing). The original version hasn’t been updated in years, so I’ve taken it upon myself, with a little help from my friends, to update it for several reasons:
- to take advantage of new Aleph One features
- to add features that it had been sorely lacking for years
- to fix longstanding bugs.

This remains a work in progress, hence its beta status. A more detailed overview:

----------------------------------------------------------------
### NEW FEATURES & PLANNED ADDITIONS:

- I’m almost finished redoing the grid interface.
  - Vasara 1.0.x only offered five grid sizes: 1/2, 1/3, 1/4, 1/5, and 1/8 world units (WU). We’ve bumped this number up to nineteen by adding options for 1, 1/6, 1/10, 1/12, 1/16, 1/20, 1/24, 1/30, 1/32, 1/40, 1/48, 1/60, 1/64, and 1/128 WU. 1/16 WU is now the default selection because it’s what I use by far the most. (See “Notes on Terminology” below for explanations of world units, internal units, and the engine’s space measurements.)
  - The “absolute” option is the vanilla alignment you’re used to from previous versions of Vasara: textures on polygons will be aligned to the map grid, and textures on walls will be aligned to the top-left.
  - In addition, I’ve added three new “relative” options, which can be useful if you drew an entire map off-grid, but have a bunch of rectangles whose points align to a *different* grid (this applies to a disturbingly large number of levels in *Where Monsters Are in Dreams*) or you recentred a map in Forge and it wasn’t recentred on-grid:
    - The “northwest” option treats walls exactly like the “absolute” option does; however, it aligns floors and ceilings to the westernmost X coordinate and the northernmost Y coordinate found within their respective polygons.
    - The “centred” option applies in both directions to floors, ceilings, and walls. I haven’t yet perfected the vertical alignment option for walls, but the horizontal alignment should always work correctly, and floors and ceilings should be aligned to a grid centred precisely within their respective polygons. As of this writing, this is the default setting, but I’m very likely to change it back to “absolute” next time I update Vasara, since the latter is what it was for 7+ years and thus what everyone’s used to.
    - The “southeast” option aligns walls to the right rather than to the left and to the bottom rather than to the top (although its vertical alignment is also not yet perfect). Meanwhile, it aligns floors and ceilings to the easternmost X coordinate and the southernmost Y coordinate within their respective polygons, making it the precise opposite of the “northwest” option.
  - The “X” and “Y” snap options are present because there are numerous cases where mapmakers might want to align one but not the other, or might want to use one alignment option for X and a different one for Y. Separating these options makes those possible (although to get different X and Y snaps, you’ll have to align them separately, and it may help to use the keyboard to do so).
  - If you want to disable the grid, disable both the X and Y snaps. (I could probably be persuaded to make a keyboard shortcut that toggles “grid snapping off” and “snap to X and Y” or that cycles between the different grid snaps.)
  - The preview should now display all grid settings correctly, though bear in mind that it does not yet display the 2x and 4x transfer modes correctly – those will have more snap positions than you’ll see in the preview.
- You can now select “apply texture mode” separately from “apply texture”.
  - If you have “apply texture mode” selected, but not “apply texture”, it’ll apply different transfer modes to existing textures without adjusting their textures, and *vice versa*. (The Romans would’ve pronounced this something like ***wee**-keh **wer**-sah*. There, you can cross off an item on your bingo cards. You’re welcome.)
  - Landscapes are the wild card, as they usually override existing transfer modes. I have yet to work out all the strange behavior this causes.
    - If for some reason you wish to apply a texture from a landscape collection in a transfer mode other than “landscape”, you can apply it to your desired surface, deselect “apply texture”, and then apply a different transfer mode. (You may need to select a different texture before you can do the last of these.) However, bear in mind that textures from landscape collections may behave weirdly in transfer modes besides “landscape”.
  - All of this mostly shows up correctly in visual mode, though the preview currently behaves weirdly when “apply texture” is disabled.
- This version of Vasara lists what you’re looking at in the upper-left corner of visual mode.
  - Floors, ceilings, and lines without associated sides (which occur when you haven’t paved a level before going into visual mode) are labeled as floors, ceilings, or lines. Sides are listed along the lines “1337 (∆0.0420)”, which indicates that you are looking at side 1337 and that it has an ambient delta value of 0.0420. Ambient delta is a rarely-used map element that affects the side’s light intensity; at present, Greg Kirkpatrick, Jason Jones, and I are the only people I’m aware of who have ever used it. See “Notes on Terminology” below for a detailed explanation.
  - If you see an additional side listed to the right of the one in the upper-left, it’s a transparent side. Unfortunately, Vasara currently displays the one furthest from you – I feel the one closest would make the most sense, but I’ve so far been unable to debug this.
  - I haven’t yet had time to begin writing the UI to adjust ambient delta, so for now, to set the ambient delta of side `foo` to `bar`, you can use the following Lua code:
    ```lua
    Sides[foo].ambient_delta = bar
    ```
    - `bar` should almost always be between -1 and 1.
    - Also, be warned that maps that use ambient delta will break if you run them through the Weland copy and paste plugin.
    - I’m not especially confident in my UI ideas (I’ve long held that UI is far too important to be left up to programmers that aren’t UI specialists, which I very decidedly am not). At the moment, I tentatively plan to add an “ambient delta modifier” hotkey that’ll be combined with other keys: one will select which digit to edit, another two will adjust it upwards or downwards, yet another will apply it, and yet another will sample it from another wall, but I haven’t gotten past the concept stage and probably won’t get around to writing it for at least a few weeks. If you have any better ideas for a UI for this feature, please contact me [on GitHub](https://github.com/aaronfreed) or on Discord (**@aaron6608**).
- This version of Vasara adds the reverse slide, 2x, and 4x transfer modes from Aleph One 1.7.
  - This flat-out breaks if you aren’t using at least Aleph One 1.7, and I don’t care. Upgrade your Aleph One.
  - I don’t know what sort of preview to do for the 2x or 4x transfer modes. Contact me (see directly above) if you have any ideas.
- The new “Realign when retexturing” option preserves the old behavior of Vasara of realigning textures to (0,0) when you change a texture. I currently have it disabled by default, since it’s possible to realign textures to (0,0) manually with it disabled, while it’s *not* possible to preserve existing texture alignment with it *enabled*, but sometimes having it enabled is useful behavior.

----------------------------------------------------------------
### BUG FIXES, CURRENT ISSUES, PLANNED FEATURES, AND CREDITS:

- I’ve fixed the Lua error spam for lights > 55, but haven’t figured out how to get them to preview correctly. You can currently select lights 0-97 in the main palette, and even if you have both “apply light” and “apply texture” selected with lights > 97, it won’t spam errors. I may figure out a way to reduce the size of each light if there are more than 98 so that more will fit in the selector (but really, what are you doing with that many lights? I’ve only ever made a map with that many lights to test Vasara).
- Platform and light switches now display a lot more options, which should reduce the amount people need to rely on tags. Side note: [tags are terrible](https://aaronfreed.github.io/mapmaking.html#tagsareterrible). :-)
- I think I understand the math needed to fix alignment of transparent textures on the reverse side; I just haven’t figured out how to get Vasara to do it correctly.
- As much as I hated Forge’s implementation of this feature, I’m tentatively planning to add an “adjust heights” mode that would adjust polygon heights, on the strict condition that it _always_ snap to the player’s selected grid setting.
  - Forge’s “adjust height” mode _always_ adjusted heights by 51 IU (≈.04980 WU). This meant that adjusting the height by five clicks would have moved it by 255 IU (≈.24902 WU), which caused egregious _mis_-alignments when mappers were too lazy to clean up their heights. (Bungie could’ve easily fixed this by simply adding or subtracting 1 IU \[≈.00098 WU\] with each five adjustments.) For those of us on the obsessive-compulsive spectrum, I believe this qualifies as a war crime. Any implementation of this feature that does _not_ align to a grid is to be nuked from orbit – it’s the only way to be sure.
- ~~The border for the selected texture on the texture palette broke and I haven’t figured out why. This has been the most annoying thing to debug.~~ Fixed. Apparently I needed to throw in some `tonumber` statements that weren't previously necessary. ¯\\(°\_o)/¯
- Vasara’s code is very, very dense and very, very sparsely documented, so this has been a slow project and will probably continue to be slow, but I hope to get it finished soon™.
- Most of the updates are mine; a few are Cryos (notably the platform switch fix and the initial work at expanding the grid selections) or Solra’s (e.g., the extended stack traces) work.

----------------------------------------------------------------
### NOTES ON TERMINOLOGY:
**Lengths and heights:**
  - A **world unit** (WU) is the standard size of a texture repetition (i.e., not using the “2x”, “4x”, or “Landscape” transfer modes).
  - The game uses a much smaller scale to store its position values and to perform most of its calculations. I refer to this scale as **internal units** (IU). 1,024 internal units equal one world unit (thus, 1 IU = 0.0009765625 WU).
  - For reference, in vanilla game physics, the player is 819 IU (≈0.7998 WU) tall and has a radius of 256 IU (0.25 WU).
  - Forge and Weland use both WU and IU in different contexts; for instance, when you single-click a point in either, the status bar in the lower left shows its location in WU; when you double-click it, the dialog box that comes up lists its location in IU. Most values are rounded to the thousandths place (which means that, e.g., 64 IU and 65 IU both display as 0.063 WU, although Weland treats these as functionally different heights in some circumstances).
  - Anvil and ShapeFusion list values for physics models in IU. The scale factor in a shapes file also corresponds to IU – each pixel of a shape with a scale factor of 1 will occupy 1 IU in the game world.
  - I present both WU and IU throughout the this document. This version of Vasara also displays both where space permits.

**Lines, sides, and surfaces:**
- A **line** is what you’d draw in Forge or Weland, and what they display in top-down view.
- Each line can have up to two associated **sides**. In most cases, a side does not begin to exist until a **texture** is placed on the line. A side’s **obverse polygon** is the one closer to its viewer; the **converse polygon**, if it exists, is the one further away.
- Each side in turn has what, for lack of a better term, I refer to as **surfaces**. These generally, though not always, correspond to textures placed on them. I describe the exceptions in the sublist below.
- Each side can also have multiple textures, which can be **primary**, **secondary**, or **transparent**. These generally, though not always, correspond both to surfaces and to different parts of a border between two polygons.
- I’m currently aware of at least four cases in which “surface” and “texture” may not correspond how you’d expect:
  1. After the side was textured, one or more of the polygons on either side had its height changed in a way that added or deleted a surface. **Tip:** Using the “select texture” key on such a side will correct this, though you will probably need to retexture the side or realign its textures after you do so.
  2. A transparent and primary texture can both be applied to the same surface of a line that that does not border another polygon, e.g., the [dual texture trick](https://citadel.lhowon.org/litterbox/Forge/hastursworkshop/aesthetics3.html) from [Hastur’s Workshop](https://citadel.lhowon.org/litterbox/Forge/hastursworkshop/).
  3. A transparent and primary texture can also be applied to the same surface of a line bordering two polygons in certain circumstances, described in this item’s sub-bullets. In these cases, the same side can be given both a primary and a transparent texture, which functionally behave as two transparent textures with the “transparent” texture rendered in front of the “primary” texture on both sides. As far as I’m aware, this currently must be done using Lua. I’m currently thinking about a UI to enable this in Vasara.
      - This can work on *both* sides of the line *if and only if* the polygons on each side have the exact same floor and ceiling heights.
      - It can work on *one* side if the converse polygon’s floor height is no lower than the obverse polygon’s and its ceiling height is no lower than the obverse polygon’s. however, if either the floor or ceilings have different heights, it will not work on both.
      - If either the converse polygon’s height is higher than the obverse polygon’s, or the converse polygon’s ceiling is lower than the obverse polygon’s, this currently results in glitchy z-fighting. This may 
      - Sampling textures from these sides currently removes the transparent side if you have “edit transparent sides” selected; fortunately, pressing “undo” restores it. I’ll add “fix this” to my to-do list.
  4. The conditions described in iii may also exist _without_ a transparent texture. This means that, confusingly, a side will have a texture that looks to all appearances to be a “transparent” texture, but will be defined as “primary” in the engine. This was fairly easy to do in Forge – one simply made a line non-transparent, applied textures, and then reapplied transparency. It is less easy to do with modern tools – in fact, these sides are currently invisible to Vasara (I plan to work on a fix for this as well). Several examples of this form of texturing occur in the *Tempus Irae* level “Towel Boy”. (I may have changed them to genuine “transparent” textures in *Tempus Irae Redux* to make my life easier – I can’t remember at the moment.)
- If the polygon on the converse side has a lower ceiling and higher floor than the one on the obverse side, the primary texture is applied to the part of the side above the converse polygon’s ceiling, the transparent texture (if it exists) is applied to the part between the converse polygon’s floor and its ceiling, and the secondary texture is applied to the part below its floor.
- As far as I’m aware, in most other cases (outside the exceptions listed above), sides can only have primary and transparent textures, though the game can sometimes get confused into displaying the secondary texture, or not displaying any texture, if polygon heights have changed since the last time the map was textured.

**Ambient delta:**
- A value added to or subtracted from the light value of a side, where a value of 1 corresponds to a 100% increase in light value.
- Ambient delta applies to the entire side - thus, its primary, secondary, and transparent textures are all affected by it. It cannot be applied to polygon floors or ceilings.
- Negative ambient delta values can override the game’s miner’s light (i.e., the effect that lights surfaces close to the player more brightly).
  - Thus, If you want to preserve the miner’s light, do not give any side an ambient delta value lower than `-(100 - l)/100`, where l is the lowest possible intensity for any light applied to any of its surfaces.
    - **NOTE:** The Forge manual’s description of “∆ Intensity” is incorrect: the engine only ever adds, and never subtracts, random values from a light’s specified “Intensity”. Thus, if Intensity is 50 and ∆ Intensity is also 50, the possible values are not 0 to 100 but 50 to 100.
  - A side with an ambient delta value of 1 always renders at 100% light intensity, even if one or more of its surfaces is textured with a 0% intensity light.
  - If a side’s ambient delta value is -1, a texture on the side given a 100% intensity light is rendered as if it had been given a light with 0% intensity. A texture lit at 0% intensity is rendered as completely black.
  - If a side’s ambient delta value is -2, it always renders as completely black.

--**Aaron**, 2023-12-12

----------------------------------------------------------------
## Vasara 1.0.3
- by **Hopper** and **Ares Ex Machina**
- from work by **Irons** and **Smith**

----------------------------------------------------------------
### DESCRIPTION:

Vasara is a Lua script and dedicated HUD for use in texturing **Aleph One** maps. The HUD lists the keyboard shortcts for easy reference, and features a GUI-style interface for choosing textures and options.

To get the most out of Vasara, be sure to turn on "**Use Mouse**" and "**Overlay Map**" in your preferences.

----------------------------------------------------------------
### INSTALLATION:

- Drag the downloaded .zip file, or the unzipped "Vasara" folder, into the "**Plugins**" folder inside your *Marathon Infinity* or custom scenario folder. (Create a "**Plugins**" folder if you don't already have one.)
- Launch **Aleph One**, and go to "**Preferences**", then "**Environment**", then **"Plugins**" to enable or disable Vasara.

***(EDITORIAL NOTE:** With **Aleph One** 1.7 and later, **Plugins** isn’t found under **Environment** but is instead its own button. But then, you can also just launch **Vasara** from within **Weland,** and you should. See Weland’s readme for basic instructions or https://aaronfreed.github.io/mapmaking.html#welandsetup for a more detailed setup guide. **-Aaron)***

**IMPORTANT:** other plugins can interfere with Vasara. You should be all right as long as anything listed after Vasara in your plugins list is turned off. If you have problems, try turning off all plugins except Vasara.

***(EDITORIAL NOTE:** More specifically, it’s best to disable any other plugin that uses solo Lua while using Vasara. These will be marked as such on the plugins list. Any other plugins probably won’t affect its performance. **-Aaron)***

----------------------------------------------------------------
### GETTING STARTED:

Vasara has four modes. The tabs at the top left of the screen show which mode you're in, and the area to the right shows what your keys do. For some commands, you need to hold the **Microphone** key down and then press the other key shown.

***(EDITORIAL NOTE:** The Microphone key is now referred to as the **Aux Trigger** key. I will henceforth correct the term without further notes to this extent. **-Aaron)***

Vasara will feel most natural if you have "**Use Mouse**" turned on, and have the primary trigger mapped to your left mouse button. That way, the most common actions can be done by pointing and clicking.

1. You start in **Visual Mode**, where you apply lights and textures to your level. Click to "paint", and hold the trigger down to drag textures into position.

2. Press the **Aux Trigger** key to switch to **Choose Textures mode**. Click a texture to select it for use in **Visual Mode**. Click on the buttons at the bottom to switch to a different collection. Or, use the key shortcuts to switch textures and collections.

3. Press the **Action** key to switch to **Options mode**. You can toggle lesser-used settings here, like **snap-to-grid** or **transfer modes**.

4. Press the **Map** key to switch to **Teleport mode**. Point at a polygon and click to teleport there. With the key shortcuts, you can cycle through polygons to reach faraway areas. The currently selected polygon is highlighted in first-person view and on the overhead map.

You can get back to **Visual Mode** from any other mode by hitting the **secondary trigger** (the "grenade" button). Always check the top of the screen to see what your options are.

***(EDITORIAL NOTE:** If you’ve launched Vasara through Weland as I’ve suggested doing above, the rest of this section will not be necessary. -**Aaron)***

To save your work, press the **Chat/Console** key (default is backslash: \ ) and then type:

```lua
  .save level my-fabulous-level.sceA
```

The period at the start is important! You can replace "my-fabulous-level.sceA" with whatever filename you like. Your level will be saved in Aleph One's standard location for your platform; see https://github.com/Aleph-One-Marathon/alephone/wiki/File-Locations

----------------------------------------------------------------
### TIPS AND TRICKS:

Vasara's functionality is based on **Visual Mode.lua**, which in turn is based on **Forge**'s Visual Mode. If you're confused about what something in Vasara does, check the Forge manual or existing discussions about VML.

Having trouble navigating menu screens with the mouse? Try the keyboard. Your key bindings for turning and looking up/down will move the cursor. Moving or sidestepping will snap the cursor to the closest item in the pressed direction.

When selecting lights, the clickable area is larger than you might think. You can click on either the number or the square.

For VML veterans, the key combo **Aux+Action** acts as an **Undo/Redo toggle** just like in Visual Mode.lua.

Once you're done texturing, you can take screenshots of your level in Vasara. Use teleport, jump and freeze to find a nice vantage point, then press F2 to hide the GUI. Press F9 to take a screenshot and F1 to bring the GUI back.

The two Lua scripts have various preferences at the top. You can change the mouse cursor sensitivity, the color scheme, the collection names, and more. Poke around there if you're interested.

***(EDITORIAL NOTE:** Owing to how one of our script elements works, these had to be moved down a bit. They are currently about 100 lines down. --**Aaron**)*

----------------------------------------------------------------
### SCENARIO COMPATIBILITY:

Out of the box, Vasara only works with scenarios that use the same 5 texture sets and same 4 landscapes as *Marathon Infinity*, since the plugin needs to know the proper shapes collections to use. It mostly works with *Marathon 2* (which is missing the Jjaro set), but there are glitches with the fourth "landscape" since M2 uses that collection for something else.

To use Vasara with additional or moved collections (or to limit M2 to the 3 working landscapes), edit the "walls" and "landscapes" settings at the top of **Vasara_Script.lua**.

***(EDITORIAL NOTE:** Again, these are currently about 100 lines into the script. --**Aaron**)*

----------------------------------------------------------------
### CHANGELOG:

**v1.0.3:**
* Improved compatibility with Marathon 2

**v1.0.2:**
* Fix problem where "Revert Changes" did nothing
* Fix problem where control panel settings were reverted
* Fix problem where chip insertion slots were marked as destroyable
* Require Aleph One 1.2, which fixes a bug involving Lua and wires
* Ships as one plugin instead of two

**v1.0.1:**
* Fix crash when frames are missing for wall texture bitmaps
* Fix crash when a level has no platforms

**v1.0:**
* First release

----------------------------------------------------------------
### SPECIAL THANKS:

* **TychoVII**, **Kurinn** - For pushing the boundaries of the Lua HUD
* **Bitstream**, **Tavmjong Bah** - For fonts used in the HUD
* **dustu** - For beta testing
* **Treellama**, **Irons** - For Visual Mode.lua

----------------------------------------------------------------
### CONTACT:

If you have any questions, comments, or bugs to report, you can email Hopper:
- hopper@whpress.com
