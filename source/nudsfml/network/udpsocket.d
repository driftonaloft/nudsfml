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
 * A UDP socket is a connectionless socket.
 *
 * Instead of connecting once to a remote host, like TCP sockets, it can send to
 * and receive from any host at any time.
 *
 * It is a datagram protocol: bounded blocks of data (datagrams) are transfered
 * over the network rather than a continuous stream of data (TCP). Therefore,
 * one call to send will always match one call to receive (if the datagram is
 * not lost), with the same data that was sent.
 *
 * The UDP protocol is lightweight but unreliable. Unreliable means that
 * datagrams may be duplicated, be lost or arrive reordered. However, if a
 * datagram arrives, its data is guaranteed to be valid.
 *
 * UDP is generally used for real-time communication (audio or video streaming,
 * real-time games, etc.) where speed is crucial and lost data doesn't matter
 * much.
 *
 * Sending and receiving data can use either the low-level or the high-level
 * functions. The low-level functions process a raw sequence of bytes, whereas
 * the high-level interface uses packets (see Packet), which are easier to use
 * and provide more safety regarding the data that is exchanged. You can look at
 * the Packet class to get more details about how they work.
 *
 * It is important to note that UdpSocket is unable to send datagrams bigger
 * than MaxDatagramSize. In this case, it returns an error and doesn't send
 * anything. This applies to both raw data and packets. Indeed, even packets are
 * unable to split and recompose data, due to the unreliability of the protocol
 * (dropped, mixed or duplicated datagrams may lead to a big mess when trying to
 * recompose a packet).
 *
 * If the socket is bound to a port, it is automatically unbound from it when
 * the socket is destroyed. However, you can unbind the socket explicitely with
 * the Unbind function if necessary, to stop receiving messages or make the port
 * available for other sockets.
 *
 * Example:
 * ---
 * // ----- The client -----
 *
 * // Create a socket and bind it to the port 55001
 * auto socket = UdpSocket();
 * socket.bind(55001);
 *
 * // Send a message to 192.168.1.50 on port 55002
 * string message = "Hi, I am " ~ IpAddress.getLocalAddress().toString();
 * socket.send(message, "192.168.1.50", 55002);
 *
 * // Receive an answer (most likely from 192.168.1.50, but could be anyone else)
 * char[1024] buffer;
 * size_t received = 0;
 * IpAddress sender;
 * ushort port;
 * socket.receive(buffer, received, sender, port);
 * writeln( sender.toString(), " said: ", buffer[0 .. received]);
 *
 * // ----- The server -----
 *
 * // Create a socket and bind it to the port 55002
 * auto socket = new UdpSocket();
 * socket.bind(55002);
 *
 * // Receive a message from anyone
 * char[1024] buffer;
 * size_t received = 0;
 * IpAddress sender;
 * ushort port;
 * socket.receive(buffer, received, sender, port);
 * writeln(sender.toString(), " said: ", buffer[0 .. received]);
 *
 * // Send an answer
 * message = "Welcome " ~ sender.toString();
 * socket.send(message, sender, port);
 * ---
 *
 * See_Also:
 * $(SOCKET_LINK), $(TCPSOCKET_LINK), $(PACKET_LINK)
 */
module nudsfml.network.udpsocket;

import nudsfml.network.ipaddress;
import nudsfml.network.packet;
import nudsfml.network.socket;

import nudsfml.system.err;

/**
 * Specialized socket using the UDP protocol.
 */
class UdpSocket:Socket
{
    package sfUdpSocket* sfPtr;

    /// The maximum number of bytes that can be sent in a single UDP datagram.
    enum maxDatagramSize = 65507;

    /// Default constructor.
    this()
    {
        sfPtr = sfUdpSocket_create();
    }

    /// Destructor.
    ~this()
    {
        import nudsfml.system.config;
        mixin(destructorOutput);
        sfUdpSocket_destroy(sfPtr);
    }

    /**
     * Get the port to which the socket is bound locally.
     *
     * If the socket is not bound to a port, this function returns 0.
     *
     * Returns: Port to which the socket is bound.
     */
    ushort getLocalPort() const
    {
        return sfUdpSocket_getLocalPort(sfPtr);
    }

    /**
     * Set the blocking state of the socket.
     *
     * In blocking mode, calls will not return until they have completed their
     * task. For example, a call to Receive in blocking mode won't return until
     * some data was actually received. In non-blocking mode, calls will always
     * return immediately, using the return code to signal whether there was
     * data available or not. By default, all sockets are blocking.
     *
     * Params:
     * 	blocking = true to set the socket as blocking, false for non-blocking
     */
    void setBlocking(bool blocking)
    {
        sfUdpSocket_setBlocking(sfPtr,blocking);
    }

    /**
     * Bind the socket to a specific port.
     *
     * Binding the socket to a port is necessary for being able to receive data
     * on that port. You can use the special value Socket.AnyPort to tell the
     * system to automatically pick an available port, and then call
     * getLocalPort to retrieve the chosen port.
     *
     * Params:
     * 	port    = Port to bind the socket to
     *  address = Address of the interface to bind to
     *
     * Returns: Status code.
     */
    Status bind(ushort port, IpAddress address = IpAddress.Any)
    {
        return sfUdpSocket_bind(sfPtr,port, &address);
    }

    /**
     * Tell whether the socket is in blocking or non-blocking mode.
     *
     * Returns: true if the socket is blocking, false otherwise.
     */
    bool isBlocking() const
    {
        return (sfUdpSocket_isBlocking(sfPtr));
    }

