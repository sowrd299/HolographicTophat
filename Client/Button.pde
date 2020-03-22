import java.util.ArrayList;

// a display class for animated dots that acknowledge a button being pressed

class AckDots {

    private Rect r;

    private int when_last_played;
    private int anim_length; // the length of the animation in milis;

    private color c;
    private int displacement; // the displacement covered by the animation
    private int margin; // the margin within the rect the animation is contained inside

    AckDots(Rect rect, int anim_length, color c, int displacement, int margin){
        this.r = rect;
        this.anim_length = anim_length;
        this.c = c;
        this.displacement = displacement;
        this.margin = margin;

        // start not animated, even at time 0;
        this.when_last_played = -(2*anim_length);
    }

    void play_anim(){
        when_last_played = millis();
    }

    void draw(){
        int time = millis() - when_last_played;
        int current_disp = 0;
        if( time < anim_length){
            current_disp = (displacement * time) /anim_length;
        }
        stroke(c);
        strokeWeight(10);
        point(r.x+margin+current_disp, r.y + r.h/2);
        point(r.x+r.w-margin-current_disp, r.y + r.h/2);
    }

}

interface ButtonHandler {
    void on_click();
}

/**
A base class for all interactible UI elements
*/
class Button {
    
    protected Rect r;

    private String label;

    protected Box box;
    protected PFont font;
    protected int font_size;
    protected int margin;
    protected color c;


    protected ButtonHandler handler;

    Button(Rect rect, String label, Box box, color c, ButtonHandler handler){
        this.r= rect;
        this.label = label;
        this.box = box;
        this.margin = min(r.h/8, height/120); // TODO: ideally would not need to use "height" here

        font = loadFont("TlwgTypist-Bold-48.vlw");
        font_size = r.h;
        this.handler = handler;
        // create the font color
        colorMode(HSB);
        this.c = color(hue(c), saturation(c), 50);
        colorMode(RGB);
    }

    Button(Rect rect, String label, color c, ButtonHandler handler){
        this(rect, label, null, c, handler);
    }

    int get_font_size(){
        return font_size;
    }

    String get_label(){
        return label;
    }

    void set_label(String label){
        this.label = label;
    }

    /**
    Returns the width of the area the label will be printed in
    */
    int get_label_width(){
        return r.w - 2*margin;
    }

    void setup_label_draw(){
        textFont(font, font_size);
        textAlign(CENTER);
        fill(c, 200);
    }

    void draw(){
        if(box != null) box.draw();
        // draw the label
        String text = get_label();
        if(text.length() > 0){
            setup_label_draw();
            text(text, r.x + margin, r.y+ 1.5*margin, get_label_width(), r.h);
        }
    }

    boolean click(){
        return this.click(r.x + 1, r.y + 1);
    }

    boolean click(int x, int y){
        if(handler != null && r.touches_point(x,y)){
            handler.on_click();
            return true;
        }
        return false;
    }
    
    /**
    Returns the given text wrapped into lines,
        as it will be rendered by this button
    TODO: does not use actual wrapping, but it should
    */
    protected ArrayList<String> to_lines(String text){

        setup_label_draw();
        int wrap_width = get_label_width();

        ArrayList<String> r = new ArrayList<String>(); // the broken up wrapped lines
        String[] lines = text.split("\n", 0); // the original lines of text

        // for each line
        for(String line : lines){

            String new_line = "";
            float w = 0;

            // for each character
            for(int i = 0; i < line.length(); i++){
                float char_width = textWidth(line.charAt(i));

                // if we can't fit that char on the current line, wrapp
                if(w + char_width > wrap_width){
                    r.add(new_line);
                    new_line = "" ;
                    w = 0;
                }
                new_line += line.charAt(i);
                w += char_width; 
            }

            r.add(new_line + "\n");
        }
        return r;
    }

    /**
    Decreases font until the label fits on one line
    */
    void shrink_font_to_fit(int step){
        setup_label_draw();
        while(textWidth(get_label()) > get_label_width()){
            this.font_size -= step;
            setup_label_draw();
        }
    }

    void shrink_font_to_fit(){
        shrink_font_to_fit(5);
    }
}

/**
A class to represent a fancy button the user can interact with
 */
class TicketButton extends Button{

    private AckDots dots;

    TicketButton(Rect rect, String label, color c, ButtonHandler handler, int stroke_weight, int corner_size){
        super(rect, label, c, handler);
        this.box = new TicketBox(rect, c, stroke_weight, corner_size);
        this.font = loadFont("OldeEnglish-Regular-48.vlw");
        this.font_size = r.h-(2*margin);  

        // create the animated dots
        dots = new AckDots(rect, 500, this.c, 64, 2*margin);
    }

    void draw(){
        super.draw();
        // draw the dots
        dots.draw();
    }

    boolean click(int x, int y){
        boolean r = super.click(x,y);
        if(r){
            dots.play_anim();
        }
        return r;
    }

}

/**
A type of button based on the Desk Box for use in the background of menus
*/
class BackgroundButton extends Button {

    BackgroundButton(Rect rect, String label, color c, ButtonHandler handler, int font_size, int stroke_weight, int corner_size, int margin){
        super(rect, label, c, handler);
        this.font_size = font_size;
        box = new DeskBox(rect, c, stroke_weight, corner_size, margin);
    }

}

/**
A type of button used mostly for cards
*/

class ShieldButton extends Button {

    ShieldButton(Rect rect, String label, color c, ButtonHandler handler, int stroke_weight, int corner_size){
        super(rect, label, c, handler);
        font_size = r.h - 2*margin;
        box = new ShieldBox(rect, c, stroke_weight, corner_size);
    }

}
