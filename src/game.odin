package sokoban

import rl "vendor:raylib"

TileType :: enum u8 {
	Empty,
	Wall,
	Floor,
	Goal,
}

EntityType :: enum u8 {
	None,
	Player,
	Box,
}

Tile :: struct {
	position: [2]i32,
	type:     TileType,
}

Entity :: struct {
	position: [2]i32,
	type:     EntityType,
}

Light :: struct {
	position: [2]i32,
	radius:   f32,
}

World :: struct {
	player:   Entity,
	entities: [dynamic]Entity,
	tiles:    [dynamic]Tile,
	lights:   [dynamic]Light,
	assets:   ^Assets `json:"-"`,
}
