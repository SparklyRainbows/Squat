clear all
pong();
commands = {'downarrow','uparrow'};
tcpipServer = tcpserver('127.0.0.1', 55000);
tic
while toc < 10000000
   ind = randi(2);
   inputStruct = struct('Key', commands{ind});
    if tcpipServer.Connected
        data = structToData(inputStruct);
        write(tcpipServer, data);
    end
    pause(.1)
end