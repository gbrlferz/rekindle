package sokoban

import rl "vendor:raylib"

Assets :: struct {
	tile_textures:   [TileType]rl.Texture2D,
	entity_textures: [EntityType]rl.Texture2D,
}

init_assets :: proc() -> Assets {
	assets: Assets

	// Tiles
	assets.tile_textures[.Wall] = rl.LoadTexture("../assets/wall.png")

	// Entities
	assets.entity_textures[.Player] = rl.LoadTexture("../assets/player.png")
	assets.entity_textures[.Box] = rl.LoadTexture("../assets/box.png")

	return assets
}
