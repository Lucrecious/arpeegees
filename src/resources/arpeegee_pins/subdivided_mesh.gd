tool
class_name SubdividedQuadMeshInstance
extends MeshInstance2D

export(int, 1, 100) var resolution_x := 4 

export(bool) var generate_mesh := false setget _generate_mesh_set
func _generate_mesh_set(value: bool) -> void:
	if not value:
		return
	
	var dense_mesh := _generate_mesh(texture)
	mesh = dense_mesh

func _generate_mesh(texture: Texture) -> Mesh:
	if not texture:
		return null
	
	if Rect2(Vector2.ZERO, texture.get_size()).has_no_area():
		return null
	
	var rows := resolution_x
	var size := texture.get_size()
	var columns := round(size.y / (size.x / resolution_x))
	
	var surface_tool := SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var cell_size := Vector2(1.0 / columns, 1.0 / rows)
	var size3 := Vector3(size.x, size.y, 0)
	
	for r in rows:
		for c in columns:
			var u := float(cell_size.x * c)
			var v := float(cell_size.y * r)
			
			surface_tool.add_uv(Vector2(u, v))
			surface_tool.add_vertex(Vector3(u, v, 0) * size3)
			
			surface_tool.add_uv(Vector2(u + cell_size.x, v))
			surface_tool.add_vertex(Vector3(u + cell_size.x, v, 0) * size3)
			
			surface_tool.add_uv(Vector2(u + cell_size.x, v + cell_size.y))
			surface_tool.add_vertex(Vector3(u + cell_size.x, v + cell_size.y, 0) * size3)
			
			surface_tool.add_uv(Vector2(u + cell_size.x, v + cell_size.y))
			surface_tool.add_vertex(Vector3(u + cell_size.x, v + cell_size.y, 0) * size3)
			
			surface_tool.add_uv(Vector2(u, v + cell_size.y))
			surface_tool.add_vertex(Vector3(u, v + cell_size.y, 0) * size3)
			
			surface_tool.add_uv(Vector2(u, v))
			surface_tool.add_vertex(Vector3(u, v, 0) * size3)
	
	surface_tool.index()
	var mesh := surface_tool.commit()
	
	return mesh
	
