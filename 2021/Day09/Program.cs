using Day09;
using System.Reflection;

string dataPath = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location) ?? string.Empty;
string[] data = File.ReadAllLines(Path.Combine(dataPath, @"Data\input.txt"));

int partOne = HeightMapSeeker.FindLowPoints(data);
int partTwo = HeightMapSeeker.FindBasins(data);
Console.WriteLine($"Result part one: {partOne}");
Console.WriteLine($"Result part two: {partTwo}");
