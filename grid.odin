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

get_entity_index :: proc(x: f32, y: f32) -> int {
	for i in 0 ..< len(entities) {
		if x == entities[i].position.x && y == entities[i].position.y {
			return i
		}
	}
	return -1
}
