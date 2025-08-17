package sokoban
import "core:math"
import rl "vendor:raylib"

GAME_WIDTH :: 320
GAME_HEIGHT :: 180
TILE_SIZE :: 20

BACKGROUND :: rl.Color{28, 38, 50, 255}

main :: proc() {
	rl.SetConfigFlags({.VSYNC_HINT})
	rl.InitWindow(1280, 720, "Sokoban")

	renderer := init_renderer(GAME_WIDTH, GAME_HEIGHT)
	assets := init_assets()
	editor := init_editor(&assets)

	world := World {
		player = {type = .Player},
		assets = &assets,
	}

	append(&world.lights, Light{{5, 5}, 4.0})

	load_game(&world, "world.json")

	rl.SetTargetFPS(60)

	for !rl.WindowShouldClose() {
		if rl.IsKeyPressed(.F9) {
			rl.ToggleBorderlessWindowed()
		}

		if rl.IsKeyPressed(.F1) {
			editor.active = !editor.active
		}

		if rl.IsWindowResized() {
			cleanup_renderer(&renderer)
			renderer = init_renderer(320, 180)
		}

		player_update(&world)

		if !editor.active {
			// Gameplay camera
			renderer.world_space_camera = {
				zoom   = 1,
				offset = {GAME_WIDTH / 2 - TILE_SIZE / 2, GAME_HEIGHT / 2 - TILE_SIZE / 2},
				target = {
					f32(world.player.position.x * TILE_SIZE),
					f32(world.player.position.y * TILE_SIZE),
				},
			}

		} else {
			update_editor(&editor, &world, &renderer)
		}

		// RENDERING
		rl.ClearBackground(rl.RED)

		rl.EndTextureMode()

		begin_world_rendering(&renderer)
		rl.ClearBackground(BACKGROUND)
		render_game(&world)

		if editor.active {
			if editor.show_grid {
				render_editor_grid(&renderer)
			}
			render_editor_preview(&editor, &renderer)
		}

		end_world_rendering(&renderer)


		rl.BeginDrawing()
		rl.ClearBackground(rl.RED)
		draw_to_screen(&renderer)


		if editor.active {
			render_editor_hud(&editor, &renderer)
		}

		rl.EndDrawing()
	}

	cleanup_renderer(&renderer)
	save_game(&world, "world.json")
	rl.CloseWindow()
}

player_update :: proc(world: ^World) {
	dir: [2]i32

	rl.IsGamepadAvailable(0)

	right :=
		rl.IsKeyPressed(.RIGHT) ||
		rl.IsKeyPressed(.D) ||
		rl.IsGamepadButtonPressed(0, .LEFT_FACE_RIGHT)

	left :=
		rl.IsKeyPressed(.LEFT) ||
		rl.IsKeyPressed(.A) ||
		rl.IsGamepadButtonPressed(0, .LEFT_FACE_LEFT)

	up :=
		rl.IsKeyPressed(.UP) || rl.IsKeyPressed(.W) || rl.IsGamepadButtonPressed(0, .LEFT_FACE_UP)

	down :=
		rl.IsKeyPressed(.DOWN) ||
		rl.IsKeyPressed(.S) ||
		rl.IsGamepadButtonPressed(0, .LEFT_FACE_DOWN)

	if right {dir = {1, 0}}
	if left {dir = {-1, 0}}
	if up {dir = {0, -1}}
	if down {dir = {0, 1}}

	if dir == {0, 0} do return

	new_pos := world.player.position + dir

	if entity, ok := get_entity_at_position(world, new_pos); ok && entity.type == .Box {
		box_new_pos := new_pos + dir

		if !is_position_blocked(world, box_new_pos) {
			entity.position = box_new_pos
			world.player.position = new_pos
		}
	} else {
		if !is_position_blocked(world, new_pos) {
			world.player.position = new_pos
		}
	}
}

is_position_blocked :: proc(world: ^World, pos: [2]i32) -> bool {
	for tile in world.tiles {
		if tile.position == pos && tile.type == .Wall {
			return true
		}
	}

	if entity, ok := get_entity_at_position(world, pos); ok {
		if entity.type == .Box {
			return true
		}
	}

	return false
}

get_entity_at_position :: proc(world: ^World, pos: [2]i32) -> (^Entity, bool) {
	if world.player.position == pos {
		return &world.player, true
	}

	for &entity in world.entities {
		if entity.position == pos {
			return &entity, true
		}
	}

	return nil, false
}

render_game :: proc(world: ^World) {
	for tile in world.tiles {
		rl.DrawTexture(
			world.assets.tile_textures[tile.type],
			tile.position.x * TILE_SIZE,
			tile.position.y * TILE_SIZE,
			rl.WHITE,
		)
	}

	for entity in world.entities {
		rl.DrawTexture(
			world.assets.entity_textures[entity.type],
			entity.position.x * TILE_SIZE,
			entity.position.y * TILE_SIZE,
			rl.WHITE,
		)
	}

	rl.DrawTexture(
		world.assets.entity_textures[world.player.type],
		world.player.position.x * TILE_SIZE,
		world.player.position.y * TILE_SIZE,
		rl.WHITE,
	)
}
