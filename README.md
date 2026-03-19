# Until Then Decompiled + Bahasa Indonesia

**Yeah, it's Until Then Decompiled back to a godot project. I also added my native language(Bahasa Indonesia) into the game**

# Building

**Things you need:**
- [Godot Engine v4.1.4](https://github.com/godotengine/godot/releases/tag/4.1.4-stable) (**MUST BE v4.1.4!!**)
- Patience (trust me you will need it)
- Common Sense

## Step 1: Download the repo
You can either git clone it or go to "Code -> Download ZIP" and then extract it, doesn't matter tbh
```
git clone https://github.com/trollguy62/UntilThenDecompiled.git
```

## Step 2: Open Godot Engine
Open the project(project.godot) in Godot Engine v4.1.4

## Step 3: Compile
# IMPORTANT: You MUST wait for Godot to load the project entirely. You can tell if it's loaded by checking the FileSystem and all the project files/folders should be under res://. This can take up to 10-30 or even more minutes

Once Godot finished loading the project, head over to "Project -> Export" and select Windows. Then "Export Project...". For me, it took ~30 minutes to compile

# NOTE
If you compiled it in Debug mode, you need to rename the dlls from "fmodL.dll" to "fmod.dll", "fmod.debug.dll" to "fmod.release.dll", "godotsteam.debug.x86_64.dll" to "godotsteam.dll", "internal.debug.dll" to "internal.dll", etc. Idk how to fix this because I'm not familiar with the Godot Engine, if you know, please open a PR!

Oh and this source has a problem with the fonts, for some reason it will spam a bunch of "Condition "!fd" is true. Returning: 0.0" errors so much that it causes lag spikes, let me know if you can fix this issue by opening a PR!