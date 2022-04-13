import std.stdio;
import std.format;

import game : Game;

import bindbc.sfml;

import nudsfml.graphics.color;
import nudsfml.graphics.renderwindow;
import nudsfml.system;
import nudsfml.window.event;
import nudsfml.window.keyboard;
//


string gameVersion = "0.00.01";
string dataDir = "data/";

//handle loading and setting up configurations for the application

void main(){
	writeln(format("Zombie Survival: %s", gameVersion));

	if(!loadSFML()){
		writeln("failed to load sfml");
	}


	RenderWindow win = new RenderWindow;
	bool running = true;
	char i = 0;
	while(win.isOpen() && running){
		Event e;
		while(win.pollEvent(e)){
			switch(e.type){
				case Event.EventType.KeyPressed:
					if(e.key.code == Keyboard.Key.Escape){
						running = false;
					}
					break;
				default:
					break;
			}
		}
		
		win.clear(Color.Green);


		win.display();
	}
}
