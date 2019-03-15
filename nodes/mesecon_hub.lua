-- GENERATED CODE
-- Node Box Editor, version 0.9.0
-- Namespace: test

minetest.register_node("test:node_1", {
	tiles = {
		"top.bus.base.png",
		"bottom.base.png",
		"side.base.png",
		"side.base.png",
		"side.base.png",
		"side.base.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.375, -0.5, -0.375, 0.375, -0.3125, 0.375}, -- NodeBox1
			{-0.25, -0.5, -0.5, 0.25, -0.375, 0.5}, -- NodeBox2
			{-0.5, -0.5, -0.25, 0.5, -0.375, 0.25}, -- NodeBox3
		}
	}
})

