sd = sensorData();
%tic;
%sd.getCommand()
for i = 1:10
    pause(.1)
    command = sd.getCommand()
end

delete(sd)