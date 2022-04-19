module gameentity;

import nudsfml.graphics;

import std.stdio;

class Entity {
    Vector2f position;

    bool destroy=false;

    this(){

    } 

    void update(float dt){

    }

    void draw(RenderTarget target){
        
    }
}


class SnakeEntity : Entity {
    int partsID;
    int parentID;
    int childID;

    RectangleShape shape;

    override void update(float dt){
        if(destroy){
            return;
        }
    }

    override void draw(RenderTarget target){
        shape.position = position;
        target.draw(shape);   
    }
    
}

enum Direction{
    UP,
    DOWN,
    LEFT,
    RIGHT
}

static Vector2f dir[Direction] = [
    Direction.UP : Vector2f(0, -1),
    Direction.DOWN: Vector2f(0, 1),
    Direction.LEFT: Vector2f(-1, 0),
    Direction.RIGHT: Vector2f(1, 0)
];
 
class Snake {
    SnakeEntity[] parts;
    int length;
    Direction direction;

    int head;
    int tail;

    bool doAdd = false;

    GameMap map;

    this(GameMap map_){
        map = map_;
    }

    void move(int scale){
        
        int id = tail;
        while (id != head){
            auto current = parts[id];
            auto parent = parts[current.parentID];
            current.position = parent.position;
            id = parent.id;
        }
        auto current = parts[head];
        current.position += dir[direction] * scale;

    }

    int addPart(){
        auto part = SnakeEntity();
        part.parentID = tail;
        part.position = parts[tail].position;
        part.id = length;
        parts[length] = part;
        length++;
        doAdd = false;
        return part.id;
    }


}

class AppleEntity : Entity {
    Vector2f offset = Vector2f(0, -8);

    float floatTime = 0;
    float floatTimeMultiplyer = 1.0;

    Texture texture;
    RectangleShape shape;
    RectangleShape shadow;

    this(Texture t) {
        texture = t;
        shape = new RectangleShape();
        shape.setTexture(t);
        //TODO!!! - load tile texture position and size from file 
        shape.size(Vector2f(32, 48));
        shape.textureRect = IntRect(32 * 4, 48*2, 32, 48);
        shape.fillColor = Color.White;

        shadow = new RectangleShape();
        shadow.setTexture(t);
        //TODO!!! - load tile texture position and size from file 
        shadow.size(Vector2f(32, 48));
        shadow.textureRect = IntRect(32 * 5, 48*2, 32, 48);
        shadow.fillColor = Color.White;

        super();
    }

    override void update(float deltaTime){
        
        floatTime += deltaTime * floatTimeMultiplyer;
        //writeln("deltaTime: ", deltaTime ," floatTime: ", floatTime, " multiplier: ", floatTimeMultiplyer);
        if(floatTime > .75 ){
            floatTime = .75;
            floatTimeMultiplyer = -floatTimeMultiplyer;
        }
        if(floatTime < 0 ){
            floatTime = 0.0;
            floatTimeMultiplyer = -floatTimeMultiplyer;
        }

        super.update(deltaTime);
    }

    override void draw(RenderTarget target){
        shadow.position = position;
        target.draw(shadow);
        
        shape.position = position + offset * (floatTime/0.75);
        target.draw(shape);

        super.draw(target);
    }
}