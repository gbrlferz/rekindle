package game

import rl "vendor:raylib"

player: Entity

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
	if check_grid(i32(pos.x), i32(pos.y)) {
		player.position = pos
	}
	pos = player.position
}

check_grid :: proc(x: i32, y: i32) -> bool {
	if x >= 0 && x < GRID_WIDTH && y >= 0 && y < GRID_HEIGHT {
		if grid[y][x] == 1 {
			return false
		} else {
			return true
		}
	}
	return false
}
