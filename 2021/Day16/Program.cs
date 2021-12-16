using Day16;
using System.Reflection;

string dataPath = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location) ?? string.Empty;
string[] data = File.ReadAllLines(Path.Combine(dataPath, @"Data\input.txt"));

var package = BitsParser.Parse(data[0]);
int partOne = BitsParser.SumVersions(package);
long partTwo = BitsParser.Execute(package);

Console.WriteLine($"Result part one: {partOne}");
Console.WriteLine($"Result part two: {partTwo}");
