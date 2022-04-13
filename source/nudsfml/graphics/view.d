module nudsfml.graphics.view;

import nudsfml.graphics.rect;
import nudsfml.system.vector2;

import nudsfml.graphics.transform;

struct View {
    package {
        Vector2f m_center = Vector2f(500, 500);
        Vector2f m_size = Vector2f(1000, 1000);
        float m_rotation = 0;
        FloatRect m_viewport = FloatRect(0, 0, 1, 1);
    } private {
        bool m_transformUpdated;
        bool m_invTransformUpdated;
        Transform m_transform;
        Transform m_invTransform;
    }

    this (FloatRect rectangle){
        reset (rectangle);
    }

    this (Vector2f center, Vector2f size){
        m_center = center;
        m_size = size;
    }

    @property { //center 
        Vector2f venter(Vector2f newCenter){
            m_center = newCenter;
            m_transformUpdated = false;
            m_invTransformUpdated = false;
            return m_center;
        }

        Vector2f center() const {
            return m_center;
        }
    }

    @property {//rotation 
        float rotation(float newRotation){
            m_rotation = newRotation;
            if (m_rotation < 0) {
                m_rotation += 360;
            }
            m_transformUpdated = false;
            m_invTransformUpdated = false;
            return m_rotation;
        }
        float rotation() const {
            return m_rotation;
        }
    }

    @property {//size 
        Vector2f size(Vector2f newSize){
            m_size = newSize;
            m_transformUpdated = false;
            m_invTransformUpdated = false;
            return m_size;
        }
        Vector2f size() const {
            return m_size;
        }
    }

    @property {//viewport 
        FloatRect viewport(FloatRect newViewport){
            m_viewport = newViewport;
            m_transformUpdated = false;
            m_invTransformUpdated = false;
            return m_viewport;
        }
        FloatRect viewport() const {
            return m_viewport;
        }
    }

    void move(Vector2f offset){
        m_center += offset;
    }

    void reset(FloatRect rectangle){
        m_center.x  = rectangle.left + rectangle.width / 2;
        m_center.y = rectangle.top + rectangle.height / 2;
        m_size.x = rectangle.width;
        m_size.y = rectangle.height;
        m_rotation = 0;

        m_transformUpdated = false;
        m_invTransformUpdated = false;
    }

    void zoom(float factor){
        m_size *= factor;
    }

    Transform getTransform() {
        import std.math;

        Transform currentTransform;

        float angle =   m_rotation * 3.141592654f / 180.0;
        float cosine =  cos(angle);
        float sine =    sin(angle);
        float tx =      -m_center.x * cosine - m_center.y * sine + m_center.x;
        float ty =      m_center.x * sine - m_center.y * cosine + m_center.y;

        float a = 2.0 / m_size.x;
        float b = 2.0 / m_size.y;
        float c = -a * m_center.x - b * m_center.y;
        float d = -b * m_center.y;

        currentTransform = Transform(a * cosine,    a * sine,   a * tx + c,
                                    -b * sine,      b * cosine, b * ty + d,
                                     0.0,           0.0,        1.0);

        return currentTransform;
    }

    Transform getInverseTransform() {
        if (!m_invTransformUpdated) {
            m_invTransform = getTransform().getInverse();
            m_invTransformUpdated = true;
        }

        return m_invTransform;
    }
}