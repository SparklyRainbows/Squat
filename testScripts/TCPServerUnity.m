clear all
commands = {'jump', 'roll', 'turn', 'crouch'};
tcpipServer = tcpserver('127.0.0.1', 55000);
tic
while toc < 10000000
   ind = randi(4);
   if ind == 3
    inputStruct = struct(commands{ind}, single(sign(rand(1)-.5)*1.0));
   else
    inputStruct = struct(commands{ind}, single(1.0));
   end
    if tcpipServer.Connected
        data = structToData(inputStruct);
        write(tcpipServer, data);
    end
    pause(.5)
end