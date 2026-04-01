extends Node
class_name SfxManager

enum sfx {KnightEnterButton, KnightPressButton, KnightLevelUp, GamerEnterButton, GamerPressButton}

func PlaySfx(soundToPlay : sfx):
	if soundToPlay == sfx.GamerPressButton : $GamerPressButton.play()
	elif soundToPlay == sfx.KnightPressButton : $KnightPressButton.play()
	elif soundToPlay == sfx.KnightEnterButton : $KnightEnterButton.play()
	elif soundToPlay == sfx.KnightLevelUp : $KnightLevelUp.play()
