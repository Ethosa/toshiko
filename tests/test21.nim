# --- Test 23. Play audio. --- #
import toshiko


Window("Test 23")

build:
  - Scene main:
    - AudioStreamPlayer audio1
    - AudioStreamPlayer audio2

audio1.stream = loadAudio("assets/V-NSH.ogg")
audio1.setVolume(64)
audio2.stream = loadAudio("assets/Amusing Mechanisms.ogg")
audio2.setVolume(64)

audio1.play()
when false:
  # You can play more than one audio at one time.
  audio2.play()

addMainScene(main)
showWindow()
