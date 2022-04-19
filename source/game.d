module game;

import nudsfml.graphics;
import nudsfml.system;

import std.stdio;

import gamemap;

class Game {
    string dataDir;
    bool running = true;

    RenderWindow win;

    GameMap map;
    
    //SceneManager
    //scriptingEngine
    //

    Font systemFont;
    Text debugText;

    bool doDrawDebug = false;

    Clock gameTick;

    this(string dataDir_ = "data/"){
        dataDir = dataDir_;

        win = new RenderWindow(VideoMode(1024, 768), "NudSFML");
        //win.setVerticalSyncEnabled(true); // higher accuracy but more cpu time
        win.setFramerateLimit(60); // 60 fps max // TODO: make this configurable

        systemFont = new Font();
        systemFont.loadFromFile(dataDir ~ "CamingoCode-Regular.ttf");

        debugText = new Text("Test", systemFont, 16);
        doDrawDebug = true;
        //create initial resources

        map = new GameMap();
        map.addApple(5,4);

        gameTick = new Clock();
    } 


    void startup() {
        win.setTitle("素晴らしい ！"d);

    }

    void run(){
        while(running){
            float dt = gameTick.restart().asSeconds();
            handleEvents();
            update(dt);
            draw();
        }
    }

    void update(float dt){
        map.update(dt); 

    }

    void draw(){
        win.clear();

        //draw stuff here 
        map.draw(Vector2f(0,16), win);
        
        drawDebug();
        win.display();
    }

    void drawDebug(){
        if(doDrawDebug){
            win.draw(debugText);
        }
    }

    void handleEvents(){
        Event e;
        while(win.pollEvent(e)){
            switch(e.type){
                case Event.Type.Closed:
                    running = false;
                    break;
                case Event.Type.KeyPressed:
                    switch(e.key.code) { 
                        case Keyboard.Key.Escape:  
                            running = false;
                            break;
                        case Keyboard.Key.F12:
                            doDrawDebug = !doDrawDebug;
                            break;
                        case Keyboard.Key.F11:
                            auto screenShot = win.capture();
                            writeln("Saved screenshot to screenShot.png");
                            screenShot.saveToFile("screenshot.png");
                            break;
                        default: break;
                    }
                    break;
                default: break;
            }
        }
    }



    void shutdown(){
        //clean up resources 

    }
}