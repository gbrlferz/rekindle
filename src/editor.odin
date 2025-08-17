package sokoban

import "core:encoding/json"
import "core:math"
import "core:os"
import rl "vendor:raylib"

Editor :: struct {
	active:          bool,
	assets:          ^Assets,
	selected_tile:   TileType,
	selected_entity: EntityType,
	current_mode:    enum {
		Tiles,
		Entities,
	},
	show_grid:       bool,
}

init_editor :: proc(assets: ^Assets) -> Editor {
	return Editor {
		assets = assets,
		selected_tile = .Wall,
		selected_entity = .Player,
		current_mode = .Tiles,
		show_grid = true,
	}
}

update_editor :: proc(editor: ^Editor, world: ^World, renderer: ^Renderer) {
	if rl.IsKeyPressed(.TAB) {
		editor.current_mode = .Tiles if editor.current_mode == .Entities else .Entities
	}

	if editor.current_mode == .Tiles {
		if rl.IsKeyPressed(.ONE) do editor.selected_tile = .Wall
		if rl.IsKeyPressed(.TWO) do editor.selected_tile = .Floor
		if rl.IsKeyPressed(.THREE) do editor.selected_tile = .Goal
	}

	if editor.current_mode == .Entities {
		if rl.IsKeyPressed(.ONE) do editor.selected_entity = .Player
		if rl.IsKeyPressed(.TWO) do editor.selected_entity = .Box
	}

	if rl.IsKeyPressed(.G) {
		editor.show_grid = !editor.show_grid
	}

	if rl.IsMouseButtonDown(.LEFT) || rl.IsMouseButtonDown(.RIGHT) {
		grid_pos := get_grid_position_from_mouse(renderer)

		if rl.IsMouseButtonDown(.LEFT) {
			// Placement
			switch editor.current_mode {
			case .Tiles:
				remove_tile_at_position(world, grid_pos)
				append(&world.tiles, Tile{grid_pos, editor.selected_tile})

			case .Entities:
				remove_entity_at_position(world, grid_pos)
				if editor.selected_entity == .Player {
					world.player = Entity{grid_pos, .Player}
				} else {
					append(&world.entities, Entity{grid_pos, editor.selected_entity})
				}
			}
		} else if rl.IsMouseButtonDown(.RIGHT) {
			// Removal
			switch editor.current_mode {
			case .Tiles:
				remove_tile_at_position(world, grid_pos)
			case .Entities:
				remove_entity_at_position(world, grid_pos)
			}
		}
	}

	if rl.IsMouseButtonDown(.MIDDLE) || rl.IsKeyDown(.SPACE) {
		camera := &renderer.world_space_camera
		screen_delta := rl.GetMouseDelta()

		virtual_delta := rl.Vector2 {
			screen_delta.x * (f32(renderer.virtual_width) / f32(rl.GetScreenWidth())),
			screen_delta.y * (f32(renderer.virtual_height) / f32(rl.GetScreenHeight())),
		}

		delta := virtual_delta * (-1.0 / camera.zoom)

		camera.target += delta
		camera.target.x = math.round(camera.target.x)
		camera.target.y = math.round(camera.target.y)
	}

	// Camera Zoom
	wheel := rl.GetMouseWheelMove()
	if wheel != 0 {
		camera := &renderer.world_space_camera
		mouse_pos := get_virtual_mouse_position(renderer)
		mouse_world_pos := rl.GetScreenToWorld2D(mouse_pos, camera^)

		camera.offset = mouse_pos
		camera.target = mouse_world_pos

		scale := 0.2 * wheel
		camera.zoom = clamp(camera.zoom * math.exp(scale), 0.125, 64.0)
	}
}

get_grid_position_from_mouse :: proc(renderer: ^Renderer) -> [2]i32 {
	mouse_pos := get_virtual_mouse_position(renderer)
	mouse_world_pos := rl.GetScreenToWorld2D(mouse_pos, renderer.world_space_camera)
	return {
		i32(math.floor(mouse_world_pos.x / TILE_SIZE)),
		i32(math.floor(mouse_world_pos.y / TILE_SIZE)),
	}
}

