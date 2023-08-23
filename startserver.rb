# Importing socket library
require 'socket'

#Initializing TCP server on localhost and port number 4445
$server = TCPServer.new('localhost', 4445)

#Useless but hey. it gotta stay
request_count = 0 

#Self-explanatory :)
$client = $server.accept 

#Loop establishes name of Client and welcomes them
loop do
    nameData = $client.gets("\0")
    if nameData != nil
        $nameData = nameData.chomp
        puts "Connection established with #{nameData}"
        request_count += 1
        $client.send("Welcome! You are visitor ##{request_count}, Time: #{Time.now}\000",0)
        break
    end 
end

# Incoming Data thread
incT = Thread.new{
loop do 
    incomingData = $client.gets("\0") # Very import to append the \0 to the gets method
    if incomingData == nil 
        puts "Closing Connection..."
        $server.close 
        exit
        break 
    end

    if incomingData != nil 
        puts "(#{$nameData}) >> #{incomingData.chomp}"
    end
end
}

# Outgoing Data Thread
outT = Thread.new{
loop do
    server_text = gets 
    if server_text.include? "exit"
        puts "Closing Connection..."
        $server.close
        exit
        break 
    end
        
    if server_text != nil 
        $client.send(server_text +"\000",0) # Very important to append the \000 else it wouldn't work
    end
end 
}

# Two below starts the threads for the Incoming and Outgoing Data Threads
incT.join
outT.join