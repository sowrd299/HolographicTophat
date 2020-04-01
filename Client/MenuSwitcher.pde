/**
Handles the current menu, and all other potential menus
Overrides methods to be able to behave as the current menu, whatever it is
Provides a callback for switching the menu
*/
// TODO: Should be called "MenuManager"
class MenuSwitcher extends Menu{

    Menu menu;

    MenuSwitcher(){}

    void switch_menu(Menu m) {
        //System.out.println("Switching menu...");
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