remove_tile_at_position :: proc(world: ^World, position: [2]i32) {
	for i := len(world.tiles) - 1; i >= 0; i -= 1 {
		if world.tiles[i].position == position {
			unordered_remove(&world.tiles, i)
			break
		}
	}
}

remove_entity_at_position :: proc(world: ^World, position: [2]i32) {
	for i := len(world.entities) - 1; i >= 0; i -= 1 {
		if world.entities[i].position == position {
			unordered_remove(&world.entities, i)
		}

		if world.player.position == position {
			world.player = {}
		}
	}
}

render_editor_preview :: proc(editor: ^Editor, renderer: ^Renderer) {
	grid_pos := get_grid_position_from_mouse(renderer)
	world_pos := [2]f32{f32(grid_pos.x * TILE_SIZE), f32(grid_pos.y * TILE_SIZE)}

	color := rl.Color{255, 255, 255, 180}

	switch editor.current_mode {
	case .Tiles:
		texture := editor.assets.tile_textures[editor.selected_tile]
		rl.DrawTextureV(texture, world_pos, color)
	case .Entities:
		texture := editor.assets.entity_textures[editor.selected_entity]
		rl.DrawTextureV(texture, world_pos, color)
	}

	tile_pos := rl.TextFormat("%i, %i", grid_pos.x, grid_pos.y)
	rl.DrawText(tile_pos, i32(world_pos.x), i32(world_pos.y) - 10, 20, rl.WHITE)
}

render_editor_hud :: proc(editor: ^Editor, renderer: ^Renderer) {
	mode_text: cstring = editor.current_mode == .Tiles ? "TILE MODE" : "ENTITY MODE"
	rl.DrawText(mode_text, 10, 10, 20, rl.WHITE)

	selection: cstring

	switch editor.current_mode {
	case .Tiles:
		selection = rl.TextFormat("Selected: %s", editor.selected_tile)
	case .Entities:
		selection = rl.TextFormat("Selected: %s", editor.selected_entity)
	}

	rl.DrawText(selection, 10, 40, 20, rl.WHITE)

	// Controls help
	rl.DrawText("TAB: Switch mode", 10, rl.GetScreenHeight() - 60, 20, rl.LIGHTGRAY)
	rl.DrawText("1/2/3: Select item", 10, rl.GetScreenHeight() - 30, 20, rl.LIGHTGRAY)
	rl.DrawText("G: Toggle grid", 250, rl.GetScreenHeight() - 30, 20, rl.LIGHTGRAY)
}

render_editor_grid :: proc(renderer: ^Renderer) {
	camera := renderer.world_space_camera

	top_left := rl.GetScreenToWorld2D({0, 0}, camera)
	bottom_right := rl.GetScreenToWorld2D(
		{f32(renderer.virtual_width), f32(renderer.virtual_height)},
		camera,
	)

	start_x := i32(math.floor(top_left.x / TILE_SIZE)) - 1
	start_y := i32(math.floor(top_left.y / TILE_SIZE)) - 1
	end_x := i32(math.ceil(bottom_right.x / TILE_SIZE)) + 1
	end_y := i32(math.ceil(bottom_right.y / TILE_SIZE)) + 1

	grid_color := rl.Color{80, 80, 80, 100}

	for x in start_x ..= end_x {
		rl.DrawLine(
			i32(x * TILE_SIZE),
			i32(start_y * TILE_SIZE),
			i32(x * TILE_SIZE),
			i32(end_y * TILE_SIZE),
			grid_color,
		)
	}

	for y in start_y ..= end_y {
		rl.DrawLine(
			i32(start_x * TILE_SIZE),
			i32(y * TILE_SIZE),
			i32(end_x * TILE_SIZE),
			i32(y * TILE_SIZE),
			grid_color,
		)
	}
}

save_game :: proc(world: ^World, filename: string) -> bool {
	data, err := json.marshal(world^, json.Marshal_Options{use_enum_names = true})
	if err != nil {
		return false
	}

	return os.write_entire_file(filename, data)
}

load_game :: proc(world: ^World, filename: string) -> bool {
	data, ok := os.read_entire_file(filename, context.allocator)

	if !ok {
		return false
	}

	assets := world.assets

	err := json.unmarshal(data, world)
	if err != nil {
		return false
	}

	world.assets = assets
	return true
}
