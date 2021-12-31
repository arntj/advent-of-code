using Day23;
using System.Reflection;

string dataPath = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location) ?? string.Empty;
string[] data = File.ReadAllLines(Path.Combine(dataPath, @"Data\input.txt"));

//string[] test = new[]
//{
//    "#############",
//    "#..........D#",
//    "###A#B#C#.###",
//    "  #A#B#C#D#",
//    "  #A#B#C#D#",
//    "  #A#B#C#D#",
//    "  #########"
//};

//var res = BurrowOrganizer.GetValidMoves(test, 0).ToList();

long partOne = BurrowOrganizer.Organize(data);

string[] extendedData = BurrowOrganizer.InsertExtraRows(data);
long partTwo = BurrowOrganizer.Organize(extendedData);

Console.WriteLine($"Result part one: {partOne}");
Console.WriteLine($"Result part two: {partTwo}");
