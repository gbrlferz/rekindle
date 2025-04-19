package game

import rl "vendor:raylib"

player: Entity

init_player :: proc() {
	player = {
		type     = .Player,
		position = {0, 0},
		sprite   = rl.LoadTexture("textures/player.png"),
	}

	append(&entities, &player)
}

player_movement :: proc() {
	pos := player.position
	if rl.IsKeyPressed(.LEFT) {
		pos.x -= 1
	} else if rl.IsKeyPressed(.RIGHT) {
		pos.x += 1
	} else if rl.IsKeyPressed(.UP) {
		pos.y -= 1
	} else if rl.IsKeyPressed(.DOWN) {
		pos.y += 1
	}
	if !check_grid(pos.x, pos.y) {
		player.position = pos
	}
}
