using Day22;
using System.Reflection;

string dataPath = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location) ?? string.Empty;
string[] data = File.ReadAllLines(Path.Combine(dataPath, @"Data\input.txt"));

var core = new ReactorCore();
core.Parse(data);

long partOne = core.GetInitializationCubesCount();
long partTwo = core.GetAllCubesCount();

Console.WriteLine($"Result part one: {partOne}");
Console.WriteLine($"Result part two: {partTwo}");
