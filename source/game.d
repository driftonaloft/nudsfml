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


    this(string dataDir_ = "data/"){
        dataDir = dataDir_;

        systemFont = new Font(dataDir ~ "CamingoCode-Regular.ttf");
        win = new RenderWindow(new VideoMode(800, 600), "NudSFML", Styles.);
        //create initial resources
    } 


    void startup() {

    }

    void run(){
        while(running){

        }
    }

    void shutdown(){
        //clean up resources 

    }
}