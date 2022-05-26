# Essentials API
A ⭐revolutionary⭐ CelLua API laser-focused on ⚡Efficiency⚡, 🧠Ease-of-Use🧠 and ✂️Shortcuts✂️

# How to install a mod?
Open the .love file as a zip archive and, if there is no Mods folder, create it.
If it already exists or after you created the Mods folder, you drag the folder containing the mod's files in it.

## How is a folder structured?
There is a `main.lua` file for normal code. This is mandatory.
Then there are 3 optional folders: `textures`, `cells` and `src`.

When loading a cell by default it will create the texture as a file inside of the `textures` folder.
`cells` is where cells are at. They return a table to config a cell, or return a table containing tables to create multiple cells at once.
`src` is where source files are at.

In `cells` and `src` all files in there get executed, unless they start with `_` or end with `.manual.lua`.

## How do you do any advanced stuff?
For that, read the Wiki of the GitHub. It goes more in-depth with the actual API.