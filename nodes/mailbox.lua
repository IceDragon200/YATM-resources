-- GENERATED CODE
-- Node Box Editor, version 0.9.0
-- Namespace: test

minetest.register_node("test:node_1", {
	tiles = {
		"top.base.png",
		"top.base.png",
		"side.base.png",
		"side.base.png",
		"back.base.png",
		"front.base.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.375, -0.5, -0.4375, 0.375, 0.25, 0.4375}, -- NodeBox1
			{-0.375, -0.5, -0.5, -0.3125, 0.25, -0.4375}, -- NodeBox2
			{0.3125, -0.5, -0.5, 0.375, 0.25, -0.4375}, -- NodeBox4
			{-0.3125, 0.1875, -0.5, 0.3125, 0.25, -0.4375}, -- NodeBox5
			{-0.3125, 0.1875, 0.4375, 0.3125, 0.25, 0.5}, -- NodeBox6
			{0.3125, -0.5, 0.4375, 0.375, 0.25, 0.5}, -- NodeBox7
			{-0.375, -0.5, 0.4375, -0.3125, 0.25, 0.5}, -- NodeBox8
		}
	}
})

