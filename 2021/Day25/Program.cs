using Day25;
using System.Reflection;

string dataPath = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location) ?? string.Empty;
string[] data = File.ReadAllLines(Path.Combine(dataPath, @"Data\input.txt"));

var seafloor = new Seafloor(data);
int partOne = seafloor.MoveUntilStop();

Console.WriteLine($"Result part one: {partOne}");
