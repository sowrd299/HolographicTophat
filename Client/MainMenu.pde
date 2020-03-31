import java.util.ArrayList;

class MainMenu extends Menu {

    private PlayerUI local_player;
    private PlayerUI[] opponents;
    private Hand player_hand; // the master copy of the hand
    private Hand hand; // the working copy of the hand
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
        this.player_hand = hand;
        refresh_hand();
        this.lockin_handler = lockin_handler;
        //margin = r.h/40;
    }

    private void refresh_hand(){
        hand = new Hand(player_hand);
    }

    /**
    To be called at the start of the turn
    */
    void start_turn(){
        refresh_hand();
    }

    void init() {

        int player_button_h = r.h/6;
        int player_button_w = r.w-2*margin;

        // setup the opponent buttons
        play_buttons = new Button[opponents.length];
        Rect[] rects = create_rects(margin,margin+font_size,player_button_w,player_button_h,margin,margin,opponents.length,1);
        
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
                margin/10, 2*margin/3
            );
        };

        opponent_bg_button = new BackgroundButton(
            create_bounding_rect(rects, margin/2, margin/2, font_size + margin/2, margin/2),
            ":opponent <played against>:",
            holo_color,
            null,
            font_size,
            margin/10, margin, margin/2
        );

        // setup the local player ui

        int send_button_h = r.h/13;

        Rect local_r = new Rect(margin, r.h-send_button_h-2*margin-player_button_h, player_button_w, player_button_h);
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
            margin/10, 2*margin/3
        );

        String agent_line = "|";
        Stat agents = local_player.get_player().get_boss().get_stat_object(STAT_AGENTS);
        for(String agent_type : agents.get_stats()){
            agent_line += " " + agent_type + ": " + agents.get_stat(agent_type).get() + " |";
        }

        local_bg_button = new BackgroundButton(
            create_bounding_rect(new Rect[]{local_r}, margin/2, margin/2, 2*font_size + margin/2, margin/2),
            ":you <defense>:\n" + agent_line,
            holo_color,
            null,
            font_size,
            margin/10, margin, margin/2
        );


        // setup the lock-in buttons
        send_button = new TicketButton(new Rect(margin,r.h-margin-r.h/13,r.w-2*margin,send_button_h), "Lock-in Actions", holo_color, lockin_handler, margin/10, 2*margin/3);

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
