package game

import rl "vendor:raylib"

TILE_SIZE: i32 : 16

SCREEN_WIDTH: i32 : 1280
SCREEN_HEIGHT: i32 : 720

VIRTUAL_SCREEN_WIDTH: i32 : 320
VIRTUAL_SCREEN_HEIGHT: i32 : 180

VIRTUAL_RATIO: f32 : f32(SCREEN_WIDTH) / f32(SCREEN_HEIGHT)

selected_entity: Entity

Level :: struct {
	entities: [dynamic]^Entity,
}

level: Level

main :: proc() {
	rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Rekindle")
	defer rl.CloseWindow()

	init_player()

	load_entity_textures()

	selected_entity = box

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
			if is_empty(f32(grid_x), f32(grid_y)) {
				new_entity := new(Entity)
				new_entity^ = selected_entity
				new_entity.position = {f32(grid_x), f32(grid_y)}
				append(&level.entities, new_entity)
			}
		}

		if rl.IsMouseButtonDown(.RIGHT) {
			grid_x := i32(mouse_pos.x) / TILE_SIZE
			grid_y := i32(mouse_pos.y) / TILE_SIZE
			index := get_entity_index(f32(grid_x), f32(grid_y))
			if index >= 0 {
				free(level.entities[index])
				unordered_remove(&level.entities, index)
			}
		}

		if rl.IsKeyPressed(.ONE) {
			selected_entity = torch
		}

		if rl.IsKeyPressed(.TWO) {
			selected_entity = box
		}

		rl.BeginTextureMode(target)
		rl.ClearBackground(rl.DARKBROWN)

		// Draw entities
		for entity in level.entities {
			rl.DrawTextureV(
				entity.sprite,
				{entity.position.x * f32(TILE_SIZE), entity.position.y * f32(TILE_SIZE)},
				rl.WHITE,
			)
		}

		rl.EndTextureMode()
		rl.BeginDrawing()

		rl.DrawTexturePro(target.texture, source_rec, dest_rec, origin, 0, rl.WHITE)

		rl.DrawText(rl.TextFormat("Selected Entity: %i", selected_entity.type), 2, 4, 20, rl.RED)

		rl.EndDrawing()
	}
}
