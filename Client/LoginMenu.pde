class LoginMenu extends Menu{

    Connection con;

    Button bg_button;

    LoginMenu(Connection con, color holo_color){
        super(null, holo_color);
        this.con = con;
    }

    void init(){
        start_buttons();

        int rows = 4;
        int cols = 4;
        Rect[] rects = create_rects(r.get_x() + 2*margin, r.get_y() + 2*margin + 5*font_size, (r.get_w() - (6*margin))/cols, r.get_h()/(rows+4), margin, margin, rows, cols);

        // the background button
        add_button(new BackgroundButton(
            create_bounding_rect(new Rect[]{create_bounding_rect(rects, margin, margin, margin, margin)}, 0, 0, 5*font_size, 0),
            "Pick an id number. Pick a different number from everyone else. When returning, pick the same number.",
            holo_color,
            null,
            font_size,
            margin/10, margin, margin/2
        ));

        // the loging buttons
        for(int i = 0; i < rects.length; i++){

            String id_num = "" + (i+1);

            add_button(new TicketButton(
                rects[i],
                id_num,
                holo_color,
                new LoginButtonHandler("keypad_user_" + id_num),
                margin/10, 2*margin/3
            ));
        }


    }

    class LoginButtonHandler implements ButtonHandler {

        String user_id;

        LoginButtonHandler(String user_id){
            this.user_id = user_id;
        }

        void on_click(){
            Message msg = new Message("login");
            msg.put("user_id", user_id);
            con.send(msg);
        }

    }

}