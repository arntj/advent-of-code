// this function was stolen from this website: http://www.javascripter.net/faq/numberisprime.htm
function isPrime3(n) {
  if (isNaN(n) || !isFinite(n) || n%1 || n<2) return false; 
  if (n%2==0) return (n==2);
  if (n%3==0) return (n==3);
  var m=Math.sqrt(n);
  for (var i=5;i<=m;i+=6) {
   if (n%i==0)     return false;
   if (n%(i+2)==0) return false;
  }
  return true;
 }

module.exports = isPrime3;