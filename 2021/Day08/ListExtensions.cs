namespace Day08
{
    public static class ListExtensions
    {
        public static T RemoveAndReturn<T>(this List<T> list, Func<T, bool> predicate)
        {
            T item = list.Single(predicate);
            list.Remove(item);
            return item;
        }
    }
}
