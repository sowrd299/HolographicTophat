/**
a class for representing a retangular region of the screen
 */
class Rect{

    private int x, y, w, h;

    Rect(int x, int y, int w, int h){
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
    }

    String toString(){
        return "{pos: ("+x+","+y+"), size: ("+w+","+h+")}";
    }

    int get_x(){
        return x;
    }

    int get_y(){
        return y;
    }

    int get_w(){
        return w;
    }

    int get_h(){
        return h;
    }

    /**
    Returns if the rect includes a given region of the screen
     */
    boolean touches_point(int x, int y){
        return x > this.get_x() && x < this.get_x() + get_w() &&
                y > this.get_y() && y < this.get_y() + get_h();
    }

    /**
    Returns a rect that is a sliced subsection of the total rect
    Takes the pos and size of the new rect as percentages of the entire rect
        where (0,0) is the upper left, and (1,1) is the lower right
    */
    Rect get_section(float rel_x, float rel_y, float rel_w, float rel_h){
        return new Rect(
            get_x() + (int)(rel_x * (float)w),
            get_y() + (int)(rel_y * (float)h),
            (int)(rel_w * (float)get_w()),
            (int)(rel_h * (float)get_h())
        );
    }

    /**
    Returns an interpolation between this rect and the given rect
    Step should be between 1 and zero
    */
    Rect interpolate(Rect f, float step){
        return new Rect(
            interpolate_int(get_x(), f.get_x(), step),
            interpolate_int(get_y(), f.get_y(), step),
            interpolate_int(get_w(), f.get_w(), step),
            interpolate_int(get_h(), f.get_h(), step)
        );
    }

}

/**
Returns an array of teslated rects created to the given speficications
*/
Rect[] create_rects(int x, int y, int w, int h, int x_padding, int y_padding, int rows, int cols){

    Rect[] r = new Rect[rows * cols];
    int x_step = w + x_padding;
    int y_step = h + y_padding;

    for(int i = 0; i < rows; i++){
        for(int j = 0; j < cols; j++){
            r[i*cols + j] = new Rect(x+(j*x_step),y+(i*y_step),w,h);
        }
    }

    return r;

}

Rect[] create_rects(Rect r, int x_padding, int y_padding, int rows, int cols){
    return create_rects(r.get_x(), r.get_y(), r.get_w(), r.get_h(), x_padding, y_padding, rows, cols);
}

/**
Creats a rect that encompasses the given rectangles
*/
Rect create_bounding_rect(Rect[] rects, int left_padding, int right_padding, int top_padding, int bottom_padding){

    int x1 = rects[0].get_x();
    int y1 = rects[0].get_y();
    int x2 = x1 + rects[0].get_w();
    int y2 = y1 + rects[0].get_h();

    for(int i = 1; i < rects.length; i++){
        x1 = min(x1, rects[i].get_x());
        y1 = min(y1, rects[i].get_y());
        x2 = max(x1, rects[i].get_x() + rects[i].get_w());
        y2 = max(y1, rects[i].get_y() + rects[i].get_h());
    }

    return new Rect(
        x1 - left_padding,
        y1 - top_padding,
        x2 - x1 + left_padding + right_padding,
        y2 - y1 + top_padding + bottom_padding
    );

}

/**
the rect that represents the entire screen
is a function, so that can be manipulated independently
NOTE: this must be called durring runtime; durring construction time, width and height are wrong;
*/
Rect get_screen_rect(){
    return new Rect(0,0,width,height);
}


/**
Returns a given interpolation between i and f
Step should be between 1 and 0
*/
int interpolate_int(int i, int f, float step){
    return int( i + ((f - i) * step) );
}