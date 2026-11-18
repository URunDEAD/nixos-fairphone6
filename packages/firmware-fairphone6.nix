# User-provided package input. Never fetch device firmware or calibration automatically.
{ runCommand, firmwareArchive }:
runCommand "fairphone6-firmware" {} ''
  mkdir -p "$out/lib"
  tar xf ${firmwareArchive} -C "$out/lib"
  test -d "$out/lib/firmware/qcom/milos/fairphone/fp6"
  if test -d "$out/lib/firmware/postmarketos"; then
    cp -a "$out/lib/firmware/postmarketos/." "$out/lib/firmware/"
  fi
''
