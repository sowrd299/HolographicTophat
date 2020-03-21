/**
A class for a UI element comprised of multiple buttons
*/
class CompositButton extends Button {

    CompositButton(Rect rect, String label, color c, ButtonHandler general_handler){
        super(rect, label, c, general_handler);
    }

    /**
    Returns all the button components
    */
    Button[] get_buttons() {
        return new Button[]{};
    }

    void draw(){
        super.draw();
        for(Button button : get_buttons()){
            button.draw();
        }
    }

    /**
    Will allow the composit button and a component button to be clicked
    ...at the same time.
    Otherwise only allows the first button clicked to be clicked.
    */
    boolean click(int x, int y){

        boolean base_clicked = super.click(x,y);

        for(Button button : get_buttons()){
            if(button.click(x,y)){
                // once we've clicked a button, return true
                return true;
            }
        }

        return base_clicked;

    }

}

/**
A class specifically for representing a screen of the game
*/
class Menu extends CompositButton {

    MenuSwitcher menu_switcher;
    color holo_color;

    ArrayList<Button> buttons;

    Menu() {
        super(get_screen_rect(), "", color(0), null);
    }

    Menu(MenuSwitcher m, color holo_color){
        super(get_screen_rect(), "", holo_color, null);
        menu_switcher = m;
        this.holo_color = holo_color;
        margin *= 3;    
        font_size = r.h/36;
    }

    /**
    Restarts the register of buttons
    */
    void start_buttons(){
        buttons = new ArrayList<Button>();
    }

    /**
    Logs a new button
    */
    void add_button(Button b){
        buttons.add(b);
    }

    /**
    Returns the logged buttons
    */
    Button[] get_buttons(){
        Button[] b = new Button[0];
        return buttons.toArray(b);
    }

    /**
    Initializes the menu
    Is done on delay to allow for constructing new menus without eating up resources
    */
    void init() {}
  
}