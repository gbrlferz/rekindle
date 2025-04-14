package game

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
	defer rl.CloseWindow()

	target: rl.RenderTexture2D = rl.LoadRenderTexture(VIRTUAL_SCREEN_WIDTH, VIRTUAL_SCREEN_HEIGHT)
	player := Entity{{0, 0}, rl.LoadTexture("textures/player.png")}

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
		// Player controls
		if rl.IsKeyPressed(.LEFT) {
			player.position.x -= 1
		} else if rl.IsKeyPressed(.RIGHT) {
			player.position.x += 1
		} else if rl.IsKeyPressed(.UP) {
			player.position.y -= 1
		} else if rl.IsKeyPressed(.DOWN) {
			player.position.y += 1
		}

		rl.BeginTextureMode(target)
		// Draw Player
		rl.DrawTextureV(
			player.sprite,
			{player.position.x * f32(TILE), player.position.y * f32(TILE)},
			rl.WHITE,
		)
		rl.ClearBackground(rl.DARKBROWN)
		rl.EndTextureMode()

		rl.BeginDrawing()

		rl.DrawTexturePro(target.texture, source_rec, dest_rec, origin, f32(0), rl.WHITE)

		rl.EndDrawing()
	}
}
