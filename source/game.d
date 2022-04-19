module game;

import nudsfml.graphics;

class Game {
    string dataDir;
    bool running = true;

    RenderWindow win;
     
    //SceneManager
    //scriptingEngine
    //

    Font systemFont;
    Text debugText;

    bool doDrawDebug = false;

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
    } 


    void startup() {
        win.setTitle("素晴らしい ！"d);

    }

    void run(){
        while(running){
            handleEvents();
            update();
            draw();
        }
    }

    void update(){

    }

    void draw(){
        win.clear();

        //draw stuff here 
        
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