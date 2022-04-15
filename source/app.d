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

	RenderWindow win = new RenderWindow(VideoMode(1024, 768), "NudSFML Test");
	win.setFramerateLimit(60);

	
	Font f = new Font();
	if(!f.loadFromFile("data/CamingoCode-Regular.ttf")){
		writeln("failed to load font");
	}
	
	//writeln(f.sfPtr);

	Text t = new Text("Hello World", f);
	
	Vector2f speed = Vector2f(0.3f, 0.8f);
	Vector2f pos = Vector2f(0, 0);

	bool running = true;
	char i = 0;

	RectangleShape rect = new RectangleShape();
	rect.size(Vector2f(100, 100));
	rect.fillColor(Color.Red);
	rect.position(Vector2f(100, 100));

	float angle = 0;

	while(win.isOpen() && running){
		Event e;
		while(win.pollEvent(e)){
			switch(e.type){
				case Event.Type.KeyPressed:
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

		angle += 0.5f;
		if(angle > 360){
			angle = 0;
		}

		
		win.clear();

		win.draw(rect);
		win.draw(t);

		win.display();
	}
}

unittest {
	import bindbc.sfml;
	import std.stdio;

	writeln("testing sfml");

	if(!loadSFML()){
		writeln("failed to load sfml");
	}
}
