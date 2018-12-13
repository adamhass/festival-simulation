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
	int numberOfGuests <- 30;
	int numberOfSecurity <- 2;
	int numberOfBadguests <- 10;
	int numberOfPerformers <- 4;
	int numberOfJournalists <- 2;
	int numberOfStages <- 1;
	int numberOfBars <- 1;
	int numberOfKiosks <- 1;
	int numberOfTents <- 1;
	int numberOfBackstages <- 1;
	list<point> stageLocations <- [{5,5},{95,5},{95,95},{5,95}];
	point campingLocations <- {50,75};
	point backstageLocation <- {0,0};
	init
	{

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
		create camping number: 1{
			areaSize <- 50;
			buildingSize <- 0;
			buildingColor <- #magenta;
			areaColor <- #brown;
			location <- campingLocations;
		}
		create backstage number: numberOfBackstages{
			areaSize <- 12;
			buildingSize <- 0;
			buildingColor <- #orange;
			areaColor <- #maroon;
			location <- backstageLocation;
		}
		create guest number: numberOfGuests{
			headColor <- #black;
			bodyColor <- #green;
			campingLocation <- campingLocations;
		}
		create security number: numberOfSecurity{
			headColor <- #black;
			bodyColor <- #blue;
			sleepLocation <- backstageLocation;
		}
		create badguest number: numberOfBadguests{
			headColor <- #black;
			bodyColor <- #red;
			campingLocation <- campingLocations;
		}
		create performer number: numberOfPerformers{
			headColor <- #gold;
			bodyColor <- #gold;
			sleepLocation <- backstageLocation;
		}
		create journalist number: numberOfJournalists{
			headColor <- #grey;
			bodyColor <- #brown;
			sleepLocation <- backstageLocation;
		}
	}
	

	int guestHappiness;
	int totalHappiness;
	int performerHappiness;
	int journalistHappiness;
	int securityHappiness;
	int badguestHappiness;
	
	reflex chartValues when: time mod 5 = 0
	{
		guestHappiness <- guest sum_of each.happiness;
		totalHappiness <- person sum_of each.happiness;
		performerHappiness <- performer sum_of each.happiness;
		journalistHappiness <- journalist sum_of each.happiness;
		securityHappiness <- security sum_of each.happiness;
		badguestHappiness <- badguest sum_of each.happiness;
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
	// Store locations for where to eat, sleep and drink:
	list<place> foodLocations;
	list<place> drinkLocations;
	point campingLocation <- nil;
	point sleepLocation <- nil;
	point stageLocation <- nil;
	place targetBar <- nil;
	place targetKiosk <- nil;
	point target_point <- {rnd(100),rnd(100)};
	bool sleeping <- false;
	
	
	// Initialize random needs
	init{
		location <- {rnd(0,100),rnd(0,100)};
		happiness <- rnd(0,100);
		hunger <- rnd(0,50);
		thirst <- rnd(0,50);
		tired <- rnd(0,50);
		foodLocations <- list(kiosk);
		drinkLocations <- list(bar);
		stageLocation <- first(list(stage)).location;
		do add_belief(idle_predicate);
	}
	
	// Increase the needs by time:
	reflex when: true=true {
		if ((time mod 10) = 0){
		//	write "increase hunger";
			hunger <- hunger+1;
//			happiness <- happiness -1;
		}
		if ((time mod 5) = 0 ){
		//	write "increase thirst";
			thirst <- thirst+1;
//			happiness <- happiness -1;	
		}
		if ((time mod 30) = 0) and !sleeping {
		//	write "increase tired";
			tired <- tired+1;
			happiness <- happiness -1;
		}
	}
	
	reflex reduceHappiness when: (hunger > 100 or thirst > 100 or tired > 100) and time mod 10 and !sleeping{
		happiness <- happiness - 1;
	}
	
	// Draw on map
	aspect default{
		draw sphere(1) color: headColor at:{location.x,location.y,location.z+3};
		draw cube(3) color: bodyColor;
	}
	
	// Predicates and perception of Eat Sleep Drink needs, shared among all persons
	predicate thirst_predicate <- new_predicate("is thirsty", true);
	predicate hunger_predicate <- new_predicate("is hungry", true);
	predicate sleep_predicate <- new_predicate("is sleepy", true);
	predicate happy_predicate <- new_predicate("is unhappy", true);
	predicate idle_predicate <- new_predicate("want to idle", true);
	predicate becomeHappy <- new_predicate("do_something_to_become_happy", false);
	predicate drink <- new_predicate("get_drink", false);
	predicate eat <- new_predicate("get_food", false);
	predicate sleep <- new_predicate("go_sleep", false);
	predicate idle <- new_predicate("go_wander", false);

	
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
		if(tired>50){
			do add_belief(sleep_predicate);
		}
		if(tired<40){
			do remove_belief(sleep_predicate);
		}
		if(happiness<50){
			do add_belief(happy_predicate);
		}
		if(happiness>70){
			do remove_belief(happy_predicate);
		}
	}
	
	rule belief: thirst_predicate new_desire: drink strength:10.0;
	rule belief: hunger_predicate new_desire: eat strength:9.0;
	rule belief: sleep_predicate new_desire: sleep strength:8.0;
	rule belief: happy_predicate new_desire: becomeHappy strength:7.0;
	rule belief: idle_predicate new_desire: idle strength: 1;

	plan goIdle intention: idle {
		do goto target:target_point speed: 3;
		if (location distance_to target_point < 3) {
			target_point <- {rnd(0,100),rnd(0,100)};
		}
		do remove_intention(idle, true);
	}
	
	plan getDrink intention: drink {
 		if (targetBar = nil){
 			targetBar <- one_of(drinkLocations);
 		} else {
 			if(location distance_to targetBar.location > 3) {
 				do goto target:targetBar.location speed: 3;
 			} else {
 				thirst <- 0;
 				do remove_belief(thirst_predicate);
				do remove_intention(drink, true);
				targetBar <- nil;
 			}
 		}
	}
	plan getFood intention: eat {
 		if (targetKiosk = nil){
 			targetKiosk <- one_of(foodLocations);
 		} else {
 			if(location distance_to targetKiosk.location > 3) {
 				do goto target:targetKiosk.location speed: 3;
 			} else {
 				if (hunger > 1) {
 					if (time mod 3 = 0){
 						hunger <- hunger-1;
 					}
 				} else { 					
	 				do remove_belief(hunger_predicate);
					do remove_intention(eat, true);
					targetKiosk <- nil;
 				}
 			}
 		}
	}
	plan goSleep intention: sleep {
		// If no tent:
		if (sleepLocation = nil) {
			if (location distance_to campingLocation > 3) {
				do goto target:campingLocation speed: 3;				
			} else {
				ask camping at_distance 3 {
					point tentLocation <- one_of(self.tentSpaces);
					remove all: tentLocation from: self.tentSpaces;
					myself.sleepLocation <- tentLocation;
					write name + " is pitching a tent";
					create tent number: 1{
						areaSize <- 0;
						buildingSize <- 2;
						buildingColor <- #pink;
						areaColor <- #brown;
						location <- tentLocation;
					}
				}
			}
		} else {
			// Go to tent:
			if (location distance_to sleepLocation > 3) {
				do goto target:sleepLocation speed: 3;				
			} else {
				sleeping <- true;
				if ((time mod 10) = 0) {
					tired <- tired-1;					
				}
				if (tired < 1) {
					sleeping <- false;
					do remove_belief(sleep_predicate);
					do remove_intention(sleep, true);
				}
			}
		}
	}
	
}
// Agents:
species guest parent: person 
{
	bool wasPunched <- false;
	person attacker <- nil;
	
	plan goDance intention: becomeHappy{
		if (location distance_to stageLocation > 6) {
			do goto target:stageLocation speed: 3;
		} else {
			do wander;
			happiness <- happiness+1;
			if(!empty(informs)){
				loop i over:informs{
				 if (i.contents[0]='Music') and (int(i.contents[1])-time> -2) {
				 	happiness<-happiness+1;
				 	if(happiness>30){
				 	do start_conversation (to:: i.sender, protocol:: 'no-protocol', performative:: 'inform', contents:: ['Applause']); 	
				 	//write name + "i am applauding";
				 	}
				 }	
				}
			}
			if (happiness > 70 and (thirst < 40 or hunger < 40 or tired < 40)) {
				do remove_belief(happy_predicate);
				do remove_intention(becomeHappy, true);
			}
		}
	}
	
	predicate has_been_in_fight <- new_predicate("has been in fight", true);
	predicate reportBadguest <- new_predicate("report the bad guest", false);
	
	perceive target:self {
		if(attacker != nil){
			do add_belief(has_been_in_fight);
		}
	}
	
	rule belief: has_been_in_fight new_desire: reportBadguest strength:11;
	plan reportAttacker intention: reportBadguest{
		write name + " reporting " + attacker + " to security";
		do start_conversation (to:: list(security), protocol:: 'no-protocol', performative:: 'inform', contents:: ['Attacker', attacker.name]);
		attacker <- nil;
		do remove_belief(has_been_in_fight);
		do remove_intention(reportBadguest, true);
	}
	
	
}

