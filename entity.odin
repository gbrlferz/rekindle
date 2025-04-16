package game

import rl "vendor:raylib"

entities: [dynamic]Entity

Entity :: struct {
	type:     Entity_Type,
	position: rl.Vector2,
	sprite:   rl.Texture2D,
}

Entity_Type :: enum {
	Empty,
	Player,
	Wall,
	Box,
	Torch,
}
