class_name Dispatcher
extends NavigationRegion3D



var houses_to_order:Array[Node3D] = []
var orders_address:Array[Node3D] = []

@onready var restaurants_list: Node = $RestaurantsList
@onready var houses_list: Node = $HousesList


	
var order_count:int = 0

var orders_queue :Array[CustomerOrder]= []
var orders_in_progress :Array[CustomerOrder] = []
var orders_complete :Array[CustomerOrder] = [] 

var time_per_day = 60.0
var curr_time = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for e in houses_list.houses:
		houses_to_order.append(e)
		
var first_time = true
var order_timer = 0.0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if first_time:
		first_time = false

	curr_time += delta
	order_timer += delta
	if curr_time > time_per_day:
		clear_lists()
	if order_timer > 0.5:
		order_timer = 0.0
		random_order()

func random_order():

	var house :House= houses_to_order.pick_random()
	house.order_id = order_count
	
	var new_order:CustomerOrder = CustomerOrder.new()
	new_order.order_id = order_count
	new_order.house_id = house.id
	new_order.delivery_address = house.get_address()
	
	# needs refactoring below
	new_order.rest_id = randi_range(0, restaurants_list.restaurants.size()-1)
	var restaurant = restaurants_list.get_restaurant(new_order.rest_id)
	new_order.collection_address =restaurant.get_address()

	restaurant.orders.append(new_order.order_id)
	
	orders_queue.append(new_order)

	orders_address.append(house)
	houses_to_order.erase(house)
	order_count += 1
	
func complete_order(order_id:int):
	var ocount = 0
	var order_found = false
	for e in orders_in_progress:
		if e.order_id == order_id:
			order_found = true
			break
		ocount += 1
	if order_found:
		var order = orders_in_progress.get(ocount)
		orders_in_progress.erase(order)
		orders_complete.append(order)
	
		
		
func get_order():
	if orders_queue.size() > 0:
		var order = orders_queue.get(0)		
	
		orders_queue.erase(order)
		orders_in_progress.append(order)
		return order
	return null

func clear_lists():
	for e in orders_address:
		houses_to_order.append(e)
		
	orders_address.clear()
	
