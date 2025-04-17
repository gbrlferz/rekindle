package game

import rl "vendor:raylib"

TILE_SIZE: i32 : 16

SCREEN_WIDTH: i32 : 1280
SCREEN_HEIGHT: i32 : 720

VIRTUAL_SCREEN_WIDTH: i32 : 320
VIRTUAL_SCREEN_HEIGHT: i32 : 180
VIRTUAL_RATIO: f32 : f32(SCREEN_WIDTH / SCREEN_HEIGHT)

main :: proc() {
	rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Rekindle")
	defer rl.CloseWindow()

	init_player()

	box := Entity {
		type   = .Box,
		sprite = rl.LoadTexture("./textures/box.png"),
	}

	target: rl.RenderTexture2D = rl.LoadRenderTexture(VIRTUAL_SCREEN_WIDTH, VIRTUAL_SCREEN_HEIGHT)

	source_rec: rl.Rectangle = {
		f32(0),
		f32(0),
		f32(target.texture.width),
		-f32(target.texture.height),
	}

	dest_rec: rl.Rectangle = {
		-VIRTUAL_RATIO,
		-VIRTUAL_RATIO,
		f32(SCREEN_WIDTH) + (VIRTUAL_RATIO * 2),
		f32(SCREEN_HEIGHT) + (VIRTUAL_RATIO * 2),
	}

	origin: rl.Vector2 = {f32(0), f32(0)}
	for !rl.WindowShouldClose() {
		// UPDATE
		player_movement()

		// Map Editor
		mouse_pos := rl.GetScreenToWorld2D(
			rl.GetMousePosition(),
			rl.Camera2D{zoom = f32(SCREEN_WIDTH) / f32(VIRTUAL_SCREEN_WIDTH)},
		)

		if rl.IsMouseButtonDown(.LEFT) {
			grid_x := i32(mouse_pos.x) / TILE_SIZE
			grid_y := i32(mouse_pos.y) / TILE_SIZE
			if check_grid(f32(grid_x), f32(grid_y)) {
				box.position = {f32(grid_x), f32(grid_y)}
				append(&entities, box)
			}
		}

		if rl.IsMouseButtonDown(.RIGHT) {
			grid_x := i32(mouse_pos.x) / TILE_SIZE
			grid_y := i32(mouse_pos.y) / TILE_SIZE
			index := get_entity_index(f32(grid_x), f32(grid_y))
			if index >= 0 {
				unordered_remove(&entities, index)
			}
		}

		rl.BeginTextureMode(target)

		// Draw player
		rl.DrawTextureV(
			player.sprite,
			{player.position.x * f32(TILE_SIZE), player.position.y * f32(TILE_SIZE)},
			rl.WHITE,
		)

		for entity in entities {
			rl.DrawTextureV(
				entity.sprite,
				{entity.position.x * f32(TILE_SIZE), entity.position.y * f32(TILE_SIZE)},
				rl.WHITE,
			)
		}

		rl.DrawText(rl.TextFormat("Entities: %i", len(entities)), 2, 2, 4, rl.RED)

		rl.ClearBackground(rl.DARKBROWN)
		rl.EndTextureMode()

		rl.BeginDrawing()

		rl.DrawTexturePro(target.texture, source_rec, dest_rec, origin, f32(0), rl.WHITE)

		rl.EndDrawing()
	}
}
