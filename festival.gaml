/***
* Name: festival
* Author: adam, pavlos
* Description: 
* 	Festival simulation with:
* 		5 Agents: Guest, Security, BadGuest, Performer, Journalist
* 		4 locations: Stage, Bar, Kiosk, Tent, Backstage
* 	Tracking Agents happiness
***/

model festival

global
{
	int numberOfGuests <- 10;
	int numberOfSecurity <- 2;
	int numberOfBadguests <- 2;
	int numberOfPerformers <- 2;
	int numberOfJournalists <- 1;
	int numberOfStages <- 1;
	int numberOfBars <- 1;
	int numberOfKiosks <- 1;
	int numberOfTents <- 1;
	int numberOfBackstages <- 1;
	list<point> stageLocations <- [{5,5},{95,5},{95,95},{5,95}];
	init
	{
		create guest number: numberOfGuests{
			headColor <- #black;
			bodyColor <- #green;
		}
		create security number: numberOfSecurity{
			headColor <- #black;
			bodyColor <- #blue;
		}
		create badguest number: numberOfBadguests{
			headColor <- #black;
			bodyColor <- #red;
		}
		create performer number: numberOfPerformers{
			headColor <- #gold;
			bodyColor <- #gold;
		}
		create journalist number: numberOfJournalists{
			headColor <- #grey;
			bodyColor <- #brown;
		}
		create stage number: numberOfStages{
			areaSize <- 18;
			buildingSize <- 6;
			buildingColor <- #silver;
			areaColor <- #yellow;
			location <- {50,0};
		}
		create bar number: numberOfBars{
			areaSize <- 12;
			buildingSize <- 6;
			buildingColor <- #orange;
			areaColor <- #yellow;
			location <- {0,50};
		}
		create kiosk number: numberOfKiosks{
			areaSize <- 12;
			buildingSize <- 6;
			buildingColor <- #darkgreen;
			areaColor <- #yellow;
			location <- {100,50};
		}
		create tent number: numberOfTents{
			areaSize <- 0;
			buildingSize <- 4;
			buildingColor <- #magenta;
			areaColor <- #yellow;
			location <- {50,100};
		}
		create backstage number: numberOfBackstages{
			areaSize <- 12;
			buildingSize <- 0;
			buildingColor <- #orange;
			areaColor <- #maroon;
			location <- {0,0};
		}
	}
}

// Parent of agents:
species person skills: [moving, fipa] control: simple_bdi
{
	int happiness;
	int hunger;
	int thirst;
	int tired;
	rgb headColor;
	rgb bodyColor;
	
	init{
		location <- {rnd(0,100),rnd(0,100)};
		happiness <- rnd(0,100);
		hunger <- rnd(0,100);
		thirst <- rnd(0,100);
		tired <- rnd(0,100);
	}
	
	aspect default{
		draw sphere(1) color: headColor at:{location.x,location.y,3};
		draw cube(3) color: bodyColor;
	}
}
// Agents:
species guest parent: person 
{
	predicate thirst_predicate <- new_predicate("is thirsty", true);
	predicate hunger_predicate <- new_predicate("is hungry", true);
	predicate drink <- new_predicate("get_drink", false);
	predicate eat <- new_predicate("get_food", false);
	
	perceive target:self {
		if(thirst>50){
			do add_belief(thirst_predicate);
		}
		if(thirst<40){
			do remove_belief(thirst_predicate);
		}
		if(hunger>50){
			do add_belief(hunger_predicate);
		}
		if(hunger<40){
			do remove_belief(hunger_predicate);
		}
	}
	
	rule belief: thirst_predicate new_desire: drink strength:10.0;
	rule belief: hunger_predicate new_desire: eat strength:9.0;
	
	plan getDrink intention: drink {
 		do wander;
 		write name + " is getting a drink, " + thirst + ", " + hunger;
	}
	plan getFood intention: eat {
 		bodyColor <- #black;
 		write name + " is getting food, " + thirst + ", " + hunger;
	}
}

species security parent: person
{
	
}

species badguest parent: person
{
	
}

species performer parent: person
{
	
}

species journalist parent: person
{
	
}

// Parent of locations: 
species place skills: [moving]
{
	int areaSize;
	int buildingSize;
	rgb buildingColor;
	rgb areaColor;
	
	aspect default{
		draw square(areaSize) color: areaColor at:{location.x,location.y,0};
		draw cube(buildingSize) color: buildingColor;
	}
}

// Locations:
species stage parent: place
{
	
}

species bar parent: place
{
	
}

species kiosk parent: place
{
	
}

species backstage parent: place
{
	
}

species tent parent: place
{
	
}

// GUI: 
experiment main type: gui 
{
	output {
		display map type: opengl{
			species guest;
			species security;
			species badguest;
			species performer;
			species journalist;
			species stage;
			species bar;
			species kiosk;
			species tent;
			species backstage;
		}
	}
}

