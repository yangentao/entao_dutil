

void hel({required int $a, required String b}){
  print($a);
  print(b);
}

void main(){
  int $a = 2;
  print($a);
  hel($a: 10, b : "ab");
}