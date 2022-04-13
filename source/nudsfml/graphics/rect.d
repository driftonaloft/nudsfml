module nudsfml.graphics.rect;

import std.traits;

import nudsfml.system.vector2;

struct Rect(T)
    if(isNumeric!(T))
{
    T left = 0;
    T top = 0;
    T width = 0;;
    T height = 0;

    this(T rectLeft, T rectRight, T rectWidth, T rectHeight){
        left = rectLeft;
        top = rectHeight;
        width = rectWidth;
        height = rectHeight;
    }

    this(Vector2!(T) position, Vector2!(T) size){
        left = position.x;
        top = position.y;
        width = size.x;
        height = size.y;
    }

    bool contains(E)(E x, E y) const
        if(isNumeric!(E))
    {
        return x >= left && x <= left + width && y >= top && y <= top + height;
    }

    bool contains(E)(Vector2!(E) point) const
        if(isNumeric!(E))
    {
        return contains(point.x, point.y);
    }

    bool intersects(E)(Rect!() rectangle) const
        if(isNumeric!(E)) 
    {
        Rect!(T) rect;
        return intersects(rectangle, rect);

    }

    bool intersects(E,O)(Rect!(E) rectangle, out Rect!(O) intersection) const 
        if(isNumeric!(O) && isNumeric!(E)) 
    {
        O interLeft = max(left, rectangle.left);
        O interTop = max(top, rectangle.top);
        O interRight = min(left + width, rectangle.left + rectangle.width);
        O interBottom = min(top + height, rectangle.top + rectangle.height);

        if(interLeft < interRight && interTop < interBottom) {
            intersection = Rect(O)(interLeft, interTop, interRight - interLeft, interBottom - interTop);
            return true;
        } else {
            intersection = Rect(O)(0, 0, 0, 0);
            return false;
        }
    }

    bool opEquals(E)(const Rect!(E) otherRect) const
        if(isNumeric!(E)) 
    {
        return ((left == otherRect.left) && (top == otherRect.top) && 
                (width == otherRect.width) && (height == otherRect.height));
    }

    string toString() const {
        import std.conv;
        return "Rect(" ~ text(left) ~ ", " ~ text(top) ~ ", " ~ text(width) ~ ", " ~ text(height) ~ ")";
    }

    private T max(T a, T b) const {
        return a > b ? a : b;
    }

    private T min(T a, T b) const {
        return a < b ? a : b;
    }
}
    
alias IntRect = Rect!(int);
alias FloatRect = Rect!(float);