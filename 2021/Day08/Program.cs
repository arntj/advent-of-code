using Day08;
using System.Reflection;

string dataPath = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location) ?? string.Empty;
string[] data = File.ReadAllLines(Path.Combine(dataPath, @"Data\input.txt"));

int partOne = SevenSegmentDisplayAdapter.CountUniqueDigits(data);
int partTwo = SevenSegmentDisplayAdapter.InterpretAndAddSignals(data);
Console.WriteLine($"Result part one: {partOne}");
Console.WriteLine($"Result part two: {partTwo}");
