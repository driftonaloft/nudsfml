/*
 * DSFML - The Simple and Fast Multimedia Library for D
 *
 * Copyright (c) 2013 - 2018 Jeremy DeHaan (dehaan.jeremiah@gmail.com)
 *
 * This software is provided 'as-is', without any express or implied warranty.
 * In no event will the authors be held liable for any damages arising from the
 * use of this software.
 *
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 *
 * 1. The origin of this software must not be misrepresented; you must not claim
 * that you wrote the original software. If you use this software in a product,
 * an acknowledgment in the product documentation would be appreciated but is
 * not required.
 *
 * 2. Altered source versions must be plainly marked as such, and must not be
 * misrepresented as being the original software.
 *
 * 3. This notice may not be removed or altered from any source distribution
 *
 *
 * DSFML is based on SFML (Copyright Laurent Gomila)
 */

/**
 * A listener socket is a special type of socket that listens to a given port
 * and waits for connections on that port. This is all it can do.
 *
 * When a new connection is received, you must call `accept` and the listener
 * returns a new instance of $(TCPSOCKET_LINK) that is properly initialized and
 * can be used to communicate with the new client.
 *
 * Listener sockets are specific to the TCP protocol, UDP sockets are
 * connectionless and can therefore communicate directly. As a consequence, a
 * listener socket will always return the new connections as $(TCPSOCKET_LINK)
 * instances.
 *
 * A listener is automatically closed on destruction, like all other types of
 * socket. However if you want to stop listening before the socket is destroyed,
 * you can call its `close()` function.
 *
 * Example:
 * ---
 * // Create a listener socket and make it wait for new
 * // connections on port 55001
 * auto listener = new TcpListener();
 * listener.listen(55001);
 *
 * // Endless loop that waits for new connections
 * while (running)
 * {
 *     auto client = new TcpSocket();
 *     if (listener.accept(client) == Socket.Status.Done)
 *     {
 *         // A new client just connected!
 *         writeln("New connection received from ", client.getRemoteAddress());
 *         doSomethingWith(client);
 *     }
 * }
 * ---
 *
 * See_Also:
 * $(TCPSOCKET_LINK), $(SOCKET_LINK)
 */
module nudsfml.network.tcplistener;

import nudsfml.network.ipaddress;
import nudsfml.network.socket;
import nudsfml.network.tcpsocket;
import nudsfml.system.err;

/**
 * Socket that listens to new TCP connections.
 */
class TcpListener:Socket
{
    package sfTcpListener* sfPtr;

    /// Default constructor.
    this()
    {
        sfPtr = sfTcpListener_create();
    }

    /// Destructor.
    ~this()
    {
        import nudsfml.system.config;
        mixin(destructorOutput);
        sfTcpListener_destroy(sfPtr);
    }

    /**
     * Get the port to which the socket is bound locally.
     *
     * If the socket is not listening to a port, this function returns 0.
     *
     * Returns: Port to which the socket is bound.
     */
    ushort getLocalPort() const
    {
        return sfTcpListener_getLocalPort(sfPtr);
    }

    /**
     * Tell whether the socket is in blocking or non-blocking mode.
     *
     * In blocking mode, calls will not return until they have completed their
     * task. For example, a call to `receive` in blocking mode won't return
     * until some data was actually received.
     *
     * In non-blocking mode, calls will
     * always return immediately, using the return code to signal whether there
     * was data available or not. By default, all sockets are blocking.
     *
     * Params:
     *  blocking = true to set the socket as blocking, false for non-blocking
     */
    void setBlocking(bool blocking)
    {
        sfTcpListener_setBlocking(sfPtr, blocking);
    }

    /**
     * Accept a new connection.
     *
     * If the socket is in blocking mode, this function will not return until a
     * connection is actually received.
     *
     * Params:
     *  socket = Socket that will hold the new connection
     *
     * Returns: Status code.
     */
    Status accept(TcpSocket socket)
    {
        return sfTcpListener_accept(sfPtr, socket.sfPtr);
    }

    /**
     * Start listening for connections.
     *
     * This functions makes the socket listen to the specified port, waiting for
     * new connections. If the socket was previously listening to another port,
     * it will be stopped first and bound to the new port.
     *
     * Params:
     *  port    = Port to listen for new connections
     *  address = Address of the interface to listen on
     *
     * Returns: Status code.
     */
    Status listen(ushort port, IpAddress address = IpAddress.Any)
    {
        return sfTcpListener_listen(sfPtr, port, &address);
    }

    /**
     * Tell whether the socket is in blocking or non-blocking mode.
     *
     * Returns: true if the socket is blocking, false otherwise.
     */
    bool isBlocking() const
    {
        return (sfTcpListener_isBlocking(sfPtr));
    }
}

unittest
{
    version(DSFML_Unittest_Network)
    {
        import std.stdio;
        import nudsfml.network.ipaddress;

        writeln("Unittest for Listener");
        //socket connecting to server
        auto clientSocket = new TcpSocket();

        //listener looking for new sockets
        auto listener = new TcpListener();
        listener.listen(55002);

        writeln("The listener is listening to port ", listener.getLocalPort());

        //get our client socket to connect to the server
        clientSocket.connect(IpAddress.LocalHost, 55002);

        //socket on the server side connected to the client's socket
        auto serverSocket = new TcpSocket();

        //accepts a new connection and binds it to the socket in the parameter
        listener.accept(serverSocket);

        clientSocket.disconnect();
        writeln();
    }
}

package extern(C):

struct sfTcpListener;

sfTcpListener* sfTcpListener_create();

//Destroy a TCP listener
void sfTcpListener_destroy(sfTcpListener* listener);

//Set the blocking state of a TCP listener
void sfTcpListener_setBlocking(sfTcpListener* listener, bool blocking);

//Tell whether a TCP listener is in blocking or non-blocking mode
bool sfTcpListener_isBlocking(const sfTcpListener* listener);

//Get the port to which a TCP listener is bound locally
ushort sfTcpListener_getLocalPort(const(sfTcpListener)* listener);

//Start listening for connections
Socket.Status sfTcpListener_listen(sfTcpListener* listener, ushort port, IpAddress* address);

//Accept a new connection
Socket.Status sfTcpListener_accept(sfTcpListener* listener, sfTcpSocket* connected);
