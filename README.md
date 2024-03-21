# How this will eventually work

*this is for my own notekeeping*

## 1) Build Stardew Valley Reference Binaries

Possible avenues:

**Download from Steam**

Upside: Steam builds come first
Downside: Steam builds require constant reauthentication, require DRM

**Download from GOG**

Upside: DRM-free builds, can download specific files (focus only on DLLS), all builds are properly tagged
Downside: Comes a bit later than Steam

**Verdict: probably from GOG**

Building reference DLLs using [Refasmer](https://github.com/JetBrains/Refasmer), which will strip all implementation details and only keep the API surface, so referenced binaries are totally fine.

Figure out: what binaries can we strip? Can we remove the included dotnet and instead use a base docker image that includes this? Should theoretically be possible by finding the tag referenced by StardewValley.deps.json. I don't know.

Publish reference DLLs as release on this repo? We can publish per build, properly tagged with the relevant build from (GOG, Steam)

NOTE: all of this requires explicit permission from someone, probably

## 2) Build SMAPI using Reference Binaries, publish as Docker Image

Using script from SMAPI, we should be able to build a reference docker image containing reference binaries + SMAPI + dotnet runtime relevant to Stardew Build.

Tagging strategy: Do we want reference binaries per SMAPI/Version triplet? We can find the relevant SMAPI version by parsing the releases log and downloading the relevant tag. It should be as easy as `dotnet publish` for everything, but I'm not sure how far back this build strategy extends to. Will probably require some level of just testing.

## 3) Package CLI inside of Docker Image that allows easy builds

Build a CLI (probably in Python?) that handles building a specific mod. Mod is bind-mounted to a specified directory, we can `docker run mod_cli --[blah] blah` and it builds the mod. It will be outputted in the bind mount directory (or redirected). Can specify release, debug, etc.

## 4) Create a Github Action

The github action will just be an extension of the docker image, which a bit of ease of use metadata (specify desired SMAPI, game version, etc.) Gitlab CI users can use the docker image directly.
