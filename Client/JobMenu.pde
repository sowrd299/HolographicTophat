class JobMenu extends Menu {
    
    private Menu inactive_menu; // the menu to be shown instead while the player is inactive

    private Hand job_hand;
    private Player player;
    private PlayPosition position;
    private ButtonHandler when_finished;
    private ButtonHandler when_do_nothing;
    private boolean sent_when_do_nothing; // TODO: Have a more robust system for only doing this once

    private Button status_button;
    private Button bg_button;
    private Button[] job_buttons;
    private Button continue_button;

    JobMenu(Hand job_hand, Player player, PlayPosition position, ButtonHandler when_finished, ButtonHandler when_do_nothing, color holo_color){
        super(null, holo_color);
        this.job_hand = job_hand;
        this.player = player;
        this.position = position;
        this.get_w()hen_finished = when_finished;
        this.get_w()hen_do_nothing = when_do_nothing;
        this.sent_when_do_nothing = false;

        this.inactive_menu = new AlertMenu("Anticipating an enemy to begin a job soon. Oppertunity to interupt is eminant. Remain alert.", holo_color, null);

        this.inactive_menu.init(); // because it's static, just do it the once
        // TODO: have a better system for the inactive menu
    }

    void set_rect(Rect r){
        super.set_rect(r);
        this.inactive_menu.set_rect(r); // TODO: find a less hacky way to keep this menu updated
    }

    void init(){

        if(player.is_active()){ // TODO: assumes player will have a constant active state until next switch

            Card cont_job = player.get_job();

            Rect status_rect = new Rect(r.get_x() + margin, r.get_y()+margin, r.get_w()-2*margin, 2*(margin+font_size));
            status_button = new BackgroundButton(
                status_rect,
                cont_job == null ?
                "Select a job to begin." :
                    ((player.get_w()ill_complete_job()? 
                        ":JOB COMPLETE!:\nYou are ready for your next job." :
                        "If you abandon your job now, it will fail.") + " (" + player.get_progress() + " Progress on current job)"),
                holo_color,
                null,
                font_size,
                margin/10, margin, margin/2
            );

            Card[] cards = job_hand.get_cards();
            Rect[] rects = create_rects(r.get_x()+margin, status_rect.get_y()+status_rect.get_h()+margin+font_size, r.get_w()-2*margin, r.get_h()/12, 0, margin/2, cards.length+1, 1);
            int i = 0;

            job_buttons = new Button[cards.length];
            for(; i < job_buttons.length; i++){
                job_buttons[i] = new JobCardButton(
                    cards[i],
                    rects[i],
                    holo_color,
                    new JobButtonHandler(cards[i]),
                    margin/10, 2*margin/3
                );
            }

            rects[i] = rects[i].get_section(0,0,1,1.5);
            continue_button = new ContinueButton(rects[i], cont_job);

            bg_button = new BackgroundButton(
                create_bounding_rect(rects, margin/2, margin/2, margin/2 + font_size, margin/2),
                "Select your next job:",
                holo_color,
                null,
                font_size,
                margin/10, margin, margin/2
            );

        }else{
            if(!sent_when_do_nothing){
                when_do_nothing.on_click();
                sent_when_do_nothing = true;
            }
        }

    }

    Button[] get_buttons(){
        if(player.is_active()){
            Button[] r = new Button[job_buttons.length + 3];
            r[0] = bg_button;
            r[1] = continue_button;
            r[2] = status_button;
            for(int i = 0; i < job_buttons.length; i++){
                r[i+3] = job_buttons[i];
            }
            return r;
        }else{
            return inactive_menu.get_buttons();
        }
    }

    class JobButtonHandler implements ButtonHandler{

        private Card card;

        JobButtonHandler(Card card){
            this.card = card;
        }

        void on_click(){
            job_hand.remove_card(card);
            position.play_card(card);
            when_finished.on_click();
        }

    }

    class ContinueButton extends CompositButton {

        private Button label_button;
        private Button card_button;

        ContinueButton(Rect r, Card cont_job){
            super(r, "", holo_color, cont_job != null ? when_finished : null);
            label_button = new TicketButton(
                r.get_section(0.25,0,0.5,0.33),
                "Continue:",
                holo_color,
                null,
                margin/3, 3*margin
            );
            card_button = new JobCardButton(
                cont_job,
                r.get_section(0, 0.34, 1, 0.64),
                holo_color,
                null,
                margin/3, 3*margin
            );
        }

        Button[] get_buttons(){
            return new Button[]{
                label_button,
                card_button
            };
        }

    }

}