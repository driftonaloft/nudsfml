module nudsfml.graphics.glsl;

import nudsfml.graphics.color;
import nudsfml.graphics.transform;

import nudsfml.system.vector2;
import nudsfml.system.vector3;

import std.traits;

/// 2D float vector (vec2 in GLSL)
alias Vec2 = Vector2!(float);
/// 2D int vector (ivec2 in GLSL)
alias Ivec2 = Vector2!(int);
/// 2D bool vector (bvec2 in GLSL)
alias Bvec2 = Vector2!(bool);
/// 3D float vector (vec3 in GLSL)
alias Vec3 = Vector3!(float);
/// 3D int vector (ivec3 in GLSL)
alias Ivec3 = Vector3!(int);
/// 3D bool vector (bvec3 in GLSL)
alias Bvec3 = Vector3!(bool);

/**
 * 4D float vector (vec4 in GLSL)
 *
 * 4D float vectors can be converted from sf::Color instances. Each color
 * channel is normalized from integers in [0, 255] to floating point values
 * in [0, 1].
 * ---
 * Vec4 zeroVector;
 * auto vector = Vec4(1.f, 2.f, 3.f, 4.f);
 * auto color = Vec4(Color.Cyan);
 * ---
 */
alias Vec4 = Vector4!(float);
/**
 * 4D int vector ( ivec4 in GLSL)
 *
 * 4D int vectors can be converted from sf::Color instances. Each color channel
 * remains unchanged inside the integer interval [0, 255].
 * $(LI test)
 * ---
 * Ivec4 zeroVector;
 * auto vector = Ivec4(1, 2, 3, 4);
 * auto color = Ivec4(Color.Cyan);
 * ---
 */
alias Ivec4 = Vector4!(int);

/// 4D bool vector (bvec4 in GLSL)
alias Bvec4 = Vector4!(bool);

/**
 * 3x3 float matrix (mat3 in GLSL)
 *
 * The matrix can be constructed from an array with 3x3 elements, aligned in
 * column-major order. For example,a translation by (x, y) looks as follows:
 * ---
 * float[9] array =
 * [
 *     1, 0, 0,
 *     0, 1, 0,
 *     x, y, 1
 * ];
 *
 * auto matrix = Mat3(array);
 * ---
 *
 * $(PARA Mat4 can also be converted from a $(TRANSFORM_LINK Transform).)
 * ---
 * Transform transform;
 * auto matrix = Mat3(transform);
 * ---
 */
alias Mat3 = Matrix!(3,3);

/**
 * 4x4 float matrix (mat4 in GLSL)
 *
 * The matrix can be constructed from an array with 4x4 elements, aligned in
 * column-major order. For example, a translation by (x, y, z) looks as follows:
 * ---
 * float array[16] =
 * {
 *     1, 0, 0, 0,
 *     0, 1, 0, 0,
 *     0, 0, 1, 0,
 *     x, y, z, 1
 * };
 *
 * auto matrix = Mat4(array);
 * ---
 *
 * $(PARA Mat4 can also be converted from a $(TRANSFORM_LINK Transform).)
 * ---
 * Transform transform;
 * auto matrix = Mat4(transform);
 * ---
 */
alias Mat4 = Matrix!(4,4);

/**
 * 4D vector type, used to set uniforms in GLSL.
 */
struct Vector4(T)
    if(isNumeric!(T) || is(T == bool))
{
    /// 1st component (X) of the 4D vector
    T x;
    /// 2nd component (Y) of the 4D vector
    T y;
    /// 3rd component (Z) of the 4D vector
    T z;
    /// 4th component (W) of the 4D vector
    T w;

    /**
     * Construct from 4 vector components
     *
     * Params:
     * X = Component of the 4D vector
     * Y = Component of the 4D vector
     * Z = Component of the 4D vector
     * W = Component of the 4D vector
     */
    this(T X, T Y, T Z, T W)
    {
        x = X;
        y = Y;
        z = Z;
        w = W;
    }

    /**
     * Conversion constructor
     *
     * Params:
     * other = 4D vector of different type
     */
    this(U)(Vector!(U) other)
    {
        x = cast(T)other.x;
        y = cast(T)other.y;
        z = cast(T)other.z;
        w = cast(T)other.w;
    }

    /**
     * Construct vector from color.
     *
     * The vector values are normalized to [0, 1] for floats, and left as-is for
     * ints.
     *
     * Params:
     * source = The Color instance to create the vector from
     */
    this(Color source)
    {
        static if(is(T == float))
        {
            x = source.r / 255f;
            y = source.g / 255f;
            z = source.b / 255f;
            w = source.a / 255f;
        }
        else static if(is(T == int))
        {
            x = cast(T)source.r;
            y = cast(T)source.g;
            z = cast(T)source.b;
            w = cast(T)source.a;
        }
    }
}

/**
 * Matrix type, used to set uniforms in GLSL.
 */
struct Matrix(uint C, uint R)
{
    /// Array holding matrix data.
    float[C * R] array;

    /**
     * Construct from DSFML transform.
     *
     * This constructor is only supported for 3x3 and 4x4 matrices.
     *
     * Params:
     * source = A DSFML Transform
     */
    this(ref const(Transform) source)
    {
        static assert(C == R && (C == 3 || C == 4),
        "This constructor is only supported for 3x3 and 4x4 matrices.");

        const(float)[] from = source.getMatrix();

        static if(C == 3)
        {
            float[] to = array;                 // 3x3
        // Use only left-upper 3x3 block (for a 2D transform)
        to[0] = from[ 0]; to[1] = from[ 1]; to[2] = from[ 3];
        to[3] = from[ 4]; to[4] = from[ 5]; to[5] = from[ 7];
        to[6] = from[12]; to[7] = from[13]; to[8] = from[15];
        }
        else static if(C == 4)
        {
            array[] = from[];
        }
    }

    /**
     * Construct from raw data.
     *
     * The elements in source are copied to the instance.
     *
     * Params:
     * source = An array that has the size of the matrix.
     */
    this(const(float)[] source)
    {
        assert(array.length == source.length);

        array[0..$] = source[0 .. $];
    }
}
