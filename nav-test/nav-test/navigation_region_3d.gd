class_name Dispatcher
extends NavigationRegion3D



var ready_customers:Array[Node3D] = []
var busy_customers:Array[Node3D] = []

@onready var restaurants_list: Node = $RestaurantsList
@onready var houses_list: Node = $HousesList

@onready var label: Label = %Label
@onready var label_2: Label = %Label2
@onready var label_3: Label = %Label3

	
var order_count:int = 0

var orders_queue :Array[CustomerOrder]= []
var orders_in_progress :Array[CustomerOrder] = []
var orders_complete :Array[CustomerOrder] = [] 

var time_per_day = 60.0
var curr_time = 0.0

var first_time = true
var order_timer = 0.0


#========================================================================	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for e in houses_list.houses:
		ready_customers.append(e)

#========================================================================			
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	curr_time += delta
	order_timer += delta
	
	label.text = "Orders Complete: " + var_to_str(orders_complete.size())
	label_2.text = "Order Queue: " + var_to_str(orders_queue.size())
	label_3.text = "Orders in progress: " + var_to_str(orders_in_progress.size())
	
	if order_timer > 1.5:
		order_timer = 0.0
		if ready_customers.size() > 0:
			random_order()

#========================================================================	
func random_order():
	var random_num = randi_range(0, ready_customers.size()-1) 
	
	var house :House=  ready_customers.get(random_num)
	
	house.order_id = order_count
	
	var new_order:CustomerOrder = CustomerOrder.new()
	new_order.order_id = order_count
	new_order.house_id = house.id
	new_order.delivery_address = house.get_address()
	
	# needs refactoring below
	new_order.rest_id = randi_range(0, restaurants_list.count-1)
	var restaurant = restaurants_list.get_restaurant(new_order.rest_id)
	new_order.collection_address = restaurant.get_address()

	restaurant.orders.append(new_order.order_id)
	
	orders_queue.append(new_order)

	busy_customers.append(house)
	ready_customers.erase(house)
	order_count += 1
	
#========================================================================		
func get_house_from_busy_list(house_id:int):
	var the_house = null
	for house in busy_customers:
		if (house as House).id == house_id:
			the_house = house
			
	return the_house
	
#========================================================================		
func complete_order(order_id:int):

	var order_found = false
	var order:CustomerOrder = null
	for e in orders_in_progress:
		if e.order_id == order_id:
			order_found = true
			order = e
			break
		
	if order_found:
		orders_in_progress.erase(order)
		orders_complete.append(order)
		var house = get_house_from_busy_list(order.house_id)
		busy_customers.erase(house)
		ready_customers.append(house)
		
#========================================================================		
func get_order():
	if orders_queue.size() > 0:
		var order = orders_queue.get(0)		

		orders_queue.erase(order)
		orders_in_progress.append(order)
		return order
	return null


	
