/**
A class to render a very not fancy box
 */
class Box {

    protected Rect r;
    protected color c;
    protected int stroke_weight;
    protected int corner_size;

    Box(Rect rect, color c, int stroke_weight, int corner_size){
        this.r= rect;
        this.c = c;
        this.stroke_weight = stroke_weight;
        this.corner_size = corner_size;
    }

    void setup_draw() { 
        // set the pallet
        stroke(c, 200);
        fill(c, 150);
        strokeWeight(stroke_weight);
    }

    void draw() {
        setup_draw();
        rect(r.x,r.y,r.w,r.h);
    }

}

/**
A class to render a fancy box
 */
class TicketBox extends Box{

    TicketBox(Rect rect, color c, int stroke_weight, int corner_size){
        super(rect, c, stroke_weight, corner_size);
    }

    void draw(){

        setup_draw();

        // do the background rectangle
        strokeWeight(stroke_weight-1);
        rect(r.x + corner_size/2, r.y + corner_size/2, r.w - corner_size, r.h - corner_size);

        // the main box
        strokeWeight(stroke_weight);
        int x1 = r.x + corner_size;
        int x2 = r.x + r.w - corner_size;
        int x3 = r.x + r.w;
        int y1 = r.y + corner_size;
        int y2 = r.y + r.h - corner_size;
        int y3 = r.y + r.h;
        beginShape();
        vertex(x1, r.y);

        // top right corner
        vertex(x2, r.y);
        bezierVertex(x2, y1, x3, y1, x3, y1);

        // bottom right corner
        vertex(x3,y2);
        bezierVertex(x2, y2, x2, y3, x2, y3);

        // bottom left corner
        vertex(x1,y3);
        bezierVertex(x1, y2, r.x, y2, r.x, y2);

        // top left corner
        vertex(r.x,y1);
        bezierVertex(x1, y1, x1, r.y, x1, r.y);

        endShape();
    
    }

}

/**
A class that represents a less fancy, but still fancy, box
*/
class DeskBox extends Box{

    int margin;

    DeskBox(Rect rect, color c, int stroke_weight, int corner_size, int margin){
        super(rect, c, stroke_weight, corner_size);
        this.margin = margin;
    }

    /**
    Draws the tab decal for each corner
    */
    void draw_corner(int x, int y, int x_dir, int y_dir) {

        beginShape();

        int x1 = x + (x_dir * corner_size);
        int y3 = y + (y_dir * corner_size);

        // the outside edges
        vertex(x1, y);
        vertex(x,y);
        vertex(x, y3);

        // the curves
        int x_cp1 = x + (x_dir * margin/2);
        int x4 = x + (x_dir * margin);
        int y4 = y + (y_dir * margin);
        bezierVertex(x_cp1, y3, x_cp1, y3, x4, y4);

        int y_cp2 = y + (y_dir * margin/2);
        bezierVertex(x1, y_cp2, x1, y_cp2, x1, y);

        endShape();

    }

    void draw() {

        setup_draw();
        fill(c, 75);

        super.draw();

        draw_corner(r.x, r.y, 1, 1);
        draw_corner(r.x+r.w, r.y, -1, 1);
        draw_corner(r.x+r.w, r.y+r.h, -1, -1);
        draw_corner(r.x, r.y+r.h, 1, -1);

    }

}


class ShieldBox extends Box {

    ShieldBox(Rect rect, color c, int stroke_weight, int corner_size){
        super(rect, c, stroke_weight, corner_size);
    }

    void draw() {

        setup_draw();

        beginShape();

        vertex(r.x + r.w/2, r.y);
        bezierVertex(r.x + r.w/2 + corner_size, r.y + corner_size/4, r.x + r.w - corner_size, r.y + corner_size/2, r.x + r.w, r.y + corner_size/2);
        bezierVertex(r.x + r.w, r.y + r.h - corner_size/2, r.x + r.w - corner_size, r.y + r.h - corner_size/2, r.x + r.w/2, r.y + r.h);
        bezierVertex(r.x + corner_size, r.y + r.h - corner_size/2, r.x, r.y + r.h - corner_size/2, r.x, r.y + corner_size/2);
        bezierVertex(r.x + corner_size, r.y + corner_size/2, r.x + r.w/2 - corner_size, r.y + corner_size/4, r.x + r.w/2, r.y);

        endShape();

    }

}