species badguest parent: person
{
	list<guest> guestToFight <- nil;
	
	plan fight intention: becomeHappy{
		ask guest at_distance 3 {
			if myself.happiness < self.happiness and flip(0.5){			
				myself.guestToFight <- myself.guestToFight + self;
			}
		}
		if (guestToFight != nil) {
			ask one_of(guestToFight){
				write myself.name + " fighting " + self.name;
				self.happiness <- self.happiness -40;
				self.attacker <- myself;
				myself.happiness <- myself.happiness + 40;
				self.current_plan <- nil;
			}
			do remove_belief(happy_predicate);
			do remove_intention(becomeHappy, true);
			guestToFight <- nil;
		} else {
			do goto target:stageLocation speed: 3;
		}
	}
}

species security parent: person
{
	point target_point <- {rnd(0,100),rnd(0,100)};
	list<string> guestsToArrest;
	list<string> arrested <- [];
	list<string> justArrested <- [];
	
	perceive target:self{
		if !empty(informs){
			loop i over: informs{
				if (i.contents[0] = "Attacker"){
					guestsToArrest <- guestsToArrest + i.contents[1];
					do add_belief(BadguestReported);
				}
				if (i.contents[0] = "Arrested"){
					arrested <- arrested + i.contents[1];
				}
			}
		}
	}
	
	predicate BadguestReported <- new_predicate("Someone has to be arrested", true);
	predicate arrestBadguest <- new_predicate("Arrest badguest", false);
	
	rule belief: BadguestReported new_desire: arrestBadguest strength:7.0;
	reflex when: empty(guestsToArrest){
		if (hunger < 50 and thirst < 50 and tired < 50 and time mod 30){
			happiness <- happiness +1;
		}
	}
	plan findBadguest intention: arrestBadguest{
		
		ask badguest at_distance 9 {
//			write myself.name + " asking " + self.name;
			if (myself.guestsToArrest contains self.name){
				//remove all: self from: myself.guestsToArrest; 
				write myself.name + " arrested " + self.name;
				myself.justArrested <- myself.justArrested + self.name;
				do die;
			}
		}
		// Inform other security that bad guy has been arrested
		if(!empty(justArrested)) {
			loop a over: justArrested{
				write name + " informing that I arrested " + a;
				do start_conversation (to:: list(security), protocol:: 'no-protocol', performative:: 'inform', contents:: ['Arrested',a]);
			}
		}
		
		// Check messages from other security
//		if(!empty(informs)){
//			loop i over: informs {
//				if (i.contents[0] = "Arrested"){
//					arrested <- arrested + i.contents[1];
//				}
//				if (i.contents[0] = "Attacker"){
//					guestsToArrest <- guestsToArrest + i.contents[1];
//				}
//			}
//		}
		arrested <- arrested + justArrested;
		loop a over: arrested{
			if (guestsToArrest contains a) {
				remove all: a from: guestsToArrest;
			}
		}
		justArrested <- [];
		if empty(guestsToArrest) {
			write "arrested all badguys";
			happiness <- happiness + 40;
			do remove_belief(BadguestReported);
			do remove_intention(arrestBadguest, true);
		} else {
			do goto target:target_point speed: 3;
			if (location distance_to target_point < 3) {
				target_point <- {rnd(0,100),rnd(0,100)};
			}
		}
	}
}



