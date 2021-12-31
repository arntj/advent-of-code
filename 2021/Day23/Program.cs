using Day23;
using System.Reflection;

string dataPath = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location) ?? string.Empty;
string[] data = File.ReadAllLines(Path.Combine(dataPath, @"Data\input.txt"));

int partOne = BurrowOrganizer.Organize(data);

string[] extendedData = BurrowOrganizer.InsertExtraRows(data);
int partTwo = BurrowOrganizer.Organize(extendedData);

Console.WriteLine($"Result part one: {partOne}");
Console.WriteLine($"Result part two: {partTwo}");
