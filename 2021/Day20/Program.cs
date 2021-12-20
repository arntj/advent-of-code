using Day20;
using System.Reflection;

string dataPath = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location) ?? string.Empty;
string[] data = File.ReadAllLines(Path.Combine(dataPath, @"Data\input.txt"));

(string image, string algorithm, char infiniteValue) = ImageEnhancer.ParseInput(data);

(image, infiniteValue) = ImageEnhancer.Enhance(image, algorithm, infiniteValue);
(image, infiniteValue) = ImageEnhancer.Enhance(image, algorithm, infiniteValue);

int partOne = image.Where(c => c == '#').Count();
int partTwo = 0;

Console.WriteLine($"Result part one: {partOne}");
Console.WriteLine($"Result part two: {partTwo}");
