-- GENERATED CODE
-- Node Box Editor, version 0.9.0
-- Namespace: test

minetest.register_node("test:node_1", {
	tiles = {
		"top.extractor.png",
		"top.extractor.png",
		"side.extractor.png",
		"side.extractorf.png",
		"side.extractor.png",
		"side.extractorf.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0.375, 0.5}, -- NodeBox1
			{-0.375, 0.375, -0.375, 0.375, 0.5, 0.375}, -- NodeBox2
		}
	}
})

