package main

import rl "vendor:raylib"

TILE: int : 16

SCREEN_WIDTH: i32 : 1280
SCREEN_HEIGHT: i32 : 720

VIRTUAL_SCREEN_WIDTH: i32 : 320
VIRTUAL_SCREEN_HEIGHT: i32 : 180
VIRTUAL_RATIO: f32 = f32(SCREEN_WIDTH / SCREEN_HEIGHT)

player_pos := rl.Vector2{0, 0}

main :: proc() {
	rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Kindler")

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

		if rl.IsKeyPressed(.LEFT) {
			player_pos.x -= 1
		} else if rl.IsKeyPressed(.RIGHT) {
			player_pos.x += 1
		} else if rl.IsKeyPressed(.UP) {
			player_pos.y -= 1
		} else if rl.IsKeyPressed(.DOWN) {
			player_pos.y += 1
		}

		rl.BeginTextureMode(target)
		rl.ClearBackground(rl.DARKBROWN)
		rl.DrawRectangleV({player_pos.x * f32(TILE), player_pos.y * f32(TILE)}, {16, 16}, rl.WHITE)
		rl.EndTextureMode()

		rl.BeginDrawing()

		rl.DrawTexturePro(target.texture, source_rec, dest_rec, origin, f32(0), rl.WHITE)

		rl.EndDrawing()
	}

	rl.CloseWindow()
}
