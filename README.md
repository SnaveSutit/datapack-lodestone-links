# Lodestone Links
A simple data pack that adds a more immersive and more balanced alternative to the /warp command.
### How to install
Simply download the .zip from the [releases page](https://github.com/SnaveSutit/datapack-lodestone-links/releases/) and drop it into your world's datapack folder, no unzipping required!
### How to use

#### Notes:
- Lodestone Links can teleport into unloaded chunks.
- Lodestone Links do not work interdimensionally, as lodestone compasses don't either (sticking with the vanilla theme).

### How to compile the source code
This data pack was built using [MC Build](https://github.com/mc-build/mc-build), a tool that greatly streamlines the process of creating data packs for vanilla minecraft.

How to build this data pack from source:
1. Install MCB by following the instructions [Here](https://mcbuild.dev/docs/lang-mc/Getting-Started/#installing-mc-build)
2. Restart the command prompt
3. Download the [source code](https://github.com/SnaveSutit/datapack-lodestone-links/archive/main.zip) and unzip it
4. Rename the file from `main` to `Lodestone Links`
5. Open a command prompt and navigate to the folder you just unzipped and renamed
6. Run `mcb add lang mc-extra`in the command prompt. This will add an extra utility language to your project called `mc-extra` which allows for defining some json datapack files within a `.mc`
7. Run `mcb -build` in the command prompt. It will perform a single build, and then exit
