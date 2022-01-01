using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Day25
{
    public enum Location
    {
        Empty,
        SeafishE,
        SeafishS
    }
    public class Seafloor
    {
        private readonly Location[,] _seafloor;

        public Seafloor(string[] input)
        {
            int h = input.Length;
            int w = input[0].Length;

            _seafloor = new Location[h, w];

            for (int y = 0; y < h; y++)
            {
                for (int x = 0; x < w; x++)
                {
                    _seafloor[y, x] = input[y][x] switch
                    {
                        '.' => Location.Empty,
                        '>' => Location.SeafishE,
                        'v' => Location.SeafishS,
                        _ => throw new NotImplementedException()
                    };
                }
            }
        }

        public int MoveUntilStop()
        {
            int i = 0;

            while (Move())
            {
                i++;
            }

            return i + 1;
        }

        public bool Move()
        {
            List<(int fromX, int fromY, int toX, int toY)> eastMoves = new();

            // Move the east-facing seafish
            for (int y = 0; y < _seafloor.GetLength(0); y++)
            {
                for (int x = 0; x < _seafloor.GetLength(1); x++)
                {
                    int nextX = (x + 1) % _seafloor.GetLength(1);
                    if (_seafloor[y,x] == Location.SeafishE && _seafloor[y, nextX] == Location.Empty)
                    {
                        eastMoves.Add((x, y, nextX, y));
                    }
                }
            }

            foreach ((int fromX, int fromY, int toX, int toY) in eastMoves)
            {
                _seafloor[toY, toX] = Location.SeafishE;
                _seafloor[fromY, fromX] = Location.Empty;
            }

            List<(int fromX, int fromY, int toX, int toY)> southMoves = new();

            // Move the south-facing seafish
            for (int x = 0; x < _seafloor.GetLength(1); x++)
            {
                for (int y = 0; y < _seafloor.GetLength(0); y++)
                {
                    int nextY = (y + 1) % _seafloor.GetLength(0);
                    if (_seafloor[y, x] == Location.SeafishS && _seafloor[nextY, x] == Location.Empty)
                    {
                        southMoves.Add((x, y, x, nextY));
                    }
                }
            }

            foreach ((int fromX, int fromY, int toX, int toY) in southMoves)
            {
                _seafloor[toY, toX] = Location.SeafishS;
                _seafloor[fromY, fromX] = Location.Empty;
            }

            return eastMoves.Any() || southMoves.Any();
        }

        public override string ToString()
        {
            StringBuilder res = new();

            for (int y = 0; y < _seafloor.GetLength(0); y++)
            {
                for (int x = 0; x < _seafloor.GetLength(1); x++)
                {
                    res.Append(_seafloor[y, x] switch
                    {
                        Location.Empty => ".",
                        Location.SeafishE => ">",
                        Location.SeafishS => "v",
                        _ => throw new NotImplementedException()
                    });
                }
                res.AppendLine();
            }

            return res.ToString();
        }
    }
}
