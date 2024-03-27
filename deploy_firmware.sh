cd ./ui

# We want to build assets on our host machine.
export MIX_TARGET=host
export MIX_ENV=dev

# This needs to be repeated when you change dependencies for the UI.
mix deps.get

# This needs to be repeated when you change JS or CSS files.
mix assets.deploy

cd ../firmware

# Specify our target device.
export MIX_TARGET=rpi3a
export MIX_ENV=dev

mix deps.get
mix firmware
mix firmware.burn

