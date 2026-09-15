extends CanvasLayer
@onready var game=get_parent()
@onready var player=get_node("../Player_%s" % multiplayer.get_unique_id()) if multiplayer.has_multiplayer_peer() else null
var move_id=-1
var look_id=-1
var start=Vector2.ZERO
var mv=Vector2.ZERO
var last=Vector2.ZERO

func _ready():
    var hide_btn = get_node_or_null("Controls/Hide")
    var host_btn = get_node_or_null("Controls/Host")
    var join_btn = get_node_or_null("Controls/Join")
    var run_btn = get_node_or_null("Controls/Run")
    if hide_btn: hide_btn.pressed.connect(_on_hide_pressed)
    if host_btn: host_btn.pressed.connect(_on_host_pressed)
    if join_btn: join_btn.pressed.connect(_on_join_pressed)
    if run_btn:
        run_btn.button_down.connect(_on_run_down)
        run_btn.button_up.connect(_on_run_up)

func _process(_d):
    if not player:
        player=get_node_or_null("../Player_%s" % multiplayer.get_unique_id())
    set_action("forward",mv.y < -0.25)
    set_action("back",mv.y > 0.25)
    set_action("left",mv.x < -0.25)
    set_action("right",mv.x > 0.25)

func _input(e):
    if e is InputEventScreenTouch:
        if e.pressed:
            if e.position.x<get_viewport().size.x*0.45 and move_id==-1:
                move_id=e.index; start=e.position
            elif e.position.x>=get_viewport().size.x*0.45:
                look_id=e.index; last=e.position
        else:
            if e.index==move_id: move_id=-1; mv=Vector2(); $Controls/Joystick/Knob.position=Vector2.ZERO
            if e.index==look_id: look_id=-1
    elif e is InputEventScreenDrag:
        if e.index==move_id:
            mv=(e.position-start).limit_length(65)/65
            $Controls/Joystick/Knob.position=mv*48
        elif e.index==look_id and player:
            player.look_by(e.position-last); last=e.position

func set_action(a,on):
    if on and not Input.is_action_pressed(a): Input.action_press(a)
    elif not on and Input.is_action_pressed(a): Input.action_release(a)

func _on_hide_pressed():
    if game.multiplayer.has_multiplayer_peer(): game.request_hide.rpc_id(1)

func _on_host_pressed(): game.host_game()
func _on_join_pressed():
    var ip=$Controls/IP.text
    if ip=="": ip="127.0.0.1"
    game.join_game(ip)

func _on_run_down(): Input.action_press("run")
func _on_run_up(): Input.action_release("run")
