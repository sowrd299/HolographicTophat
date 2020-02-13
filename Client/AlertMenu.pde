import java.util.ArrayList;

/**
A class for displaying alerts to the user
If "when_finished" is null, the alert will last
until the game decides to advance on it's own (e.g. from a new message from the server)
*/
class AlertMenu extends Menu{

    String text;
    ButtonHandler when_finished;
    Button bg;
    Button finished_button;

    Button[] tab_buttons;
    int active_tab;

    AlertMenu(String text, color holo_color, ButtonHandler when_finished){
        super(null, holo_color);
        this.text = text;
        this.when_finished = when_finished;
        this.margin = r.h/120;
    }

    void init(){

        int tab_w = (int)(r.w * 0.15);
        int text_h = (int)(r.h * 0.7);

        Rect area = new Rect(margin + tab_w, r.h/4, r.w-tab_w-2*margin, r.h/2);

        bg = new BackgroundButton(area, text, holo_color, null, r.h/36, margin/3, 8*margin, 2*margin);

        // the buttons for switching tabs
        ArrayList<String> lines = bg.to_lines(text);
        ArrayList<String> pages = new ArrayList<String>(); // the text for each tab
        int lines_per_page = text_h/bg.get_font_size();

        // the finished button
        if(when_finished != null){
            finished_button = new TicketButton(
                area.get_section(0.33, 0.8, 0.33, 0.15),
                "Ja",
                holo_color,
                when_finished,
                margin/3, 2*margin
            );
        }

    }

    Button[] get_buttons(){
        if(finished_button == null){
            return new Button[]{bg};
        }else{
            return new Button[]{bg, finished_button};
        }
    }

    class TabButtonHandler implements ButtonHandler{

        String text;
        int ind;

        TabButtonHandler(String text, int ind){
            this.text = text;
            this.ind = ind;
        }

        void on_click(){
            bg.set_label(text);
            active_tab = ind;
        }

    }

}