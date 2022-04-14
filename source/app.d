import std.stdio;
import std.format;

import game : Game;

import bindbc.sfml;

import nudsfml.graphics;
import nudsfml.window;
import nudsfml.system;


string gameVersion = "0.00.01";
string dataDir = "data/";

//handle loading and setting up configurations for the application

void main(){
	writeln(format("Zombie Survival: %s", gameVersion));

	if(!loadSFML()){
		writeln("failed to load sfml");
	}


	RenderWindow win = new RenderWindow(VideoMode(800, 600), "NudSFML Test");
	//win.setFramerateLimit(60);

	
	Font f = new Font();
	if(!f.loadFromFile("/Users/drifton/projects/nudsfml/data/CamingoCode-Regular.ttf")){
		writeln("failed to load font");
	}
	
	//writeln(f.sfPtr);

	Text t = new Text("Hello World", f);
	
	Vector2f speed = Vector2f(0.3f, 0.8f);
	Vector2f pos = Vector2f(0, 0);

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

		pos = pos + speed;

		if (pos.x > 800){
			speed.x = -speed.x;
			pos += speed *2;
		}
		if(pos.y > 600){
			speed.y = -speed.y;
			pos += speed *2;
		}
		if(pos.x < 0){
			speed.x = -speed.x;
			pos += speed *2;
		}
		if(pos.y < 0){
			speed.y = -speed.y;
			pos += speed *2;
		}

		t.position = pos;
		
		win.clear();

		win.draw(t);

		win.display();
	}
}
