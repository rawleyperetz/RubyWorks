# Importing the socket library
require 'socket'

# Input your name
puts "Enter your name: "
client_name = gets.chomp

# Hi Name
puts "Hi #{client_name}!"

# Initializing the TCP socket on localhost with port number 4445 (use any port number you prefer :)  )
$socket = TCPSocket.new('localhost', 4445)

# Sending name to the server.  Note: Very important to append the \000 to the send else it wouldn't work
$socket.send(client_name + "\000",0)

# Incoming Data Thread
incT = Thread.new{
loop do 
    incomingData = $socket.gets("\0")
    if incomingData == nil
        puts "Closing Connection..."
        $socket.close
        exit 
        break 
    end
    if incomingData != nil 
        puts "(server) >> #{incomingData.chomp}"
    end
end
}

# Outgoing Data Thread 
outT = Thread.new{
loop do
    client_text = gets 
    if client_text.include? "exit"
        puts "Closing Connection..."
        exit
        break
    end 

    if client_text != nil 
        $socket.send(client_text + "\000",0)
    end
end 
}

# Two below, begins the Incoming and Outgoing Data Threads
incT.join 
outT.join

