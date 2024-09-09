extends Manager
#class_name PipeManager 

var pipe_groups: Dictionary

@onready var _readied := false

#func _process(delta):
	#print("PipeManager | Process Start")
	#if not _readied:
		#print("PipeManager | Not Readied")
		#_fill_Dictionary()
		#if pipe_groups:
		#	_readied = true
		#	set_process(false)

func get_Next(pipe: Pipe) -> Pipe:
	if pipe_groups.has(pipe.PipeGroup):
		var group = pipe_groups[pipe.PipeGroup] as Array[Pipe]
		var index = pipe.PipeOrder
		index = (index + 1) % group.size()
		return group[index] 
	return null

func addPipe(pipe: Pipe):
	var group := [] as Array[Pipe]
	var index := pipe.PipeOrder
	if pipe_groups.has(pipe.PipeGroup):
		group = pipe_groups[pipe.PipeGroup] as Array[Pipe]
	if not index < 0:
		if group.size() <= index:
			group.resize(index + 1)
		group[index] = pipe
	else:
		group.append(pipe)
		pipe.PipeOrder = group.size() - 1
	pipe_groups[pipe.PipeGroup] = group
	print("PipeManager | Pipe added: ", pipe, ", in PipeGroup: ", pipe.PipeGroup, " | Group Content: ", pipe_groups[pipe.PipeGroup])

'''
func _fill_Dictionary():
	var pipes = get_tree().get_nodes_in_group("Pipe")
	var idCount = 0
	for pipe in pipes:
		if pipe is Pipe:
			
			pipe.ID = idCount
			idCount += 1
			pipe.manager = self
			
			var group := [] as Array[Pipe]
			if pipe_groups.has(pipe.PipeGroup):
				group = pipe_groups[pipe.PipeGroup] as Array[Pipe]
			group.append(pipe)
			pipe_groups[pipe.PipeGroup] = group
'''

func reset():
	pipe_groups.clear()
	#_readied = false
	#set_process(true)

func update():
	pass
