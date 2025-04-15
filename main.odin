package game

import rl "vendor:raylib"

TILE_SIZE: i32 : 16

SCREEN_WIDTH: i32 : 1280
SCREEN_HEIGHT: i32 : 720

VIRTUAL_SCREEN_WIDTH: i32 : 320
VIRTUAL_SCREEN_HEIGHT: i32 : 180
VIRTUAL_RATIO: f32 : f32(SCREEN_WIDTH / SCREEN_HEIGHT)

GRID_WIDTH: i32 : 10
GRID_HEIGHT: i32 : 10

grid: [GRID_WIDTH][GRID_HEIGHT]i32

main :: proc() {
	rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Rekindle")
	player = {{0, 0}, rl.LoadTexture("textures/player.png")}
	defer rl.CloseWindow()

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

		if rl.IsMouseButtonPressed(.LEFT) || rl.IsMouseButtonPressed(.RIGHT) {
			grid_x := i32(mouse_pos.x) / TILE_SIZE
			grid_y := i32(mouse_pos.y) / TILE_SIZE

			if grid_x >= 0 && grid_x < GRID_WIDTH && grid_y >= 0 && grid_y < GRID_HEIGHT {
				if rl.IsMouseButtonPressed(.LEFT) {
					grid[grid_y][grid_x] = 1
				} else if rl.IsMouseButtonPressed(.RIGHT) {
					grid[grid_y][grid_x] = 0
				}
			}
		}

		rl.BeginTextureMode(target)
		// Draw player
		rl.DrawTextureV(
			player.sprite,
			{player.position.x * f32(TILE_SIZE), player.position.y * f32(TILE_SIZE)},
			rl.WHITE,
		)

		// Draw tiles
		for y in 0 ..< GRID_HEIGHT {
			for x in 0 ..< GRID_WIDTH {
				if grid[y][x] != 0 {
					rl.DrawRectangle(
						i32(x * TILE_SIZE),
						i32(y * TILE_SIZE),
						TILE_SIZE,
						TILE_SIZE,
						rl.RED,
					)
				}
			}
		}
		// Draw grid lines
		for y in 0 ..= GRID_HEIGHT {
			rl.DrawLine(
				0,
				i32(y * TILE_SIZE),
				i32(GRID_HEIGHT * TILE_SIZE),
				i32(y * TILE_SIZE),
				rl.WHITE,
			)
		}
		for x in 0 ..= GRID_WIDTH {
			rl.DrawLine(
				i32(x * TILE_SIZE),
				0,
				i32(x * TILE_SIZE),
				i32(GRID_WIDTH * TILE_SIZE),
				rl.WHITE,
			)
		}

		rl.ClearBackground(rl.DARKBROWN)
		rl.EndTextureMode()

		rl.BeginDrawing()

		rl.DrawTexturePro(target.texture, source_rec, dest_rec, origin, f32(0), rl.WHITE)

		rl.EndDrawing()
	}
}
