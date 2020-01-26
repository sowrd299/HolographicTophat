class MainMenu extends Menu {

    private Button[] play_buttons; // buttons for places where the player can play buttons
    private Button send_button;

    MainMenu(color holo_color, MenuSwitcher menu_switcher){
        super(menu_switcher, holo_color);
    }

    void init() {

        HandMenu hand_menu = new HandMenu(new Hand(), menu_switcher.create_button_handler(this), holo_color);

        // setup the test opponent button
        play_buttons = new Button[]{
            new Button(new Rect(32,100,width-64,124), "Against Opponent: ", holo_color, menu_switcher.create_button_handler(hand_menu), 5, 32),
        };

        send_button = new Button(new Rect(32,height-224,width-64,124), "Lock-in Action", holo_color, null, 5, 32);

    }

    Button[] get_buttons(){
        Button[] r = new Button[play_buttons.length+1];
        r[0] = send_button;
        for(int i = 0; i < play_buttons.length; i++){
            r[1+i] = play_buttons[i];
        }
        return r;
    }

}
