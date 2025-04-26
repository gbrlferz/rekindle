package game

import rl "vendor:raylib"

box, torch: Entity

box_texture, torch_texture: rl.Texture2D

Entity :: struct {
	position: rl.Vector2,
	type:     Entity_Type,
	sprite:   rl.Texture2D,
	solid:    bool,
}

Entity_Type :: enum {
	Empty,
	Player,
	Wall,
	Box,
	Torch,
}

load_entity_textures :: proc() {
	box_texture = rl.LoadTexture("textures/box.png")
	torch_texture = rl.LoadTexture("textures/torch.png")

	box = Entity {
		type   = .Box,
		sprite = box_texture,
		solid  = true,
	}

	torch = Entity{{2, 2}, .Torch, torch_texture, true}
}
