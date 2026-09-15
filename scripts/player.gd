extends CharacterBody3D
var peer_id:int=1
var is_local:=false
var role:="hider"
var hidden:=false
var caught:=false
@export var speed:=4.5
@export var run_speed:=7.0
var gravity:=18.0
@onready var camera=$Camera3D
@onready var mesh=$Mesh

func _ready():
    if not is_local:
        $Camera3D.current=false
    else:
        camera.current=true
    if role=="seeker":
        $Role.text="EBE"
    else:
        $Role.text="SAKLANAN"

func look_by(d:Vector2):
    if not is_local: return
    rotate_y(-d.x*0.004)
    camera.rotate_x(-d.y*0.004)
    camera.rotation.x=clamp(camera.rotation.x,deg_to_rad(-70),deg_to_rad(70))

func _physics_process(delta):
    if not is_local or caught: return
    if not is_on_floor(): velocity.y-=gravity*delta
    var v=Input.get_vector("left","right","forward","back")
    var dir=(transform.basis*Vector3(v.x,0,v.y)).normalized()
    var s=run_speed if Input.is_action_pressed("run") else speed
    if dir:
        velocity.x=dir.x*s; velocity.z=dir.z*s
    else:
        velocity.x=move_toward(velocity.x,0,s*2*delta); velocity.z=move_toward(velocity.z,0,s*2*delta)
    move_and_slide()
    if multiplayer.has_multiplayer_peer():
        sync_position.rpc(global_position,rotation.y)

@rpc("any_peer","unreliable")
func sync_position(pos:Vector3,rot:float):
    if multiplayer.get_remote_sender_id()!=peer_id: return
    if is_local: return
    global_position=pos
    rotation.y=rot

@rpc("authority","call_local","reliable")
func set_hidden_state(value:bool,is_caught:bool):
    hidden=value
    caught=is_caught
    $Mesh.visible=not hidden
    $Role.visible=not hidden
