FROM alpine:latest as stardew-base

RUN apk --no-cache add unzip curl

# this has been hard-linked from the actual directory of Stardew Valley on my laptop.
ARG GAME_PATH="stardew/MacOS/"

ADD ${GAME_PATH} "/game/StardewValley"

ARG SMAPI_VERSION="4.0.1"
ARG SMAPI_PATH="SMAPI ${SMAPI_VERSION} installer"

RUN curl -L "https://www.curseforge.com/api/v1/mods/898372/files/5196995/download" --output /tmp/smapi.zip
RUN unzip -o /tmp/smapi.zip -d /tmp/smapi
RUN unzip -o "/tmp/smapi/${SMAPI_PATH}/internal/linux/install.dat" -d "/game/StardewValley"

RUN cp "/game/StardewValley/Stardew Valley.deps.json" "/game/StardewValley/StardewModdingAPI.deps.json" 

FROM mcr.microsoft.com/dotnet/sdk:6.0 as builder

COPY --from=stardew-base /game/StardewValley /game/StardewValley

ARG MOD_PATH="StardewMods/"

WORKDIR /game/mod

COPY ${MOD_PATH} .

# in a real-world scenario, this would NOT exit; 0. just for proof of concenpt
RUN dotnet build -p:GamePath=/game/StardewValley -p:EnableModDeploy=false -p:EnableModZip=true -p:ModZipPath=/output; exit 0

FROM scratch AS export

COPY --from=builder /output /