species performer parent: person
{
		float performer_start<-0;
		
		plan goPerform intention: becomeHappy{
			if (location distance_to stageLocation > 6) {
				do goto target:stageLocation speed: 3;
			} 
			else
			{
				if (performer_start=0)
				{
					performer_start<-time;
					write "starting performance " + time ; 
				}
				location<-{stageLocation.x,stageLocation.y,5};
			//	write "perofmer at stage";
			 
				loop k over:informs{
					if(k.contents[0]='Applause')
					{
						happiness<-happiness+1;
					}
				}
				if(performer_start+120=time)
				{
					do start_conversation (to:: list(journalist), protocol:: 'no-protocol', performative:: 'inform', contents:: ['Done',time]);
					write "performer is DONE: " + time;
					performer_start<-0;
					do remove_belief(happy_predicate);
					do remove_intention(becomeHappy, true);
				}
				else
				{
					if(time mod 3=0 and !empty(list(guest at_distance 9))){
						do start_conversation (to:: list(guest at_distance 9 )+list(journalist at_distance 9), protocol:: 'no-protocol', performative:: 'inform', contents:: ['Music',time]);
						
					}
				}
			}
		}
		
}

species journalist parent: person
{
	performer performer_interview<-nil;
	point performer_location<-nil;
	int number_of_questions<-5;
	
	plan goInterview intention: becomeHappy{
		if (location distance_to stageLocation > 6 and performer_interview =nil) {
			do goto target:stageLocation speed: 3;
		}
		else {
			if(hunger > 80 or thirst > 80 or tired > 80){
				do remove_belief(happy_predicate);
				do remove_intention(becomeHappy, true);
			}
			loop i over:informs	
			{
				if(i.contents[0]='Done' and time-int(i.contents[1])<2)
				{
					performer_interview<-i.sender;
				}
				if(i.contents[0]='Music' and time-int(i.contents[1])<2)
				{
					happiness <- happiness + 5;
				}
			}
			if(performer_interview!=nil){			
				ask performer_interview
				{
					myself.performer_location<-self.location;					
				}
					
					do goto target:performer_location speed:3;
					if number_of_questions>0{
						write "Asking question: " + time + " " + number_of_questions;
						ask performer_interview  {
							
							myself.number_of_questions<- myself.number_of_questions-1;
							myself.happiness<-myself.happiness+10;
						}
					}
					else {
						performer_interview<-nil;
						performer_location<-nil;
						number_of_questions<-5;
						write 	"i manage to ask 5 questions";			
						do remove_belief(happy_predicate);
						do remove_intention(becomeHappy, true);
						
					}
			}
		}
			
		}
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

// Location for tents
species camping parent: place
{
	list<point> tentSpaces;
	init {
		areaSize <- 50;
		location <- {50,75};
		loop i over: -(areaSize/2) to (areaSize/2) {
			if (i mod 4 = 0) {
				loop j over: -(areaSize/2) to (areaSize/2) {
					if (j mod 4 = 0) {
						tentSpaces <- tentSpaces + {location.x+i,location.y+j};
					}	
				}				
			}	
		}
	}
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
			species camping;
		}
		display chart refresh:every(5#cycles) {		
			chart "Happiness" type: series {
			//	data "totalHappiness" value: totalHappiness;
				data "guestHappiness" value: guestHappiness;
				data "performerHappiness" value: performerHappiness;
				data "journalistHappiness" value: journalistHappiness;
				data "securityHappiness" value: securityHappiness;
				data "badguestHappiness" value: badguestHappiness;
			}
		}
	}
}

