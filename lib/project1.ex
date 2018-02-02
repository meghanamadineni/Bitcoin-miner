 ###
  #Main module to run server and client
 ###
 defmodule InitiateMining do
  def main(args) do #inputs
    {:ok, ifs} = :inet.getif()  #getting IP address
    localIp = Enum.map(ifs, fn {ip, _broadaddr, _mask} -> ip end)
    #retrieving the local IP address
    [ipaddress | _] = Enum.filter(Enum.map(localIp, fn x -> to_string(:inet.ntoa(x)) end),fn x -> "127.0.0.1"!=x end)
    if(length(args) == 1) do
      if(String.contains?(Enum.at(args, 0),".")) do #if the given input is IP address of server
        input = "meghaname@" <> List.to_string(args) #server name
        Worker.spawnClient(input,ipaddress) #sending server name and local IP address to connect client to server
      else  #If the input is leading zeros count        
        Server.initializeServer(String.to_integer(Enum.at(args, 0)),ipaddress)  #starting the server
      end
    else
      exit(0)
    end
  end
end

###
  #Server helper functions module
###
defmodule HelperFunctionsServer do # Helper module to generate random strings to assign work to the worker
  @gatorlinkid "amrutha94;" #using ufid to generrate different rfandom strings from other group
  @stringlength 15  #defining the length of random string to be generated
  
  def randomStringGenerator(count) do #strring the random string generated into a map, to assign the clilent a bunch of load to mine
      Enum.map(1..count, fn(_x) -> generateStrings() end)#generating random strings of count number and storing them in a list to send to worker 
  end 
  
  def generateStrings() do #function to generate random strings by appending gator link Id
      @gatorlinkid <> (:crypto.strong_rand_bytes(@stringlength) |> Base.url_encode64 |> binary_part(0, @stringlength) ) #generating random string by appending gatorlinkId
  end   
end

###
  #Worker helper functions module
###
defmodule HelperFunctionsClient do
  def generateAndValidateBitcoins(string_list, zero_count) do #validating whether the bit coins have the given number of zeroes 
      Enum.map(string_list, fn(x) -> {x,  Base.encode16(:crypto.hash(:sha256,x ))} end ) # taking the input list and storing the string and its sha256 hashed value into a map.
      |> Enum.filter(fn(bitcoin) ->  String.starts_with?(elem(bitcoin, 1), String.duplicate("0", zero_count)) end)#filtering the hashed values for the number of zeros given as input.
  end

  def encodeInputSha256(str) do 
      Base.encode16(:crypto.hash(:sha256, str ))  #hashing
  end
end

###
  #Server module
###
defmodule Server do
  @pidname "meghaname"
  @count 1
  
  #function for initializing the server
  def initializeServer(leadingZeros,ipaddress) do # initialize server will spawn a server process  
    ip = "meghaname@" <>"#{ipaddress}" #server name
    spawn(__MODULE__  ,  :mineServer,  [self()] ) #storing the pid after spawning thr process   
    IO.inspect(ip)
    IO.inspect(Node.start(:"#{ip}"))  #this is the IP of the machine on which you run the code
    IO.inspect(Node.set_cookie :cookie) #setting the cookie 
    IO.inspect(:global.register_name("server", self()))
    IO.puts("Server started")#registering a name to the process Id so that we can use the pid globally
    #:global.sync
    #IO.inspect(:global.whereis_name(@pidname))
    workAllocator(leadingZeros)  
  end
  
  #function for the server to mine coins
  def mineServer(serverPid) do
    Worker.serverWork(serverPid) #starts mining by the server 
  end
  
  #function for server allocating the work to the client
  def workAllocator(leadingZeros) do
    receive do
      {:joined, clientPid} -> #waiting for the client to send a "joined" status and the it's process id.
        list = HelperFunctionsServer.randomStringGenerator(@count)#If client sends the "joined" status with it's pid then generate list of random strings
        send clientPid, {:ok, list, clientPid, leadingZeros}#send the generated strings to the client to mine bit coins using SHA256
      {:response, clientPid, bitcoins} ->#Waiting for the client to send the mined bit coins with the response status
        Enum.each(bitcoins, fn(bitcoinPair) -> IO.puts elem(bitcoinPair,0) <> "\t" <> elem(bitcoinPair,1) end)#printing the bitcoins in the asked format
        list = HelperFunctionsServer.randomStringGenerator(@count)#after client sending the mined bitcoins we again generate a list of random strings
        send clientPid, {:ok, list, clientPid, leadingZeros}# we again assign the work to client by sending th enwly generated list
    end 
    workAllocator(leadingZeros)#again calling the workallocator to continously allocate work to the clients  
  end
end

###  
  #Module for Worker
###
defmodule Worker do
  @pidname "meghaname"
  
  #function to run multiple processes as the number of cores available in the machine
  def serverWork(serverPid) do
    numberOfProcessors = :erlang.system_info(:logical_processors) #calculate number of cores on the machine
    for _x <- 1..100*numberOfProcessors do
      initializeClient(serverPid) #initialize the workers
    end
  end
  
  #function to spawn workers
  def spawnClient(serverIp,clientIp) do
    ip = "worker"<>"#{:rand.uniform(100)}"<>"@" <> "#{clientIp}"  #generating random names for workers
    IO.inspect(Node.start(:"#{ip}"))  #this is the IP of the machine on which you run the code
    IO.inspect(Node.set_cookie :cookie) #setting cookie
    IO.inspect(Node.connect(:"#{serverIp}"))  #connecting to the server
    globalVariableSync(:global.whereis_name(@pidname))  #waiting for server pid 
    serverPid =  :global.whereis_name(@pidname) #retrieving the server pid
    numberOfProcessors = :erlang.system_info(:logical_processors) #number of cores in the machine
    for _process <- 1..3*numberOfProcessors do
      initializeClient(serverPid) #initialize workers as the number of cores for each client
    end
    keepAlive(serverIp) #keeping the client alive
  end

  #function to initialize the client
  def initializeClient(serverPid) do # initializing the client process
    clientPid = spawn(__MODULE__, :miner, [serverPid]) # storing the the client process id so that we can send the server  client's process id and a message stating that client has joined
    send serverPid, {:joined, clientPid}# retrieving the server pid using global name we set
  end

  def keepAlive(serverIp) do
    if false == Node.connect(:"#{serverIp}") do
        IO.puts("server exited")
       exit(0)# checking for server status
    end
    keepAlive(serverIp)
  end

  #function to wait until we get the process id of the server
  def globalVariableSync(pidname) do
    :global.sync()
    if(pidname == :undefined) do
      globalVariableSync(:global.whereis_name(@pidname))
    end
  end

  #function to mine bit coins
  def miner(serverPid) do# mines bitcoins and sends results to the server
    receive do
      {:ok, list, clientPid, leadingZeros} -># waits for server message with status ok and list of randomly generated strings
        bitcoins = HelperFunctionsClient.generateAndValidateBitcoins(list, leadingZeros) #Fix the hard coding#mines the bitcoins 
        send serverPid, {:response, clientPid, bitcoins}# send the server pid  mined bitcoins along with client Pid
        miner(serverPid)#calling the miner function to repeat the process
    end	
  end
end