    /**
     * Send raw data to a remote peer.
     *
     * Make sure that the size is not greater than UdpSocket.MaxDatagramSize,
     * otherwise this function will fail and no data will be sent.
     *
     * Params:
     * 	data    = Pointer to the sequence of bytes to send
     * 	address = Address of the receiver
     * 	port    = Port of the receiver to send the data to
     *
     * Returns: Status code.
     */
    Status send(const(void)[] data, IpAddress address, ushort port)
    {
        Status toReturn = sfUdpSocket_send(sfPtr,data.ptr, data.length,&address,port);

        return toReturn;
    }

    /**
     * Send a formatted packet of data to a remote peer.
     *
     * Make sure that the packet size is not greater than
     * UdpSocket.MaxDatagramSize, otherwise this function will fail and no data
     * will be sent.
     *
     * Params:
     * 	packet = Packet to send
     * 	address = Address of the receiver
     * 	port = Port of the receiver to send the data to
     *
     * Returns: Status code.
     */
    Status send(Packet packet, IpAddress address, ushort port)
    {
        //temporary packet to be removed on function exit
        scope SfPacket temp = new SfPacket();

        //getting packet's "to send" data
        temp.append(packet.onSend());

        //send the data
        return sfUdpSocket_sendPacket(sfPtr, temp.sfPtr, &address, port);
    }

    /**
     * Receive raw data from a remote peer.
     *
     * In blocking mode, this function will wait until some bytes are actually
     * received.
     *
     * Be careful to use a buffer which is large enough for the data that you
     * intend to receive, if it is too small then an error will be returned and
     * all the data will be lost.
     *
     * Params:
     * 		data = The array to fill with the received bytes
     * 		sizeReceived = The number of bytes received
     * 		address = Address of the peer that sent the data
     * 		port = Port of the peer that sent the data
     *
     * Returns: Status code.
     */
    Status receive(void[] data, out size_t sizeReceived, out IpAddress address, out ushort port)
    {
        return sfUdpSocket_receive(sfPtr, data.ptr, data.length,
                                            &sizeReceived, &address, &port);
    }

    /**
     * Receive a formatted packet of data from a remote peer.
     *
     * In blocking mode, this function will wait until the whole packet has been
     * received.
     *
     * Params:
     * 	packet = Packet to fill with the received data
     * 	address = Address of the peer that sent the data
     * 	port = Port of the peer that sent the data
     *
     * Returns: Status code.
     */
    Status receive(Packet packet, out IpAddress address, out ushort port)
    {
        //temporary packet to be removed on function exit
        scope SfPacket temp = new SfPacket();

        //get the sent data
        Status status =  sfUdpSocket_receivePacket(sfPtr, temp.sfPtr, &address, &port);

        //put data into the packet so that it can process it first if it wants.
        packet.onRecieve(temp.getData());

        return status;
    }

    /**
     * Unbind the socket from the local port to which it is bound.
     *
     * The port that the socket was previously using is immediately available
     * after this function is called. If the socket is not bound to a port, this
     * function has no effect.
     */
    void unbind()
    {
        sfUdpSocket_unbind(sfPtr);
    }
}

unittest
{
    version(DSFML_Unittest_Network)
    {
        import std.stdio;

        writeln("Unittest for Udp Socket");

        auto clientSocket = new UdpSocket();

        //bind this socket to this port for receiving data
        clientSocket.bind(56001);

        auto serverSocket = new UdpSocket();

        serverSocket.bind(56002);

        //send the data to the port our server is listening to
        writeln("Sending data!");
        clientSocket.send("I sent you data!", IpAddress.LocalHost, 56002);

        ////////////////////////////////////////////////////////////////////////

        IpAddress receivedFrom;
        ushort receivedPort;
        auto receivedPacket = new Packet();

        //get the information received as well as information about the sender

        char[1024] temp2;
        size_t received;

        writeln("Receiving data!");
        serverSocket.receive(temp2,received, receivedFrom, receivedPort);

        //What did we get?!
        writeln("The data received from ", receivedFrom, " at port ", receivedPort, " was: ", cast(string)temp2[0..received]);

        writeln();
    }
}

package extern(C):

struct sfUdpSocket;

//Create a new UDP socket
sfUdpSocket* sfUdpSocket_create();

//Destroy a UDP socket
void sfUdpSocket_destroy(sfUdpSocket* socket);

//Set the blocking state of a UDP listener
void sfUdpSocket_setBlocking(sfUdpSocket* socket, bool blocking);

//Tell whether a UDP socket is in blocking or non-blocking mode
bool sfUdpSocket_isBlocking(const sfUdpSocket* socket);

//Get the port to which a UDP socket is bound locally
ushort sfUdpSocket_getLocalPort(const(sfUdpSocket)* socket);

//Bind a UDP socket to a specific port
Socket.Status sfUdpSocket_bind(sfUdpSocket* socket, ushort port, IpAddress* ipAddress);

//Unbind a UDP socket from the local port to which it is bound
void sfUdpSocket_unbind(sfUdpSocket* socket);

//Send raw data to a remote peer with a UDP socket
Socket.Status sfUdpSocket_send(sfUdpSocket* socket, const(void)* data, size_t size, IpAddress* receiver, ushort port);

//Receive raw data from a remote peer with a UDP socket
Socket.Status sfUdpSocket_receive(sfUdpSocket* socket, void* data, size_t maxSize, size_t* sizeReceived, IpAddress* sender, ushort* port);

//Send a formatted packet of data to a remote peer with a UDP socket
Socket.Status sfUdpSocket_sendPacket(sfUdpSocket* socket, sfPacket* packet, IpAddress* receiver, ushort port);

//Receive a formatted packet of data from a remote peer with a UDP socket
Socket.Status sfUdpSocket_receivePacket(sfUdpSocket* socket, sfPacket* packet, IpAddress* sender, ushort* port);
