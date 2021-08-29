using System;
using NUnit.Framework;
using System.Net.Sockets;
using System.IO;

namespace TestProject1
{
    public class Tests
    {
        private Byte[] data;
        // Use this for initialization
        internal Boolean socketReady = false;
        TcpClient mySocket;
        NetworkStream theStream;
        StreamWriter theWriter;
        StreamReader theReader;
        String Host = "localhost";
        Int32 Port = 55000;
        
        void Start () {
            setupSocket ();
            Console.Out.WriteLine("socket is set up");
        }
        
        public String ConvertToString(Byte[] dataArray, int counter, int length)
        {
            String output = "";
            for (int i = counter; i < counter + length; i++)
        {
            output += (char) dataArray[i];
        }
            return output;

        }
        
        void processStringCommand(String command, String value){
            Console.Out.WriteLine("value: " + value);
            Console.Out.WriteLine("value: " + value);
        }
        
        void processDoubleCommand(String command, double value){
            Console.Out.WriteLine("value: " + value);
            Console.Out.WriteLine("value: " + value);
        }
        
        void processFloatCommand(String command, float value){
            Console.Out.WriteLine("value: " + value);
            Console.Out.WriteLine("value: " + value);
        }
        
        void processInt32Command(String command, Int32 value){
            Console.Out.WriteLine("value: " + value);
            Console.Out.WriteLine("value: " + value);
        }
        
        void processUInt32Command(String command, UInt32 value){
            Console.Out.WriteLine("value: " + value);
            Console.Out.WriteLine("value: " + value);
        }
        
        void processInt16Command(String command, Int16 value){
            Console.Out.WriteLine("value: " + value);
            Console.Out.WriteLine("value: " + value);
        }
        
        void processUInt16Command(String command, UInt16 value){
            Console.Out.WriteLine("value: " + value);
            Console.Out.WriteLine("value: " + value);
        }
        
        public void processData(Byte[] dataArray){
            int numFields = dataArray[0];
            
            int counter = 1;
            for (int i = 0; i < numFields; i++){
                int fieldNameLength = dataArray[counter];
                counter = counter + 1;
                String fieldName = ConvertToString(dataArray, counter, fieldNameLength);
                counter = counter + fieldNameLength;
                int classNameLength = dataArray[counter];
                counter = counter + 1;
                String className = ConvertToString(dataArray, counter, classNameLength);
                counter = counter + classNameLength;
                int valueLength = dataArray[counter];
                counter = counter + 1;
                // all supported Types
                // 'double', 'single', 'uint16', 'uint32' 'int16', 'int32', 'char'
                switch (className)
                {
                    case "char":
                        String value_String = ConvertToString(dataArray, counter, valueLength);
                        processStringCommand(fieldName, value_String);
                        break;
                    case "double":
                        double value_double = BitConverter.ToDouble( dataArray, counter);
                        processDoubleCommand(fieldName, value_double);
                        break;
                    case "single":
                        float value_float = BitConverter.ToSingle( dataArray, counter);
                        processFloatCommand(fieldName, value_float);
                        break;
                    case "int32":
                        Int32 value_int32 = BitConverter.ToInt32( dataArray, counter);
                        processInt32Command(fieldName, value_int32);
                        break;
                    case "uint32":
                        UInt32 value_uint32 = BitConverter.ToUInt32( dataArray, counter);
                        processUInt32Command(fieldName, value_uint32);
                        break;
                    case "int16":
                        Int16 value_int16 = BitConverter.ToInt16( dataArray, counter);
                        processInt16Command(fieldName, value_int16);
                        break;
                    case "uint16":
                        UInt16 value_uint16 = BitConverter.ToUInt16( dataArray, counter);
                        processUInt16Command(fieldName, value_uint16);
                        break;
                }
                counter = counter + valueLength;
            }
        }
        
        public void readDate(){
            try {
                data = new Byte[256];
                // Read the first batch of the TcpServer response bytes.
                theStream.Read(data, 0, data.Length);
                processData(data); 
            }
            catch (Exception e) {
                Console.Out.WriteLine("Socket error: " + e);
            }
        }
        
        public void setupSocket() {
            try {
                mySocket = new TcpClient(Host, Port);
                theStream = mySocket.GetStream();
                theWriter = new StreamWriter(theStream);
                socketReady = true;
            }
            catch (Exception e) {
                Console.Out.WriteLine("Socket error: " + e);
            }
        }

        [Test]
        public void Test1()
        {
            Start();
            readDate();
            Assert.Pass();
        }
    }
}