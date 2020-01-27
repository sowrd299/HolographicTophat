// Networking variables
String server_ip = "192.168.1.65"; // the ip of the server computer
Connection con;

// graphics variables
StarFieldBG bg;
color holo_color;
Menu menu;

// TOP-LEVEL CONTROL FUNCTIONS

void setup(){
  
  // setup the render
  fullScreen();
  //size(520,920);


  // connect
  con = new Connection();
  con.connect(server_ip);

  // testing content
  Opponent[] opponents = new Opponent[]{
    new Opponent("Micu"),
    new Opponent("Jarli")
  };

  // setup the GUI
  holo_color = color(240,60,60);
  bg = new StarFieldBG();
  menu = new MainMenu(opponents, new MenuSwitcher(), holo_color);
  menu.init();

}

// when the player touches the screen
void mousePressed() {

  for(Button button : menu.get_buttons()){
    if(button.click(mouseX,mouseY)){
      // once we've clicked a button, break
      break;
    }
  }

}

void draw() {
  bg.draw();
  menu.draw();

  // check for incoming messages
  Message resp = con.recieve();
  if(resp != null) {
    System.out.println("Recieved message: "+resp.to_string());
  }
}

// OTHER CONTROL FUNCTIONS, WHICH CAN BE CALLED

/**
Provides a callback for switching the menu
*/
class MenuSwitcher{

  class MenuSwitcherHandler implements ButtonHandler{

    private Menu menu;
    private MenuSwitcher switcher;

    MenuSwitcherHandler(Menu menu, MenuSwitcher switcher){
      this.menu = menu;
      this.switcher = switcher;
    }

    void on_click(){
      switcher.switch_menu(menu);
    }

  }

  void switch_menu(Menu m) {
    menu = m;
    menu.init();
  }

  /**
  Creates a button handler that switches the menu
  */
  MenuSwitcherHandler create_button_handler(Menu m){
    return new MenuSwitcherHandler(m, this);
  }

}