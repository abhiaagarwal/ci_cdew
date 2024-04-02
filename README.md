# How this will eventually work

*this is for my own notekeeping*

## 1) Build Stardew Valley Reference Binaries

**Download from Steam**

We can use [SteamDepotDownloader](https://github.com/SteamRE/DepotDownloader) to download any new releases. This will likely be done on a cadence (let's say, every day or so?). By parsing the steam buildlog, we can find any new builds. Since we're only allowing one build per version, all we have to do is compare if the new manifest matches any tags in this repository (we should probably store the manifest tag somehow). 

We first download `StardewValley.deps.json` – it's been published since Manifest Version [4228275145178987423](https://steamdb.info/depot/413151/history/?changeid=M:4228275145178987423), the first version using Monogame x64 rather than XNA (it's probably not worth it to go any further back). From this, we can impute the exact list of dependencies required by `StardewValley.dll`, and then selectively download those files only. However, we can do one better — since most of the dependencies are published on NuGet, we can only keep the dependencies that are actually bundled with the game. The reference binary process does not actually require to have the dependencies as it just strips DLLs, so we can be picky with what we get. Reduce bandwidth and all. 

We might want to grab the `StardewValley.xml` file so any users using this in development have access to tags. TBD.

Building reference DLLs using [Refasmer](https://github.com/JetBrains/Refasmer), which will strip all implementation details and only keep the API surface, so referenced binaries are totally fine.

## 2) Build SMAPI using Reference Binaries, publish as Nuget package

SMAPI can be built from the reference binaries. In fact, if it can be built, that serves as a pretty good indicator that we're on the right track. First, to actually download the right version of SMAPI, we checkout the repository in an empty environment, and then analyze the github releases to determine what version they should use. The releases are pretty consistently tagged with "Made for Stardew Valley x.x.x+", our strategy is to choose the newest release that "matches" the lowest requirement (which can be done by comparing SemVers).

From this, we then use a git client to `git checkout tag/whatever`, and then try to build SMAPI. SMAPI tries to build against files inside the game, but we're using the versions from nuget, so we need to be a bit smarter here. We can probably manually overwrite the `csproj` (lol) if we're feeling particularly spicy. 

Additionally, from our internal list of dependencies we got by analyzing `StardewValley.deps.json`, we use the dependencies defined in SMAPI's `csprj` to "upgrade" the dependencies to what they should we. We can do this via version resolver or just a simple SemVer compare. 

I'm writing all of this in python. I know C#, but this is gonna be a little hacky and I want to go fast. This can be rewritten in C# later, if desired.

## 3) Assemble nuget package

We now have a bunch of binaries, which should be `StardewValley.dll` and `StardewValleyModdingAPI.dll` (and likely the bundled Harmony version). This need to be packaged into a nuget file. Drawing on [RimRef](https://github.com/krafs/RimRef/tree/main/package) (hugeee shoutout to them :)) we can just create a "shim" package and dump all our DLLs inside there. We can also dynamically modify the csproj again, using python hackery. We can define the dependencies needed through resolvement and the needed dotnet version as well.

Lots of hackery involved. But this should be a "robust!" solution!
