extends Node3D

const PORT := 7777
const MAX_PLAYERS := 8
var players := {}
var seeker_peer := 1
var round_active := false
var time_left := 90.0

func _ready():
    multiplayer.peer_connected.connect(_on_peer_connected)
    multiplayer.peer_disconnected.connect(_on_peer_disconnected)
    if DisplayServer.get_name() == "headless":
        host_game()

func host_game():
    var peer=ENetMultiplayerPeer.new()
    var err=peer.create_server(PORT, MAX_PLAYERS)
    if err != OK:
        $UI/Status.text="Sunucu açılamadı: "+str(err)
        return
    multiplayer.multiplayer_peer=peer
    seeker_peer=multiplayer.get_unique_id()
    $UI/Status.text="ODA OLUŞTURULDU  | Port: %d\nDiğer cihazlar aynı IP ile bağlanabilir." % PORT
    _spawn_player(seeker_peer)
    start_round()

func join_game(ip:String):
    var peer=ENetMultiplayerPeer.new()
    var err=peer.create_client(ip,PORT)
    if err != OK:
        $UI/Status.text="Bağlanılamadı."
        return
    multiplayer.multiplayer_peer=peer
    $UI/Status.text="Bağlanılıyor..."

func _on_peer_connected(id):
    if multiplayer.is_server():
        _spawn_player(id)
        _sync_all.rpc(players)

func _on_peer_disconnected(id):
    if players.has(id):
        players.erase(id)
        if is_instance_valid(get_node_or_null("Player_%s" % id)):
            get_node("Player_%s" % id).queue_free()

func _spawn_player(id):
    if players.has(id): return
    players[id]={ "hidden":false, "caught":false, "role":"seeker" if id==seeker_peer else "hider" }
    var p=preload("res://Player.tscn").instantiate()
    p.name="Player_%s" % id
    p.position=Vector3(-7+(players.size()%4)*5,1,8+(players.size()/4)*-5)
    p.peer_id=id
    p.is_local=(id==multiplayer.get_unique_id())
    p.role=players[id].role
    add_child(p)

func start_round():
    round_active=true
    time_left=90.0
    $UI/Status.text="EBE: Oyuncu %s  |  Saklanmak için SAKLAN'a yaklaş." % seeker_peer

func _process(delta):
    if multiplayer.is_server() and round_active:
        time_left-=delta
        if time_left<=0:
            round_active=false
            $UI/Status.text="SÜRE BİTTİ! Saklananlar kazandı."
        else:
            $UI/Timer.text="Süre: %02d" % int(time_left)
    if multiplayer.is_server():
        for id in players:
            var p=get_node_or_null("Player_%s" % id)
            if p and players[id].role=="seeker" and not players[id].caught:
                for other in players:
                    if other==id: continue
                    var h=get_node_or_null("Player_%s" % other)
                    if h and not players[other].caught and players[other].hidden and p.global_position.distance_to(h.global_position)<1.8:
                        players[other].hidden=false
                        players[other].caught=true
                        h.set_hidden_state.rpc(false,true)
                        $UI/Status.text="EBE YAKALADI: Oyuncu %s" % other

@rpc("authority","call_local","reliable")
func _sync_all(state):
    players=state

@rpc("any_peer","reliable")
func request_hide():
    var id=multiplayer.get_remote_sender_id()
    if not players.has(id) or players[id].role=="seeker" or players[id].caught: return
    var p=get_node_or_null("Player_%s" % id)
    if not p: return
    var spot=null
    var best=999.0
    for s in get_tree().get_nodes_in_group("hide_spot"):
        var d=p.global_position.distance_to(s.global_position)
        if d<best and d<2.2:
            best=d; spot=s
    if spot:
        players[id].hidden=!players[id].hidden
        p.set_hidden_state.rpc(players[id].hidden,false)

@rpc("any_peer","reliable")
func request_catch(target_id:int):
    var id=multiplayer.get_remote_sender_id()
    if id!=seeker_peer or not players.has(target_id): return
    var seeker=get_node_or_null("Player_%s" % id)
    var target=get_node_or_null("Player_%s" % target_id)
    if seeker and target and seeker.global_position.distance_to(target.global_position)<2.2:
        players[target_id].hidden=false
        players[target_id].caught=true
        target.set_hidden_state.rpc(false,true)
