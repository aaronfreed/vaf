# Vasara AF
## a texturing utility for Marathon Aleph One

credits in chronological order:
- **[Visual Mode.lua](https://github.com/treellama/visualmode)** by **[@jonirons](https://github.com/jonirons)** and **[@treellama](https://github.com/treellama)**
- **[Vasara 1.0.3](https://simplici7y.com/items/vasara/)** by **[@Hopper262](https://github.com/Hopper262)** and **Ares Ex Machina**
- **Vasara AF 1.0b** by **[@aaronfreed](https://github.com/aaronfreed)**, **[@murbruksprodukt](https://github.com/murbruksprodukt)**, and **[@SolraBizna](https://github.com/SolraBizna)**

Hopper also has a **[GitHub repository for Vasara 1.0.2](https://github.com/Hopper262/Vasara)**, but it’s one version behind the Simplici7y release.

----------------------------------------------------------------
## WIP notes by Aaron (see below for original readme):
**Vasara AF** is a texturing utility for **[Marathon Aleph One](https://alephone.lhowon.org)** 1.7 or later, best used with **[Weland](https://github.com/treellama/weland/releases)** (see [my detailed setup guide](https://aaronfreed.github.io/mapmaking101.html#welandsetup) if Weland’s readme proves confusing). The original version hasn’t been updated in years, so I’ve taken it upon myself, with a little help from my friends, to update it for several reasons:
- to take advantage of new Aleph One features
- to add features that it had been sorely lacking for years
- to fix longstanding bugs.

This remains a work in progress, hence its beta status. Below are:
- [**Brief installation instructions, including a link to my Weland setup guide**](#getting-started)
- [**A more detailed overview of Vasara AF’s new features and settings**](#new-features--planned-additions)
  - [Advanced grid interface](#advanced-grid-interface)
  - [Apply texture mode](#apply-texture-mode)
  - [Advanced map overlays](#advanced-map-overlays)
  - [Aleph One 1.7’s new transfer modes](#aleph-one-17s-new-transfer-modes)
  - [Realign when retexturing](#realign-when-retexturing)
  - [Decouple transparent sides](#decouple-transparent-sides)
- [**A somewhat less exhaustive overview of bug fixes, known issues, planned features, credits, and links to additional resources**](#bug-fixes-current-issues-planned-features-and-credits)
  - [Bug fixes](#bug-fixes)
  - [Current issues](#current-issues)
  - [Planned features](#planned-features)
  - [Credits and contact info](#credits-and-contact-info)
  - [Further resources](#further-resources)
- [**Extremely obsessive notes on mapping terminology**](#notes-on-terminology) *(you do not need to memorize all of this before you begin texturing, but it may clarify some of the terminology I use in the above sections)*
  - [Lengths and heights](#lengths-and-heights)
  - [Lines, sides, and surfaces](#lines-sides-and-surfaces)
  - [Ambient delta](#ambient-delta)
- [**The original release notes from Vasara 1.0.x, with added notes where appropriate**](#vasara-103) *(at some point, I plan to integrate these more seamlessly into my own notes)*
  - [Description](#description)
  - [Installation](#installation)
  - [Getting started](#getting-started-1)
  - [Tips and tricks](#tips-and-tricks)
  - [Scenario compatibility](#scenario-compatibility)
  - [Changelog](#changelog)
  - [Special thanks](#special-thanks)
  - [Contact](#contact)

----------------------------------------------------------------
### GETTING STARTED:

1. Click “Code”.
2. Click “Download ZIP”.
3. Save to the “Plugins” directory for the scenario you want to use it with. If one doesn’t exist, make one. Mac users may need to make one here instead: https://github.com/Aleph-One-Marathon/alephone/wiki/File-Locations#mac-os-x-1
4. *(Optional, but highly recommended.)* Set it up in Weland. There are brief instructions in Weland’s readme; should one of the steps prove challenging or frustrating, I’ve written detailed guides for doing this on Windows and MacOS. If the word “Forge” brings up a lot of *Marathon*-related memories for you, you’ll probably want [my advanced guide](https://aaronfreed.github.io/mapmaking.html#welandsetup); otherwise, you should probably consult my [beginners’ guide](https://aaronfreed.github.io/mapmaking101.html#welandsetup). (One of these days I’ll write a guide for Linux.)
    * Alternately, you can run it through Aleph One directly; as this will require you to swap the map back and forth between Aleph One and Weland, simplifying version control should in and of itself be sufficient reason to avoid this approach. However, should you be unable to get Weland to launch Vasara correctly, select it in your Aleph One install’s Preferences -> Plugins, ensure that no other plugins that use solo Lua are enabled, and ensure that “Solo Lua Script” is unchecked. You will then have to type `.save level` into the Lua console to save the level and – this step is important – *make sure to reload it in Weland **after** you save it.* Which in turn, on Windows, will require you to quit Aleph One (or take some other similarly tedious step); and once you relaunch Aleph One, you’ll have to make sure *it* loads the right version of the level – like I said, I strongly recommend against this approach.
  
[Back to the top](#vasara-af)

----------------------------------------------------------------
### NEW FEATURES & PLANNED ADDITIONS:

#### Advanced grid interface
I’m almost finished redoing the grid interface.
- Vasara 1.0.x only offered five grid sizes: 1/2, 1/3, 1/4, 1/5, and 1/8 world units (WU). We’ve bumped this number up to twenty-one by adding options for 1, 1/6, 1/10, 1/12, 1/16, 1/18, 1/20, 1/24, 1/30, 1/32, 1/36, 1/40, 1/48, 1/60, 1/64, and 1/128 WU. 1/16 WU is now the default selection because it’s what I use by far the most. (See “[Lengths and Heights](#lengths-and-heights)” below for explanations of world units, internal units, and the engine’s space measurements.)
- The default “absolute” option is the vanilla alignment you’re used to from previous versions of Vasara: textures on polygons will be aligned to the map grid, and textures on walls will be aligned to the top-left.
- In addition, I’ve added three new “relative” options, which can be useful if you drew an entire map off-grid, but have a bunch of rectangles whose points align to a *different* grid (this applies to a disturbingly large number of levels in *Where Monsters Are in Dreams*), or if you recentred a map in Forge and it wasn’t recentred on-grid:
  - The “northwest” option treats walls exactly like the “absolute” option does; however, it aligns floors and ceilings to the westernmost X coordinate and the northernmost Y coordinate found within their respective polygons.
  - The “centred” option applies in both directions to floors, ceilings, and walls. I haven’t yet perfected the vertical alignment option for walls, but the horizontal alignment should always work correctly, and floors and ceilings should be aligned to a grid centred precisely within their respective polygons. I briefly had this set as the default, but reverted it to “absolute” since (a) it’s what people are used to and (b) I still find myself using it the most often.
  - The “southeast” option aligns walls to the right rather than to the left and to the bottom rather than to the top (although its vertical alignment is also not yet perfect). Meanwhile, it aligns floors and ceilings to the easternmost X coordinate and the southernmost Y coordinate within their respective polygons, making it the precise opposite of the “northwest” option.
- The “X” and “Y” snap options are present because there are numerous cases where mapmakers might want to align one but not the other, or might want to use one alignment option for X and a different one for Y. Separating these options makes those possible (although to get different X and Y snaps, you’ll have to align them separately, and it may help to use the keyboard to do so).
- If you want to disable the grid, disable both the X and Y snaps. (I could probably be persuaded to make a keyboard shortcut that toggles “grid snapping off” and “snap to X and Y” or that cycles between the different grid snaps.)
- The preview should now display all grid settings correctly, though bear in mind that it does not yet display the 2x and 4x transfer modes correctly – those will have more snap positions than you’ll see in the preview.

#### Apply texture mode
Vasara AF splits “Apply texture mode” and “apply texture” into two separate options.
- If you have “apply texture mode” selected, but not “apply texture”, Vasara will apply different transfer modes to existing textures without adjusting their textures, and *vice versa*. (The Romans would’ve pronounced this something like ***wee**-keh **wer**-sah*. There, you can cross off an item on your bingo cards. You’re welcome.)
- Landscapes are the wild card, as they usually override existing transfer modes. I have yet to work out all the strange behavior this causes.
  - If for some reason you wish to apply a texture from a landscape collection in a transfer mode other than “landscape”, you can apply it to your desired surface, deselect “apply texture”, and then apply a different transfer mode. (You may need to select a different texture before you can do the last of these.) However, bear in mind that textures from landscape collections may behave weirdly in transfer modes besides “landscape”.
- All of this mostly shows up correctly in visual mode, though the preview currently behaves weirdly when “apply texture” is disabled. (The checkbox in visual mode is now at least checked when “apply transfer mode” is checked, but “apply texture” isn’t.)

#### Advanced map overlays
Vasara AF lists what you’re looking at in the upper-left corner of visual mode, including one feature you’re probably not familiar with: ambient delta.
- Floors, ceilings, and lines without associated sides (which occur when you haven’t paved a level before going into visual mode) are labeled as floors, ceilings, or lines. Sides are listed along the lines “1337 (∆0.0420)”, which indicates that you are looking at side 1337 and that it has an ambient delta value of 0.0420. Ambient delta is a rarely-used map element that affects the side’s light intensity; at present, Greg Kirkpatrick, Jason Jones, and I are the only people I’m aware of who have ever used it. [I explain ambient delta at length below](#ambient-delta).
- If you see an additional side listed to the right of the one in the upper-left, it’s a transparent side. Unfortunately, Vasara currently displays the one furthest from you – I feel the closest one would make the most sense, but I’ve so far been unable to debug this.
- I haven’t yet begun writing the UI to adjust ambient delta, so for now, to set the ambient delta of side `foo` to `bar`, you can use the following Lua code:
    ```lua
    Sides[foo].ambient_delta = bar
    ```
  - `bar` should almost always be between -1 and 1.
  - Also, be warned that maps that use ambient delta will break if you run them through the Weland copy and paste plugin.
  - I’m not especially confident in my UI ideas (I’ve long held that UI is far too important to be left up to programmers that aren’t UI specialists, which I very decidedly am not). At the moment, I tentatively plan to add an “ambient delta modifier” hotkey that’ll be combined with other keys: one will select which digit to edit, another two will adjust it upwards or downwards, yet another will apply it, and yet another will sample it from another wall, but I haven’t gotten past the concept stage and probably won’t get around to writing it for weeks or even months. If you have any better ideas for a UI for this feature, please [contact me](#credits-and-contact-info).

#### Aleph One 1.7’s new transfer modes
Vasara AF adds the reverse slide, 2x, and 4x transfer modes from Aleph One 1.7.
- This flat-out breaks if you aren’t using at least Aleph One 1.7, and I don’t care. Upgrade your Aleph One.
- I don’t know what sort of preview to do for the 2x or 4x transfer modes. [Contact me](#credits-and-contact-info) if you have any ideas.

#### Realign when retexturing
- The new “Realign when retexturing” option preserves the old behavior of Vasara of realigning textures to (0,0) when you change a texture. I currently have it disabled by default, since it’s possible to realign textures to (0,0) manually with it disabled, while it’s *not* possible to preserve existing texture alignment with it *enabled*, but sometimes having it enabled is useful behavior.

#### Decouple transparent sides
The new “Decouple transparent sides” option disables Vasara’s standard behavior of editing the transparent side on the reverse of the one you’re looking at. The obvious applications that come to mind for this are:
- Aligning sides separately – useful for fixing faulty alignment, of which two kinds are especially common:
  - Incorrectly aligned “2x” and “4x” textures (the default alignment behavior assumes a texture size of 1 WU)
  - Alignment that got screwed up on only one side (“align adjacent” has never aligned both sides correctly)
- Applying different lights to each side – perhaps there’s a light on one side of the texture
- Applying entirely different textures to each side – especially useful if one texture is a horizontal flip of the other
- Applying a texture to only one side of a line

[Back to the top](#vasara-af)

----------------------------------------------------------------
### BUG FIXES, CURRENT ISSUES, PLANNED FEATURES, AND CREDITS:
#### Bug fixes:
- I’ve fixed the Lua error spam for lights > 55, but haven’t figured out how to get them to preview correctly. You can currently select lights 0-97 in the main palette, and even if you have both “Apply Light” and “Apply Texture” selected with lights > 97, it won’t spam errors. I may figure out a way to reduce the size of each light if there are more than 98 so that more will fit in the selector (but really, what are you doing with that many lights? I’ve only ever made a map with that many lights to test Vasara).
- Platform and light switches now display a lot more options, which should reduce the amount people need to rely on tags. Side note: [tags are terrible](https://aaronfreed.github.io/mapmaking.html#tagsareterrible). :-)
- ~~The border for the selected texture on the texture palette broke and I haven’t figured out why. This has been the most annoying thing to debug.~~ Fixed. Apparently I needed to throw in some `tonumber` statements that weren't previously necessary. ¯\\(°\_o)/¯
- “Align adjacent” now works correctly with *most* sides Vasara has created since loading the map. Still not aligning correctly: certain transparent sides, explained below.
- By default, Vasara AF now restores the state of “Must Be Explored” polygons after the player walks over them (or even looks at them if “Exploration (M1)” is set as the mission type) – previously, they’d be set to “Normal”. This is kind of a hack, and it makes Exploration missions incompletable while Vasara AF is running, but Vasara AF is primarily meant as a texturing utility, and I suspect that most people used to Forge found those polygons being set to “Normal” to be both annoying and unexpected. If you need to preview how a level works in gameplay without monsters, either use [Nature’s Peace](https://simplici7y.com/items/nature-s-peace/) or set `RESTORE_EXPLORATION` in Vasara_Script.lua to `false`.
  - Note that if, for some reason, you try to set a “Must Be Explored” polygon to “Normal” with Lua while Vasara AF is running, Vasara AF will automatically restore it to “Must Be Explored” – the engine doesn’t provide Lua any way to know why a polygon was changed from “Must Be Explored” to “Normal”.

#### Current issues:
- Transparent sides don’t align at all when the reverse polygon’s ceiling is higher than or has the same height as the obverse polygon’s, and the reverse polygon’s floor is lower than or has the same height as the obverse polygon’s.
- I think I understand the math needed to fix alignment of transparent textures on the reverse side; I just haven’t figured out how to get Vasara to know which transparent sides should be aligned to which others. (In fact, I’m not fully sure I know this myself.) Because of this, I’ve introduced the “decouple transparent textures” mode, though for the above reason, you’ll frequently have to align transparent textures on one side of a line manually (this should at least help for the other side, though).
- Exiting a level with a polygon highlighted in teleport mode will cause the floor to get set to “static” mode and the polygon to get set to “major ouch”, regardless of what was there before (**warning: if you were looking at a platform, this _will_ overwrite all its data**). I had a fix for this that involved not highlighting the polygons, but I wound up disliking that a lot more, so I restored the previous behaviour. Fixing it more properly may likewise require some engine-side changes.
- Switching from map view to visual mode while teleporting causes Vasara to get confused and swap the teleport controls to the visual mode screen.
- Freezing with enough momentum will result in continued camera bob. When you come out of the freeze state, your momentum will be reduced (or cut to zero).
- See also [Vasara AF’s issues page](https://github.com/aaronfreed/vasara/issues).

#### Planned features:
- As much as I hated Forge’s implementation of this feature, I’m tentatively planning to add an “adjust heights” mode that would adjust polygon heights, on the strict condition that it _always_ snap to the player’s selected grid setting.
  - Forge’s “adjust height” mode _always_ adjusted heights by 51 IU (≈.04980 WU). This meant that adjusting the height by five clicks would have moved it by 255 IU (≈.24902 WU), which caused egregious _mis_-alignments when mappers were too lazy to clean up their heights. (Bungie could’ve easily fixed this by simply adding or subtracting 1 IU \[≈.00098 WU\] with each five adjustments.) For those of us on the obsessive-compulsive spectrum, I believe this qualifies as a war crime. Any implementation of this feature that does _not_ align to a grid is to be nuked from orbit – it’s the only way to be sure.
- Vasara’s code is very, very dense and very, very sparsely documented, so this has been a slow project and will probably continue to be slow, but I hope to get it finished soon™.

#### Credits, acknowledgements, and contact info:
- Most of the updates are mine; a few are **[@murbruksprodukt](https://github.com/murbruksprodukt)** (notably the platform switch fix and the initial work at expanding the grid selections) or **[@SolraBizna](https://github.com/SolraBizna)**’s (e.g., the extended stack traces) work.
- Vasara AF is, of course, based on **[Vasara 1.0.3](https://simplici7y.com/items/vasara)** by **[@Hopper262](https://github.com/Hopper262)** (Jeremiah Morris, who did most of the programming) and **Ares Ex Machina** (who did most of the UI design).
- Vasara 1.0.3 is in turn based on **[Visual Mode.lua](https://simplici7y.com/items/visual-mode-lua)** by **[@treellama](https://github.com/treellama)** and **[@jonirons](https://github.com/jonirons)**.
- If you need to contact me, email is probably the worst possible way to do so. Your best bet is to open an issue or create a discussion here, or contact me on Discord (**@Aaron#6608** or **@aaron6608**). You’ll need a server in common with me to do the latter; if you’ve read this far and aren’t already a member of the [*Marathon* Discord](https://discord.gg/c7rEVgY), you’ll want to fix that as soon as possible.
- Acknowledgements to **Solra** for a ton of coding help, **treellama** for the name “Vasara AF”, all the **Aleph One** developers for keeping this thing going, and **Bungie** for creating the games that ruined our lives to begin with.

#### Further resources:
- **[Weland](https://github.com/treellama/weland/releases)**, just in case you somehow don’t have it yet. If you need help setting it up, see the relevant section of my beginners’ guide immediately below.
- My **mapmaking guide** is now split up into several segments, the most important being:
  - **[A beginners’ guide](https://aaronfreed.github.io/mapmaking101.html)**, which is relatively brief by my standards
  - **[An advanced guide](https://aaronfreed.github.io/mapmaking.html)** that I’m in the process of splitting up further; it in turn links to several appendices with additional info that you may find helpful
- [The Aleph One GitHub wiki](https://github.com/Aleph-One-Marathon/alephone/wiki) is an invaluable resource

[Back to the top](#vasara-af)

----------------------------------------------------------------
### NOTES ON TERMINOLOGY:
#### Lengths and heights:
- A **world unit** (WU) is the standard size of a texture repetition (i.e., not using the “2x”, “4x”, or “Landscape” transfer modes).
- The game uses a much smaller scale to store its position values and to perform most of its calculations. I refer to this scale as **internal units** (IU). 1,024 internal units equal one world unit (thus, 1 IU = 0.0009765625 WU).
- For reference, in vanilla game physics, the player is 819 IU (≈0.7998 WU) tall and has a radius of 256 IU (0.25 WU). There is contradictory information about how this corresponds to real-world measurements; the indispensable [Marathon’s Story page](https://marathon.bungie.org/story/) has an [entire section on this](https://marathon.bungie.org/story/ourheight.html), and the definitive answer is “¯\\(°_o)/¯”.
- Forge and Weland use both WU and IU in different contexts; for instance, when you single-click a point in either, the status bar in the lower left shows its location in WU; when you double-click it, the dialog box that comes up lists its location in IU. Most values are rounded to the thousandths place (which means that, e.g., 64 IU and 65 IU both display as 0.063 WU, although Weland treats these as functionally different heights in some circumstances).
- Anvil and ShapeFusion list values for physics models in IU. The scale factor in a shapes file also corresponds to IU – each pixel of a shape with a scale factor of 1 will occupy 1 IU in the game world.
- I present both WU and IU throughout the this document. This version of Vasara also displays both where space permits.

#### Lines, sides, and surfaces:
- A **line** is what you’d draw in Forge or Weland, and what they display in top-down view.
- Each line can have up to two associated **sides**. Generally, a side does not exist until a **texture** is placed on the line, usually because a mapmaker either paved the level or manually placed a texture. A line can have a side for each adjoining polygon; thus, if the line adjoins two polygons, it can have two sides, and if it adjoins one, it can only have one. To disambiguate them, I call the polygon closer to a given side’s viewer its **obverse polygon** (in this context, *obverse* = *facing the observer*); the **reverse polygon**, if it exists, is the one directly behind it. (My usage roughly corresponds to numismatics, wherein *obverse* signifies a coin’s *heads* side and *reverse* signifies *tails*.)
    - A line *must* have an obverse polygon, because negative space *physically does not exist* in portal engines like Aleph One; indeed, attempting to render from outside the bounds of a polygon simply crashes the game. This is why Aleph One does not (and probably will never have) a noclip cheat. (To my knowledge, *Marathon*’s source does not actually use the term *portal* anywhere, but in Aleph One, a portal is functionally equivalent to a polygon in most contexts.)
    - Aleph One doesn’t use the terms *obverse polygon* and *inverse polygon*, or indeed any like them; most often, it instead uses **counterclockwise polygon** and **clockwise polygon**, which don’t correspond reliably to viewer position and are very nearly useless for mapmakers unless they’re writing Lua scripts (in which case it may be helpful to note that they _do_ correspond reliably to **counterclockwise side** and **clockwise side**...as far as I know‽). To my understanding, how the mapmaker drew the line determines which side is clockwise and which is counterclockwise. (If either point already belonged to another line when the line in question was drawn, this may not correspond to the points’ indices.) Picture yourself ~~in a boat on a river~~ as being at point A, which is generally the point at which the mapmaker clicked to draw the line, and facing point B, generally the point at which they released the mouse button. (If someone has since moved these points, update these definitions to match their new locations.) To your left, you’ll find the clockwise side; to your right, counterclockwise.
    - Forge used, and the engine sometimes uses, *adjacent side* (i.e., obverse side) and *opposite side* (i.e., reverse side); I’ve avoided this because *adjacent* also appears in a different mapmaking context, “activates adjacent platform”, that I don’t consider sufficiently similar. (The ‘adjacent’ platform will actually be further from the player if they are standing on the platform that activates it!)
- Each side in turn has what, for lack of a better term, I refer to as **surfaces**. These generally, though not always, correspond to textures placed on them. I describe the exceptions in the sublist below.
- Each side can also have multiple **textures**, which can be **primary**, **secondary**, or **transparent**. These generally, though not always, correspond both to surfaces and to different parts of a border between two polygons.
- I’m currently aware of at least four cases in which “surface” and “texture” may not correspond how you’d expect:
  1. After the side was textured, one or more of the polygons on either side had its height changed in a way that added or deleted a surface. **Tip:** Using the “select texture” key on such a side will correct this, though you will probably need to retexture the side or realign its textures after you do so.
  2. A transparent and primary texture can both be applied to the same surface of a line that that does not border another polygon, e.g., the [dual texture trick](https://citadel.lhowon.org/litterbox/Forge/hastursworkshop/aesthetics3.html) from [Hastur’s Workshop](https://citadel.lhowon.org/litterbox/Forge/hastursworkshop/).
  3. A transparent and primary texture can also be applied to the same surface of a line bordering two polygons in certain circumstances, described in this item’s sub-bullets. In these cases, the same side can be given both a primary and a transparent texture, which functionally behave as two transparent textures with the “transparent” texture rendered in front of the “primary” texture on both sides. As far as I’m aware, this currently must be done using Lua. I’m currently thinking about a UI to enable this in Vasara.
      - This can work on *both* sides of the line *if and only if* the polygons on each side have the exact same floor and ceiling heights.
      - It can work on *one* side if the reverse polygon’s floor height is no lower than the obverse polygon’s, and the reverse polygon’s ceiling height is no higher than the obverse polygon’s. However, if either the floors or ceilings of the adjoining polygons have different heights, it *will not* work on both sides of the line.
      - If either the reverse polygon’s height is higher than the obverse polygon’s, or the reverse polygon’s ceiling is lower than the obverse polygon’s, this currently results in glitchy z-fighting.
      - Sampling textures from these sides currently removes the transparent side if you have “edit transparent sides” selected; fortunately, pressing “undo” restores it. “Fix this” is on my to-do list.
  4. The conditions described in iii may also exist _without_ a transparent texture. This means that, confusingly, a side will have a texture that looks to all appearances to be a “transparent” texture, but will be defined as “primary” in the engine. This was fairly easy to do in Forge – one simply made a line non-transparent, textured its sides, and then made it transparent again. It is less easy to do with modern tools – in fact, these sides are currently invisible to Vasara (I plan to work on a fix for this as well). Several examples of this form of texturing occur in the *Tempus Irae* level “Towel Boy”. (I may have changed them to genuine “transparent” textures in *Tempus Irae Redux* to make my life easier – I can’t remember at the moment.)
- If the polygon on the reverse side has a lower ceiling and higher floor than the one on the obverse side, the primary texture is applied to the part of the side above the reverse polygon’s ceiling, the transparent texture (if it exists) is applied to the part between the reverse polygon’s floor and its ceiling, and the secondary texture is applied to the part below its floor.
- As far as I’m aware, in most other cases (outside the exceptions listed above), sides should only display primary and transparent textures, though the game can sometimes get confused into displaying the secondary texture, or not displaying any texture, if polygon heights have changed since the last time the side was textured. In such cases, sampling the texture on any surface of the wall should generally fix the issue.
- Polygons’ **floors** and **ceilings** behave similarly to side surfaces, except their definition is much more straightforward, since each polygon always has exactly one floor and exactly one ceiling.

#### Ambient delta:
- A value added to or subtracted from the light value of a side, where a value of 1 corresponds to a 100% increase in light value.
- Ambient delta applies to the entire side - thus, its primary, secondary, and transparent textures are all affected by it. It cannot be applied to polygon floors or ceilings.
- Negative ambient delta values can override the game’s miner’s light (i.e., the effect that lights surfaces close to the player more brightly).
  - Thus, if you want to preserve the miner’s light, do not give any side an ambient delta value lower than `m/100 - 1`, where `m` is the minimum possible intensity for any light applied to any of its surfaces.
    - **NOTE:** The Forge manual’s description of “∆ Intensity” is incorrect: the engine only ever adds, and never subtracts, random values from a light’s specified “Intensity”. Thus, if Intensity is 50 and ∆ Intensity is also 50, the possible values are not 0 to 100 but 50 to 100. This is, incidentally, [far from being the Forge manual’s only erratum](https://aaronfreed.github.io/mapmaking.html#forgeerrata).
  - A side with an ambient delta value of 1 always renders at 100% light intensity, even if one or more of its surfaces is textured with a 0% intensity light.
  - If a side’s ambient delta value is -1, a texture on the side given a 100% intensity light is rendered as if it had been given a light with 0% intensity. A texture lit at 0% intensity is rendered as completely black.
  - If a side’s ambient delta value is -2, it always renders as completely black, barring occurrences such as muzzle flashes.
--**Aaron**, 2023-12-12 (last edited 2024-04-05)

[Back to the top](#vasara-af)

----------------------------------------------------------------
## Vasara 1.0.3
- by **Hopper** and **Ares Ex Machina**
- from work by **Irons** and **Smith**

----------------------------------------------------------------
### DESCRIPTION:

Vasara is a Lua script and dedicated HUD for use in texturing **Aleph One** maps. The HUD lists the keyboard shortcuts for easy reference, and features a GUI-style interface for choosing textures and options.

To get the most out of Vasara, be sure to turn on "**Use Mouse**" and "**Overlay Map**" in your preferences.

----------------------------------------------------------------
### INSTALLATION:

- Drag the downloaded .zip file, or the unzipped "Vasara" folder, into the "**Plugins**" folder inside your *Marathon Infinity* or custom scenario folder. (Create a "**Plugins**" folder if you don't already have one.)
- Launch **Aleph One**, and go to "**Preferences**", then "**Environment**", then **"Plugins**" to enable or disable Vasara.

> [!NOTE]
> With **Aleph One** 1.7 and later, **Plugins** isn’t found under **Environment** but is instead its own button. But then, you can also just launch **Vasara** from within **Weland,** and you should. See Weland’s readme for basic instructions or https://aaronfreed.github.io/mapmaking.html#welandsetup for a more detailed setup guide. **-Aaron**

**IMPORTANT:** other plugins can interfere with Vasara. You should be all right as long as anything listed after Vasara in your plugins list is turned off. If you have problems, try turning off all plugins except Vasara.

> [!NOTE]
> More specifically, it’s best to disable any other plugin that uses solo Lua while using Vasara. These will be marked as such on the plugins list. Any other plugins probably won’t affect its performance. **-Aaron**

----------------------------------------------------------------
### GETTING STARTED:

Vasara has four modes. The tabs at the top left of the screen show which mode you're in, and the area to the right shows what your keys do. For some commands, you need to hold the **Microphone** key down and then press the other key shown.

> [!NOTE]
> The Microphone key is now referred to as the **Aux Trigger** key. I will henceforth correct the term without further notes to this extent. **-Aaron**

Vasara will feel most natural if you have "**Use Mouse**" turned on, and have the primary trigger mapped to your left mouse button. That way, the most common actions can be done by pointing and clicking.

1. You start in **Visual Mode**, where you apply lights and textures to your level. Click to "paint", and hold the trigger down to drag textures into position.

2. Press the **Aux Trigger** key to switch to **Choose Textures mode**. Click a texture to select it for use in **Visual Mode**. Click on the buttons at the bottom to switch to a different collection. Or, use the key shortcuts to switch textures and collections.

3. Press the **Action** key to switch to **Options mode**. You can toggle lesser-used settings here, like **snap-to-grid** or **transfer modes**.

4. Press the **Map** key to switch to **Teleport mode**. Point at a polygon and click to teleport there. With the key shortcuts, you can cycle through polygons to reach faraway areas. The currently selected polygon is highlighted in first-person view and on the overhead map.

You can get back to **Visual Mode** from any other mode by hitting the **secondary trigger** (the "grenade" button). Always check the top of the screen to see what your options are.

> [!NOTE]
> If you’ve launched Vasara through Weland as I’ve suggested doing above, the rest of this section will not be necessary. -**Aaron**

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

> [!NOTE]
> Owing to how one of our script elements works, these had to be moved down a bit. They are currently about 100 lines down. --**Aaron**

----------------------------------------------------------------
### SCENARIO COMPATIBILITY:

Out of the box, Vasara only works with scenarios that use the same 5 texture sets and same 4 landscapes as *Marathon Infinity*, since the plugin needs to know the proper shapes collections to use. It mostly works with *Marathon 2* (which is missing the Jjaro set), but there are glitches with the fourth "landscape" since M2 uses that collection for something else.

To use Vasara with additional or moved collections (or to limit M2 to the 3 working landscapes), edit the "walls" and "landscapes" settings at the top of **Vasara_Script.lua**.

> [!NOTE]
> Again, these are currently about 100 lines into the script. --**Aaron**

----------------------------------------------------------------
### CHANGELOG:

#### v1.0.3:
* Improved compatibility with Marathon 2

#### v1.0.2:
* Fix problem where "Revert Changes" did nothing
* Fix problem where control panel settings were reverted
* Fix problem where chip insertion slots were marked as destroyable
* Require Aleph One 1.2, which fixes a bug involving Lua and wires
* Ships as one plugin instead of two

#### v1.0.1:
* Fix crash when frames are missing for wall texture bitmaps
* Fix crash when a level has no platforms

#### v1.0:
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

[Back to the top](#vasara-af)
