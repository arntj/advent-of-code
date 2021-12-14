using Day14;
using System.Reflection;

string dataPath = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location) ?? string.Empty;
string[] data = File.ReadAllLines(Path.Combine(dataPath, @"Data\input.txt"));

long partOne = Polymerizator.InsertPolymers(data, 10);
long partTwo = Polymerizator.InsertPolymers(data, 40);

Console.WriteLine($"Result part one: {partOne}");
Console.WriteLine($"Result part two: {partTwo}");
