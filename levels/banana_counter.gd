extends Node

const TOTAL_BANANAS = 6
var captured_bananas = 0

func pickupBanana():
	captured_bananas += 1
	
	if get_tree().current_scene.has_method("banana_picked_up"):
		get_tree().current_scene.banana_picked_up()
	
	if captured_bananas >= TOTAL_BANANAS:
		if get_tree().current_scene.has_method("game_win"):
			get_tree().current_scene.game_win()
		else:
			print("You win, but unable to quit properly!")
			get_tree().quit()
