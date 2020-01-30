class MainMenu extends Menu {

    private PlayerUI local_player;
    private PlayerUI[] opponents;
    private Hand hand;
    private ButtonHandler lockin_handler;

    private Button opponent_bg_button;
    private Button[] play_buttons; // buttons for places where the player can play buttons
    private Button local_bg_button;
    private Button local_player_button;
    private Button send_button;

    MainMenu(PlayerUI[] opponents, PlayerUI local_player, Hand hand, MenuSwitcher menu_switcher, ButtonHandler lockin_handler, color holo_color){
        super(menu_switcher, holo_color);
        this.opponents = opponents;
        this.local_player = local_player;
        this.hand = hand;
        this.lockin_handler = lockin_handler;
        margin = 48;
    }

    void init() {

        int player_button_h = r.h/7;
        int player_button_w = r.w-2*margin;

        // setup the opponent buttons
        play_buttons = new Button[opponents.length];
        Rect[] rects = create_rects(margin,margin+font_size,player_button_w,player_button_h,8,8,opponents.length,1);
        
        for(int i = 0; i < play_buttons.length; i++){
            // the menu for playing a card against that opponent
            HandMenu hand_menu = new HandMenu(
                hand,
                opponents[i].get_played_against(),
                menu_switcher.create_button_handler(this),
                holo_color
            );
            // the buttons for each opponent
            play_buttons[i] = new PlayerUIButton(
                opponents[i],
                rects[i],
                holo_color,
                menu_switcher.create_button_handler(hand_menu),
                5, 32
            );
        };

        opponent_bg_button = new BackgroundButton(
            create_bounding_rect(rects, margin/2, margin/2, font_size + margin/2, margin/2),
            ":opponent <played against>:",
            holo_color,
            null,
            font_size,
            5, margin, margin/2
        );

        // setup the local player ui
        Rect local_r = new Rect(margin, r.h-224-margin-player_button_h, player_button_w, player_button_h);
        local_player_button = new PlayerUIButton(
            local_player,
            local_r,
            holo_color,
            menu_switcher.create_button_handler(new HandMenu(
                hand,
                local_player.get_played_against(),
                menu_switcher.create_button_handler(this),
                holo_color
            )),
            5, 32
        );

        local_bg_button = new BackgroundButton(
            create_bounding_rect(new Rect[]{local_r}, margin/2, margin/2, font_size + margin/2, margin/2),
            ":you <defense>:",
            holo_color,
            null,
            font_size,
            5, margin, margin/2
        );


        // setup the lock-in buttons
        send_button = new TicketButton(new Rect(32,r.h-224,r.w-64,124), "Lock-in Action", holo_color, lockin_handler, 5, 32);

    }

    Button[] get_buttons(){
        Button[] r = new Button[play_buttons.length+4];
        r[0] = send_button;
        r[1] = opponent_bg_button;
        r[2] = local_bg_button;
        r[3] = local_player_button;
        for(int i = 0; i < play_buttons.length; i++){
            r[4+i] = play_buttons[i];
        }
        return r;
    }

}
