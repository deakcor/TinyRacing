extends Control


func set_row(rank,pseudo,time,me):
	$cont/rank.text=str(rank)
	$cont/pseudo.text=pseudo
	$cont/time.text=time
	if me or rank is String:
		$cont/rank.set("custom_colors/font_color", Color("#3f7cb6"))
	elif rank==1:
		$cont/rank.set("custom_colors/font_color", Color("#FFD700"))
	elif rank==2:
		$cont/rank.set("custom_colors/font_color", Color("#C0C0C0"))
	elif rank==3:
		$cont/rank.set("custom_colors/font_color", Color("#CD7F32"))
	
