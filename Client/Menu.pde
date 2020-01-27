/**
A class for representing a screen of the game
*/
class Menu {

    MenuSwitcher menu_switcher;
    color holo_color;

    Menu() {}

    Menu(MenuSwitcher m, color holo_color){
        menu_switcher = m;
        this.holo_color = holo_color;
    }

    /**
    Initializes the menu
    Is done on delay to allow for constructing new menus without eating up resources
    */
    void init() {}

    /**
    Returns all the buttons in the menu
    */
    Button[] get_buttons() {
        return new Button[]{};
    }

    void draw(){
        for(Button button : get_buttons()){
            button.draw();
        }
    }

  
}