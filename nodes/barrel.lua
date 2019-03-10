-- GENERATED CODE
-- Node Box Editor, version 0.9.0
-- Namespace: test

minetest.register_node("test:node_1", {
	tiles = {
		"top.base.png",
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
			{-0.4375, -0.4375, -0.4375, 0.4375, 0.4375, 0.4375}, -- NodeBox1
			{-0.5, -0.5, -0.5, 0.5, 0.5, -0.4375}, -- NodeBox2
			{-0.5, -0.5, 0.4375, 0.5, 0.5, 0.5}, -- NodeBox3
			{-0.5, -0.5, -0.5, -0.4375, 0.5, 0.5}, -- NodeBox4
			{0.4375, -0.5, -0.5, 0.5, 0.5, 0.5}, -- NodeBox5
		}
	}
})

