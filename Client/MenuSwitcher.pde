/**
Handles the current menu, and all other potential menus
Overrides methods to be able to behave as the current menu, whatever it is
Provides a callback for switching the menu
*/
// TODO: Should be called "MenuManager"
class MenuSwitcher extends Menu{

    Menu menu;

    Rect exit_to;
    Rect enter_from;

    MenuSwitcher(){
        super();
        Rect sr = get_screen_rect();
        exit_to = new Rect(sr.x - sr.w, sr.y, sr.w, sr.h);
        enter_from = new Rect(sr.x, sr.y + sr.h, sr.w, sr.h);
    }

    void switch_menu(Menu m){
        if(m == menu){
            return;
        }else if(menu != null){
            println("Switching to: "+m.toString());
            menu = new TransitionMenu(menu, m, exit_to, enter_from, 20, this);
        }else{
            switch_menu_notransition(m);
        }
    }

    void switch_menu_notransition(Menu m) {
        //System.out.println("Switching menu...");
        println("Switching to: "+m.toString());
        menu = m;
        menu.init();
        //System.out.println("...switched!");
    }

    boolean click(int x, int y){
        return menu.click(x,y);
    }

    Button[] get_buttons(){
        return menu.get_buttons();
    }

    void draw(){
        menu.draw();
    }

    /**
    Creates a button handler that switches the menu
    */
    MenuSwitcherHandler create_button_handler(Menu m){
        return new MenuSwitcherHandler(m, this);
    }

    /**
    Creates a handler specifically for returning to the current menu
    */
    MenuSwitcherHandler create_return_handler(){
        return create_button_handler(menu);
    }

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

}