using Day02;
using System.Reflection;

string dataPath = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location) ?? string.Empty;
string[] data = File.ReadAllLines(Path.Combine(dataPath, @"Data\input.txt"));

(int pos, int aim, int depth) = SubmarineNavigator.ParseDirections(data);
Console.WriteLine($"Result part one: {pos * aim}");
Console.WriteLine($"Result part two: {pos * depth}");
