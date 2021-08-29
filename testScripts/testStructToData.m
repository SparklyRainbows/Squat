inputStruct = struct('running', true, 'speed', 10.1, 'lean', int32(5));
data  = structToData(inputStruct);
outputStruct = dataToStruct(data);

