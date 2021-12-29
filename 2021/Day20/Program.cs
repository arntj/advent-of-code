using Day20;
using System.Reflection;

string dataPath = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location) ?? string.Empty;
string[] data = File.ReadAllLines(Path.Combine(dataPath, @"Data\input.txt"));

var image = new Image(data);

image.Enhance(2);
int partOne = image.PointsCount;

image.Enhance(48);
int partTwo = image.PointsCount;

Console.WriteLine($"Result part one: {partOne}");
Console.WriteLine($"Result part two: {partTwo}");
