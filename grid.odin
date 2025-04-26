package game

import rl "vendor:raylib"

is_empty :: proc(x: f32, y: f32) -> bool {
	for entity in level.entities {
		if x == entity.position.x && y == entity.position.y {
			if entity.solid {
				return false
			}
		}
	}
	return true
}

get_entity_index :: proc(x: f32, y: f32) -> int {
	for i in 0 ..< len(level.entities) {
		if x == level.entities[i].position.x && y == level.entities[i].position.y {
			return i
		}
	}
	return -1
}
