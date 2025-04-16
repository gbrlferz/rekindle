package game

import rl "vendor:raylib"

check_grid :: proc(x: f32, y: f32) -> bool {
	for entity in entities {
		if x == entity.position.x && y == entity.position.y {
			return false
		}
	}
	return true
}

get_entity :: proc(x: f32, y: f32) -> ^Entity {
	for &entity in entities {
		if x == entity.position.x && y == entity.position.y {
			return &entity
		}
	}
	return nil
}
