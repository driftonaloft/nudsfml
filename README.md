# NuDSFML (New DSFML)
NuDSFML is a Refactor of DSFML using BindBC.SFML as a backend to load the
CSFML Library

Shader and Audio Support are very much a work in progress there are  missing 
features or support and will require a compleate rewrite other classes still 
need through testings 

even though i'm using SFML 2.5 as the targetted backend not all features are
implimented

The API is still underdevelopment and may change with out notice while i am
unlikely to or change an existing function I am likely to create functions 
and properties that fall more inline with how I use the D language

My initial testing shows that there is roughly a 13% over head compared to 
straight C++ (Note this is as run on a Latte Panda Alpha 1.6ghz 8GB ram) and
based on the Example Code below with out a frame rate limit set

##Example

```{.d .numberLines}
/*---------------------------------------------------------------------------*\
|   a quick example of working with nudsfml                                   |
\*---------------------------------------------------------------------------*/

import nudsfml.graphics;

void main(){
    //Create a new RenderWindow initialized at 1027x768 resolution with the title "Example Window"
	RenderWindow win = new RenderWindow(VideoMode(1024,768), "Example Window");
	win.setFramerateLimit(60);

	RectangleShape shape = new RectangleShape(Vector2f(50,50));
	shape.fillColor = Color.Red;

	Vector2f winSize = Vector2f(win.size.x, win.size.y);

	Vector2f position = Vector2f(0,0);
	Vector2f speed = Vector2f(150f,80f);

	Clock frameTime = new Clock();

	while(win.isOpen){
		float delta = frameTime.restart.asSeconds;

		Event e;
		while(win.pollEvent(e)){
			if(e.type == Event.Type.Closed)
				win.close();

		}

		position = position + speed * delta;
		if(position.x < 0 ){
			position.x = 0;
			speed.x = -speed.x;
		} else if (position.x + shape.size.x > winSize.x ){
			position.x = winSize.x - shape.size.x;
			speed.x = -speed.x;
		}
		if(position.y < 0 ){
			position.y = 0;
			speed.y = -speed.y;
		} else if (position.y + shape.size.y > winSize.y ){
			position.y = winSize.y - shape.size.y;
			speed.y = -speed.y;
		}
		shape.position = position;

		win.clear();

		win.draw(shape);

		win.display();
	}
}

```

DSFML originally used a custom variante of SFMLC called DSFMLC this offered some bennifits to memory handling
and consistency in the interface, I've done the best I could to maintain that interface and safety but at this 
time some annomolies may still exist across platforms i don't reguarly test
