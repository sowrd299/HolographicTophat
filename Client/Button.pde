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

    // TODO: this schould really take a box as an argument
    Button(Rect rect, String label, color c, ButtonHandler handler){
        this.r= rect;
        this.label = label;
        this.margin = height/120; // TODO: ideally would not need to use "height" here

        font = loadFont("TlwgTypist-Bold-48.vlw");
        font_size = r.h;
        this.handler = handler;
        // create the font color
        colorMode(HSB);
        this.c = color(hue(c), saturation(c), 50);
        colorMode(RGB);
    }

    String get_label(){
        return label;
    }

    void draw(){
        if(box != null) box.draw();
        // draw the label
        String text = get_label();
        if(text.length() > 0){
            textFont(font, font_size);
            textAlign(CENTER);
            fill(c, 200);
            text(text, r.x + margin, r.y+ 1.5*margin, r.w - 2*margin, r.h);
        }
    }

    boolean click(int x, int y){
        if(handler != null && r.touches_point(x,y)){
            handler.on_click();
            return true;
        }
        return false;
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